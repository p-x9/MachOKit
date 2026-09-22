//
//  LazyLoadDylib.swift
//  MachOKit
//
//  Created by Codex on 2026/09/19.
//

import Foundation
import MachOKitC
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
internal import FileIOBinary
#else
@_implementationOnly import FileIO
@_implementationOnly import FileIOBinary
#endif

/// Information describing a dylib that dyld loads when one of its symbols is first used.
///
/// The layout is the header of the `LC_LAZY_LOAD_DYLIB_INFO` payload in `__LINKEDIT`.
/// The load path, symbol-offset array, and symbol strings follow this header in the payload.
///
/// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/mach_o/LazyLoadDylib.cpp#L32)
public struct LazyLoadDylib: LayoutWrapper, Sendable {
    public typealias Layout = LazyLoadDylibLinkEdit

    public var layout: Layout
    /// File offset of the payload referenced by `LC_LAZY_LOAD_DYLIB_INFO`.
    public let dataOffset: Int
    /// Size of the payload referenced by `LC_LAZY_LOAD_DYLIB_INFO`.
    public let dataSize: Int
}

extension LazyLoadDylib {
    /// A copy with the byte order of each binary layout field reversed.
    /// The payload's file offset and size are unchanged.
    public var swapped: Self {
        var layout = self.layout
        layout.loadPathOffset = layout.loadPathOffset.byteSwapped
        layout.flagImageOffset = layout.flagImageOffset.byteSwapped
        layout.flags = layout.flags.byteSwapped
        layout.pointerFormat = layout.pointerFormat.byteSwapped
        layout.chainStartImageOffset = layout.chainStartImageOffset.byteSwapped
        layout.symbolsCount = layout.symbolsCount.byteSwapped
        layout.symbolStringArrayOffset = layout.symbolStringArrayOffset.byteSwapped
        return .init(layout: layout, dataOffset: dataOffset, dataSize: dataSize)
    }
}

extension LazyLoadDylib {
    /// Offset from the Mach-O header to dyld's 32-bit image-loaded flag.
    public var flagImageOffset: UInt32 {
        layout.flagImageOffset
    }

    /// Number of symbol-name offsets stored in the payload.
    public var symbolsCount: Int {
        numericCast(layout.symbolsCount)
    }

    /// Chained-fixup pointer format used by the lazy binding chain.
    public var pointerFormat: DyldChainedFixupPointerFormat? {
        .init(rawValue: layout.pointerFormat)
    }

    /// Offset from the Mach-O header to the start of the lazy binding chain.
    public var chainStartImageOffset: UInt32 {
        layout.chainStartImageOffset
    }

    /// Whether the dylib is allowed to be missing at runtime.
    public var dylibMayBeMissing: Bool {
        layout.flags & 0x0001 != 0
    }

    /// Whether the dylib's symbols were bound before the lazy load.
    ///
    /// Mirrors dyld's `dylibSymbolsAlreadyBound()`. When set, dyld skips the
    /// lazy binding chain. In a shared cache, the original bind ordinals and
    /// chain boundaries are no longer recoverable from the stored pointers.
    public var dylibSymbolsAlreadyBound: Bool {
        // TODO: Verify this flag and the lazy-chain skip behavior against Apple's
        // published LazyLoadDylib / DyldAPIs implementation once available.
        // Currently based on dylibSymbolsAlreadyBound() in iOS 27 (24A5355q)
        // dyld; the public dyld-1378 source still hardcodes alreadyBound = false.
        // https://github.com/apple-oss-distributions/dyld/blob/main/mach_o/LazyLoadDylib.cpp
        layout.flags & 0x0002 != 0
    }
}

extension LazyLoadDylib {
    /// Reads dyld's image-loaded flag, or returns `nil` if it is unavailable.
    ///
    /// A nonzero value means dyld completed the lazy load. This is distinct
    /// from ``dylibSymbolsAlreadyBound``: prebound symbols do not imply that
    /// the dylib has been initialized.
    public func imageLoadedFlag(in machO: MachOFile) -> UInt32? {
        guard let (file, offset) = fileAndOffset(
            at: numericCast(flagImageOffset),
            length: MemoryLayout<UInt32>.size,
            in: machO
        ), let value: UInt32 = try? file.read(offset: offset) else {
            return nil
        }
        return machO.isSwapped ? value.byteSwapped : value
    }

