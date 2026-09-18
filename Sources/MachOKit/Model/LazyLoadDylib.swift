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
public struct LazyLoadDylib: LayoutWrapper, Sendable {
    public typealias Layout = LazyLoadDylibLinkEdit

    public var layout: Layout
    /// File offset of the payload referenced by `LC_LAZY_LOAD_DYLIB_INFO`.
    public let dataOffset: Int
    /// Size of the payload referenced by `LC_LAZY_LOAD_DYLIB_INFO`.
    public let dataSize: Int
}

extension LazyLoadDylib {
    /// Offset from the Mach-O header to the optional flag image.
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
        return fileSlice.readString(offset: numericCast(stringsOffset))
    }

    /// Path of the dylib to load lazily.
    ///
    /// - Parameter machO: The memory-backed Mach-O containing the payload.
    /// - Returns: The dylib path, or `nil` if the payload is unavailable or invalid.
    public func loadPath(in machO: MachOImage) -> String? {
        guard let stringsOffset else { return nil }
        guard let ptr = linkEditPtr(for: machO, additionalFileOffset: stringsOffset) else {
            return nil
        }
        return String(cString: ptr.assumingMemoryBound(to: CChar.self))
    }
}

extension LazyLoadDylib {
    /// Symbol-name offsets stored in the lazy-load payload.
    ///
    /// Each value is a byte offset from the beginning of the
    /// `LC_LAZY_LOAD_DYLIB_INFO` payload and can be passed to
    /// `symbolName(at:in:)`.
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
            numberOfElements: symbolsCount
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
        return symbolName(
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
        return symbolName(
            at: offset,
            in: .init(start: ptr, count: dataSize)
        )
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

extension LazyLoadDylib {
    private var symbolOffsetsRange: Range<Int>? {
        guard let offset = Int(exactly: layout.symbolStringArrayOffset),
              let count = Int(exactly: layout.symbolsCount) else {
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

extension LazyLoadDylib {
    private func symbolName(
        at offset: Int,
        in bytes: UnsafeRawBufferPointer
    ) -> String? {
        guard offset >= 0, offset < bytes.count else { return nil }
        let symbol = bytes[offset...]
        guard let end = symbol.firstIndex(of: 0) else { return nil }
        return String(bytes: symbol[..<end], encoding: .utf8)
    }
}

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