    /// Reads dyld's live image-loaded flag, or returns `nil` if it is unavailable.
    ///
    /// This is a snapshot, not synchronization with dyld. The caller must
    /// prevent concurrent lazy binding while inspecting the chain.
    public func imageLoadedFlag(in machO: MachOImage) -> UInt32? {
        guard let address = unslidAddress(at: numericCast(flagImageOffset), in: machO) else {
            return nil
        }
        let (end, overflow) = address.addingReportingOverflow(4)
        guard !overflow, machO.segments.contains(where: {
            guard let range = $0.virtualMemoryRange else { return false }
            return range.lowerBound <= address && end <= range.upperBound
        }) else { return nil }
        return machO.ptr.advanced(by: numericCast(flagImageOffset))
            .loadUnaligned(as: UInt32.self)
    }
}

extension LazyLoadDylib {
    /// Path of the dylib to load lazily.
    ///
    /// - Parameter machO: The file-backed Mach-O containing the payload.
    /// - Returns: The dylib path, or `nil` if the payload is unavailable or invalid.
    public func loadPath(in machO: MachOFile) -> String? {
        guard let stringsOffset else { return nil }
        guard let fileSlice = linkEditSlice(for: machO) else {
            return nil
        }
        return string(
            at: stringsOffset,
            in: .init(start: fileSlice.ptr, count: fileSlice.size)
        )
    }

    /// Path of the dylib to load lazily.
    ///
    /// - Parameter machO: The memory-backed Mach-O containing the payload.
    /// - Returns: The dylib path, or `nil` if the payload is unavailable or invalid.
    public func loadPath(in machO: MachOImage) -> String? {
        guard let stringsOffset else { return nil }
        guard let ptr = linkEditPtr(for: machO, additionalFileOffset: 0) else {
            return nil
        }
        return string(at: stringsOffset, in: .init(start: ptr, count: dataSize))
    }
}

extension LazyLoadDylib {
    /// Symbol-name offsets stored in the lazy-load payload.
    ///
    /// Each value is a byte offset from the beginning of the
    /// `LC_LAZY_LOAD_DYLIB_INFO` payload and can be passed to
    /// `symbolName(at:in:)`.
    ///
    /// Values are returned in host byte order.
    ///
    /// - Parameter machO: The file-backed Mach-O containing the payload.
    /// - Returns: The symbol-name offsets, or `nil` if the payload or offset array is invalid.
    public func symbolOffsets(in machO: MachOFile) -> DataSequence<UInt32>? {
        guard let symbolOffsetsRange,
              let fileSlice = linkEditSlice(for: machO) else {
            return nil
        }
        return fileSlice.readDataSequence(
            offset: numericCast(symbolOffsetsRange.lowerBound),
            numberOfElements: symbolsCount,
            swapHandler: { data in
                guard machO.isSwapped else { return }
                data.withUnsafeMutableBytes { bytes in
                    for index in 0..<symbolsCount {
                        let offset = index * MemoryLayout<UInt32>.size
                        let value = bytes.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
                        bytes.storeBytes(of: value.byteSwapped, toByteOffset: offset, as: UInt32.self)
                    }
                }
            }
        )
    }

    /// Symbol-name offsets stored in the lazy-load payload.
    ///
    /// Each value is a byte offset from the beginning of the
    /// `LC_LAZY_LOAD_DYLIB_INFO` payload and can be passed to
    /// `symbolName(at:in:)`.
    ///
    /// - Parameter machO: The memory-backed Mach-O containing the payload.
    /// - Returns: The symbol-name offsets, or `nil` if the payload or offset array is invalid.
    public func symbolOffsets(in machO: MachOImage) -> MemorySequence<UInt32>? {
        guard let symbolOffsetsRange,
              let ptr = linkEditPtr(
                for: machO,
                additionalFileOffset: symbolOffsetsRange.lowerBound
              ) else {
            return nil
        }
        return .init(
            basePointer: ptr.assumingMemoryBound(to: UInt32.self),
            numberOfElements: symbolsCount
        )
    }
}

extension LazyLoadDylib {
    /// Resolves a symbol name at an offset within the lazy-load payload.
    ///
    /// - Parameters:
    ///   - offset: A byte offset from the beginning of the
    ///     `LC_LAZY_LOAD_DYLIB_INFO` payload, typically obtained from
    ///     `symbolOffsets(in:)`.
    ///   - machO: The file-backed Mach-O containing the payload.
    /// - Returns: The symbol name, or `nil` if the offset or string is invalid.
    public func symbolName(at offset: Int, in machO: MachOFile) -> String? {
        guard let fileSlice = linkEditSlice(for: machO) else {
            return nil
        }
        return string(
            at: offset,
            in: .init(start: fileSlice.ptr, count: fileSlice.size)
        )
    }

    /// Resolves a symbol name at an offset within the lazy-load payload.
    ///
    /// - Parameters:
    ///   - offset: A byte offset from the beginning of the
    ///     `LC_LAZY_LOAD_DYLIB_INFO` payload, typically obtained from
    ///     `symbolOffsets(in:)`.
    ///   - machO: The memory-backed Mach-O containing the payload.
    /// - Returns: The symbol name, or `nil` if the offset or string is invalid.
    public func symbolName(at offset: Int, in machO: MachOImage) -> String? {
        guard let ptr = linkEditPtr(
            for: machO,
            additionalFileOffset: 0
        ) else {
            return nil
        }
        return string(
            at: offset,
            in: .init(start: ptr, count: dataSize)
        )
    }
}

extension LazyLoadDylib {
    /// Chained-fixup pointers used to bind symbols from the lazily loaded dylib.
    ///
    /// The chain begins at ``chainStartImageOffset`` and uses ``pointerFormat``.
    /// Each returned pointer offset is relative to the Mach-O header.
    ///
    /// - Note: When ``dylibSymbolsAlreadyBound`` is set, the original lazy
    ///   chain is unavailable. Cache slide chains are not lazy binding chains
    ///   and must not be decoded using this payload's pointer format.
    /// - Parameter machO: The file-backed Mach-O containing the chain.
    /// - Returns: The fixup pointers, or `nil` if the chain is unavailable or invalid.
    ///
    /// [dyld chain traversal implementation](https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/mach_o/Image.cpp#L1251-L1273)
    public func fixups(in machO: MachOFile) -> [DyldChainedFixupPointer]? {
        guard !dylibSymbolsAlreadyBound,
              let pointerFormat else { return nil }
        return fixups(pointerFormat: pointerFormat) { offset in
            fixupPointerInfo(
                at: offset,
                in: machO,
                pointerFormat: pointerFormat
            )
        }
    }

    /// Chained-fixup pointers used to bind symbols from the lazily loaded dylib.
    ///
    /// The chain begins at ``chainStartImageOffset`` and uses ``pointerFormat``.
    /// Each returned pointer offset is relative to the Mach-O header.
    ///
    /// - Important: dyld overwrites chain entries with resolved addresses after
    ///   completing the lazy bind, so an already-processed chain is no longer decodable.
    ///   Prebound chains also return `nil`. The caller must prevent concurrent
    ///   lazy binding; checking the loaded flag alone cannot make traversal atomic.
    /// - Parameter machO: The memory-backed Mach-O containing the chain.
    /// - Returns: The fixup pointers, or `nil` if the chain is unavailable or invalid.
    ///
    /// [dyld chain traversal implementation](https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/mach_o/Image.cpp#L1251-L1273)
    public func fixups(in machO: MachOImage) -> [DyldChainedFixupPointer]? {
        guard !dylibSymbolsAlreadyBound,
              imageLoadedFlag(in: machO) == 0,
              let pointerFormat else { return nil }
        return fixups(pointerFormat: pointerFormat) { offset in
            fixupPointerInfo(
                at: offset,
                in: machO,
                pointerFormat: pointerFormat
            )
        }
    }
}

extension LazyLoadDylib {
    init?(
        data: Data,
        dataOffset: Int,
        dataSize: Int
    ) {
        guard let value = data.withUnsafeBytes({
            Self(
                bytes: $0,
                dataOffset: dataOffset,
                dataSize: dataSize
            )
        }) else {
            return nil
        }
        self = value
    }

    init?(
        bytes: UnsafeRawBufferPointer,
        dataOffset: Int,
        dataSize: Int
    ) {
        guard dataSize >= Self.layoutSize,
              bytes.count >= Self.layoutSize else {
            return nil
        }

        let layout = bytes.loadUnaligned(as: Layout.self)

        self.init(
            layout: layout,
            dataOffset: dataOffset,
            dataSize: dataSize
        )
    }
}

// MARK: - Payload Offset Validation

extension LazyLoadDylib {
    private var symbolOffsetsRange: Range<Int>? {
        guard let offset = Int(exactly: layout.symbolStringArrayOffset),
              let count = Int(exactly: layout.symbolsCount),
              count == 0 || offset >= Self.layoutSize else {
            return nil
        }
        let (size, sizeOverflow) = count.multipliedReportingOverflow(
            by: MemoryLayout<UInt32>.size
        )
        let (end, endOverflow) = offset.addingReportingOverflow(size)
        guard !sizeOverflow,
              !endOverflow,
              end <= dataSize else {
            return nil
        }
        return offset..<end
    }

    private var stringsOffset: Int? {
        guard let offset = Int(exactly: layout.loadPathOffset),
              offset >= Self.layoutSize,
              offset < dataSize else {
            return nil
        }
        return offset
    }
}

// MARK: - String Decoding

extension LazyLoadDylib {
    private func string(
        at offset: Int,
        in bytes: UnsafeRawBufferPointer
    ) -> String? {
        guard offset >= 0, offset < bytes.count else { return nil }
        let string = bytes[offset...]
        guard let end = string.firstIndex(of: 0) else { return nil }
        return String(bytes: string[..<end], encoding: .utf8)
    }
}

// MARK: - Fixup Chain Decoding

extension LazyLoadDylib {
    private func fixups(
        pointerFormat: DyldChainedFixupPointerFormat,
        fixupInfoAtOffset: (Int) -> DyldChainedFixupPointerInfo?
    ) -> [DyldChainedFixupPointer]? {
        let result = DyldChainedFixupPointer.walkChain(
            startOffset: numericCast(chainStartImageOffset),
            pointerOffsetBias: 0,
            pointerFormat: pointerFormat,
            fixupInfoAtOffset: fixupInfoAtOffset
        )
        guard result.reachedEnd,
              result.pointers.allSatisfy({
                  guard let bind = $0.fixupInfo.bind else { return false }
                  return (0..<symbolsCount).contains(bind.ordinal)
              }) else { return nil }
        return result.pointers
    }

    private func fixupPointerInfo(
        at imageOffset: Int,
        in machO: MachOFile,
        pointerFormat: DyldChainedFixupPointerFormat
    ) -> DyldChainedFixupPointerInfo? {
        let size = pointerFormat.is64Bit
        ? MemoryLayout<UInt64>.size
        : MemoryLayout<UInt32>.size

        guard let (file, offset) = fileAndOffset(
            at: imageOffset,
            length: size,
            in: machO
        ) else {
            return nil
        }

        if pointerFormat.is64Bit {
            guard var rawValue: UInt64 = try? file.read(offset: offset) else {
                return nil
            }
            if machO.isSwapped { rawValue = rawValue.byteSwapped }
            return .init(rawValue: rawValue, pointerFormat: pointerFormat)
        } else {
            guard var rawValue: UInt32 = try? file.read(offset: offset) else {
                return nil
            }
            if machO.isSwapped { rawValue = rawValue.byteSwapped }
            return .init(rawValue: rawValue, pointerFormat: pointerFormat)
        }
    }

    private func fixupPointerInfo(
        at imageOffset: Int,
        in machO: MachOImage,
        pointerFormat: DyldChainedFixupPointerFormat
    ) -> DyldChainedFixupPointerInfo? {
        let size = pointerFormat.is64Bit
        ? MemoryLayout<UInt64>.size
        : MemoryLayout<UInt32>.size

        guard let address = unslidAddress(
            at: imageOffset,
            in: machO
        ) else {
            return nil
        }
        let (lastByteAddress, overflow) = address
            .addingReportingOverflow(UInt64(size - 1))
        guard !overflow else { return nil }
        guard machO.contains(unslidAddress: address),
              machO.contains(unslidAddress: lastByteAddress) else {
            return nil
        }

        let ptr = machO.ptr.advanced(by: imageOffset)
        if pointerFormat.is64Bit {
            let rawValue = ptr.loadUnaligned(as: UInt64.self)
            return .init(rawValue: rawValue, pointerFormat: pointerFormat)
        } else {
            let rawValue = ptr.loadUnaligned(as: UInt32.self)
            return .init(rawValue: rawValue, pointerFormat: pointerFormat)
        }
    }
}

// MARK: - File Offset Resolution

extension LazyLoadDylib {
    private func fileAndOffset(
        at imageOffset: Int,
        length: Int,
        in machO: MachOFile
    ) -> (MachOFile.File, Int)? {
        if machO.isLoadedFromDyldCache {
            guard let address = unslidAddress(at: imageOffset, in: machO) else {
                return nil
            }
            guard let fullCache = machO.fullCache,
                  let (cache, fileOffset) = fullCache.cacheAndFileOffset(
                    for: address
                  ) else {
                return nil
            }
            guard length > 0,
                  let mapping = cache.mappingAndSlideInfo(for: address) else { return nil }
            let (end, overflow) = address.addingReportingOverflow(UInt64(length))
            let (mappingEnd, mappingOverflow) = mapping.address.addingReportingOverflow(mapping.size)
            guard !overflow, !mappingOverflow, end <= mappingEnd else { return nil }
            return (cache.fileHandle, numericCast(fileOffset))
        }

        guard let address = unslidAddress(
            at: imageOffset,
            length: length,
            in: machO
        ) else {
            return nil
        }
        guard let fileOffset = machO.fileOffset(of: address) else {
            return nil
        }
        return (machO.fileHandle, machO.headerStartOffset + numericCast(fileOffset))
    }
}

// MARK: - Unslid Address Resolution

extension LazyLoadDylib {
    private func unslidAddress(
        at imageOffset: Int,
        in machO: any MachORepresentable
    ) -> UInt64? {
        guard imageOffset >= 0,
              let preferredLoadAddress = machO.preferredLoadAddress else {
            return nil
        }
        let (address, overflow) = preferredLoadAddress
            .addingReportingOverflow(UInt64(imageOffset))
        return overflow ? nil : address
    }

    private func unslidAddress(
        at imageOffset: Int,
        length: Int,
        in machO: any MachORepresentable
    ) -> UInt64? {
        guard length > 0,
              let address = unslidAddress(at: imageOffset, in: machO) else {
            return nil
        }

        let (rangeEnd, overflow) = address.addingReportingOverflow(UInt64(length))
        guard !overflow else { return nil }
        guard machO.segments.contains(where: { segment in
            guard let range = segment.fileBackedVirtualMemoryRange else {
                return false
            }
            return range.lowerBound <= address && rangeEnd <= range.upperBound
        }) else {
            return nil
        }
        return address
    }
}

// MARK: - Linkedit Access

extension LazyLoadDylib {
    private func linkEditSlice(
        for machO: MachOFile,
        additionalOffset: Int = 0
    ) -> MachOFile.File.FileSlice? {
        machO._fileSliceForLinkEditData(
            offset: dataOffset + additionalOffset,
            length: dataSize - additionalOffset
        )
    }

    private func linkEditPtr(
        for machO: MachOImage,
        additionalFileOffset: Int
    ) -> UnsafeRawPointer? {
        guard let vmaddrSlide = machO.vmaddrSlide else { return nil }

        let linkedit: (any SegmentCommandProtocol)? =
        machO.loadCommands.linkedit64 ?? machO.loadCommands.linkedit

        guard let linkedit,
              let linkeditStart = linkedit.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }

        let start = linkeditStart
            .advanced(by: -numericCast(linkedit.fileOffset))
            .advanced(by: dataOffset)
        return start.advanced(by: additionalFileOffset)
    }
}
