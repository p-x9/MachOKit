//
//  MachOFile+DyldChainedFixups.swift
//
//
//  Created by p-x9 on 2024/01/11.
//
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif
import MachOKitC

extension MachOFile {
    public struct DyldChainedFixups {
        typealias FileSlice = File.FileSlice

        let fileSlice: FileSlice
        let isSwapped: Bool
    }
}

extension MachOFile.DyldChainedFixups: DyldChainedFixupsProtocol {
    public var header: DyldChainedFixupsHeader? {
        let ret = fileSlice.ptr
            .assumingMemoryBound(to: DyldChainedFixupsHeader.self)
            .pointee
        return isSwapped ? ret.swapped : ret
    }

    public var startsInImage: DyldChainedStartsInImage? {
        guard let header else { return nil }
        let offset: Int = numericCast(header.starts_offset)
        let ptr = fileSlice.ptr
            .advanced(by: offset)
        let layout = ptr
            .assumingMemoryBound(to: DyldChainedStartsInImage.Layout.self)
            .pointee
        let ret: DyldChainedStartsInImage = .init(
            layout: layout,
            offset: offset
        )
        return isSwapped ? ret.swapped : ret
    }

    public func startsInSegments(
        of startsInImage: DyldChainedStartsInImage?
    ) -> [DyldChainedStartsInSegment] {
        guard let startsInImage else { return [] }
        let offsets: [Int] = {
            let ptr = fileSlice.ptr
                .advanced(by: startsInImage.offset)
                .advanced(by: DyldChainedStartsInImage.layoutOffset(of: \.seg_info_offset))
            return UnsafeBufferPointer(
                start: ptr.assumingMemoryBound(to: UInt32.self),
                count: numericCast(startsInImage.seg_count)
            )
            .map { isSwapped ? $0.byteSwapped : $0 }
            .map { numericCast($0) }
        }()

        let ptr = fileSlice.ptr
            .advanced(by: startsInImage.offset)
        return offsets.enumerated().map { index, offset in
            let layout = ptr.advanced(by: offset)
                .assumingMemoryBound(to: DyldChainedStartsInSegment.Layout.self)
                .pointee
            let offset: Int = startsInImage.offset + offset
            let ret: DyldChainedStartsInSegment = .init(
                layout: layout,
                offset: offset,
                segmentIndex: index
            )
            return isSwapped ? ret.swapped : ret
        }
    }

    // xcrun dyld_info -fixup_chains "Path to Binary"
    public func pages(
        of startsInSegment: DyldChainedStartsInSegment?
    ) -> [DyldChainedPage] {
        guard let startsInSegment else { return [] }

        let ptr = fileSlice.ptr
            .advanced(by: startsInSegment.offset)
            .advanced(by: startsInSegment.layoutOffset(of: \.page_start))
            .assumingMemoryBound(to: UInt16.self)
        return UnsafeBufferPointer(
            start: ptr,
            count: numericCast(
                startsInSegment.page_count
            )
        )
        .map {
            isSwapped ? $0.byteSwapped : $0
        }
        .enumerated().map { .init(offset: $1, index: $0) }
    }

    public var imports: [DyldChainedImport] {
        guard let header,
              let  importsFormat = header.importsFormat else {
            return []
        }
        let offset: Int = numericCast(header.imports_offset)
        let ptr = fileSlice.ptr
            .advanced(by: offset)
        let count: Int = numericCast(header.imports_count)

        switch importsFormat {
        case .general:
            return UnsafeBufferPointer(
                start: ptr
                    .assumingMemoryBound(to: DyldChainedImportGeneral.self),
                count: count
            )
            .map { isSwapped ? $0.swapped : $0 }
            .map { .general($0) }

        case .addend:
            return UnsafeBufferPointer(
                start: ptr
                    .assumingMemoryBound(to: DyldChainedImportAddend.self),
                count: count
            )
            .map { isSwapped ? $0.swapped : $0 }
            .map { .addend($0) }

        case .addend64:
            return UnsafeBufferPointer(
                start: ptr
                    .assumingMemoryBound(to: DyldChainedImportAddend64.self),
                count: count
            )
            .map { isSwapped ? $0.swapped : $0 }
            .map { .addend64($0) }
        }
    }

    public func symbolName(for nameOffset: Int) -> String? {
        guard let header else { return nil }
        let ptr = fileSlice.ptr
            .advanced(by: numericCast(header.symbols_offset))
            .advanced(by: nameOffset)
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}

extension MachOFile.DyldChainedFixups {
    // https://github.com/apple-oss-distributions/dyld/blob/d1a0f6869ece370913a3f749617e457f3b4cd7c4/common/MachOLoaded.cpp#L884
    // xcrun dyld_info -fixup_chain_details "Path to Binary"
    // xcrun dyld_info -fixups "Path to Binary"
    public func pointers(
        of startsInSegment: DyldChainedStartsInSegment,
        in machO: MachOFile
    ) -> [DyldChainedFixupPointer] {
        let pages = pages(of: startsInSegment)
        guard pages.count > 0, startsInSegment.page_size > 0 else { return [] }

        let pagesFileSlice = try! machO.fileHandle.fileSlice(
            offset: machO.headerStartOffset + numericCast(startsInSegment.segment_offset),
            length: pages.count * numericCast(startsInSegment.page_size)
        )

        var pointers: [DyldChainedFixupPointer] = []

        for (index, page) in pages.enumerated() {
            var offsetInPage = page.offset

            if page.isNone { continue }
            if page.isMulti {
                var overflowIndex = Int(offsetInPage & ~UInt16(DYLD_CHAINED_PTR_START_MULTI))
                var chainEnd = false
                while !chainEnd {
                    chainEnd = pages[overflowIndex].offset & UInt16(DYLD_CHAINED_PTR_START_LAST) != 0
                    offsetInPage = pages[overflowIndex].offset & ~UInt16(DYLD_CHAINED_PTR_START_LAST)
                    let pageContentStart: Int = index * numericCast(startsInSegment.page_size)
                    let chainOffset = pageContentStart + numericCast(offsetInPage)
                    walkChain(offset: chainOffset, pagesFileSlice: pagesFileSlice, of: startsInSegment, pointers: &pointers)
                    overflowIndex += 1
                }
            } else {
                let pageContentStart: Int = index * numericCast(startsInSegment.page_size)
                let chainOffset = pageContentStart + numericCast(offsetInPage)
                walkChain(offset: chainOffset, pagesFileSlice: pagesFileSlice, of: startsInSegment, pointers: &pointers)
            }
        }

        return pointers
    }

    private func walkChain(
        offset: Int,
        pagesFileSlice: FileSlice,
        of startsInSegment: DyldChainedStartsInSegment,
        pointers: inout [DyldChainedFixupPointer]
    ) {
        guard let pointerFormat = startsInSegment.pointerFormat else {
            return
        }
        var offset = offset

        let stride = pointerFormat.stride
        var stop = false
        var chainEnd = false

        while !stop && !chainEnd {
            guard let fixupInfo = _fixupInfo(
                at: offset,
                in: pagesFileSlice,
                pointerFormat: pointerFormat
            ) else {
                stop = true
                continue
            }

            let pointerOffset = numericCast(startsInSegment.segment_offset) + offset

            pointers.append(
                DyldChainedFixupPointer(
                    offset: pointerOffset,
                    fixupInfo: fixupInfo
                )
            )

            if fixupInfo.next == 0 {
                chainEnd = true
            } else {
                offset += stride * fixupInfo.next
            }
        }
    }
}

extension MachOFile.DyldChainedFixups {
    public func pointer(for offset: UInt64, in machO: MachOFile) -> DyldChainedFixupPointer? {
        guard let startsInImage = startsInImage else { return nil }
        guard let startsInSegment = startsInSegments(of: startsInImage)
            .first(where: {
                let segmentSize = UInt64($0.page_size) * UInt64($0.page_count)
                return $0.segment_offset <= offset && offset < $0.segment_offset + segmentSize
            }) else {
            return nil
        }

        let pages = pages(of: startsInSegment)

        let pagesFileSlice = try! machO.fileHandle.fileSlice(
            offset: machO.headerStartOffset + numericCast(startsInSegment.segment_offset),
            length: pages.count * numericCast(startsInSegment.page_size)
        )

        for (index, page) in pages.enumerated() {
            var offsetInPage = page.offset

            if page.isNone { continue }
            if page.isMulti {
                var overflowIndex = Int(offsetInPage & ~UInt16(DYLD_CHAINED_PTR_START_MULTI))
                var chainEnd = false
                while !chainEnd {
                    chainEnd = pages[overflowIndex].offset & UInt16(DYLD_CHAINED_PTR_START_LAST) != 0
                    offsetInPage = pages[overflowIndex].offset & ~UInt16(DYLD_CHAINED_PTR_START_LAST)
                    let pageContentStart: Int = index * numericCast(startsInSegment.page_size)
                    let chainOffset = pageContentStart + numericCast(offsetInPage)

                    if let pointer = walkChainAndFindPointer(
                        for: offset,
                        chainOffset: chainOffset,
                        pagesFileSlice: pagesFileSlice,
                        of: startsInSegment
                    ) {
                        return pointer
                    }

                    overflowIndex += 1
                }
            } else {
                let pageContentStart: Int = index * numericCast(startsInSegment.page_size)
                let chainOffset = pageContentStart + numericCast(offsetInPage)

                if let pointer = walkChainAndFindPointer(
                    for: offset,
                    chainOffset: chainOffset,
                    pagesFileSlice: pagesFileSlice,
                    of: startsInSegment
                ) {
                    return pointer
                }

            }
        }

        return nil
    }
    private func walkChainAndFindPointer(
        for targetOffset: UInt64,
        chainOffset: Int,
        pagesFileSlice: FileSlice,
        of startsInSegment: DyldChainedStartsInSegment
    ) -> DyldChainedFixupPointer? {
        guard let pointerFormat = startsInSegment.pointerFormat else {
            return nil
        }
        var chainOffset = chainOffset

        let stride = pointerFormat.stride
        var stop = false
        var chainEnd = false

        while !stop && !chainEnd {
            guard let fixupInfo = _fixupInfo(
                at: chainOffset,
                in: pagesFileSlice,
                pointerFormat: pointerFormat
            ) else {
                stop = true
                continue
            }

            let pointerOffset = numericCast(startsInSegment.segment_offset) + chainOffset

            if pointerOffset == targetOffset {
                return DyldChainedFixupPointer(
                    offset: pointerOffset,
                    fixupInfo: fixupInfo
                )
            }

            if fixupInfo.next == 0 {
                chainEnd = true
            } else {
                chainOffset += stride * fixupInfo.next
            }
        }

        return nil
    }
}

extension MachOFile.DyldChainedFixups {
    @inline(__always)
    private func _fixupInfo(
        at offset: Int,
        in pagesFileSlice: FileSlice,
        pointerFormat: DyldChainedFixupPointerFormat
    ) -> DyldChainedFixupPointerInfo? {
        var fixupInfo: DyldChainedFixupPointerInfo?

        if pointerFormat.is64Bit {
//            faster than below code
//            let rawValue = data.advanced(by: offset).withUnsafeBytes {
//                $0.load(as: UInt64.self)
//            }
            guard let rawValue: UInt64 = try? pagesFileSlice.read(
                offset: offset,
                as: UInt64.self
            ) else {
                return nil
            }

            switch pointerFormat {
            case .arm64e, .arm64e_kernel, .arm64e_userland, .arm64e_firmware:
                let content = DyldChainedFixupPointerInfo.ARM64E(rawValue: rawValue)
                switch pointerFormat {
                case .arm64e:
                    fixupInfo = .arm64e(content)
                case .arm64e_kernel:
                    fixupInfo = .arm64e_kernel(content)
                case .arm64e_userland:
                    fixupInfo = .arm64e_userland(content)
                case .arm64e_firmware:
                    fixupInfo = .arm64e_firmware(content)
                default: break
                }

            case .arm64e_userland24:
                let content = DyldChainedFixupPointerInfo.ARM64EUserland24(rawValue: rawValue)
                fixupInfo = .arm64e_userland24(content)

            case ._64, ._64_offset:
                let content = DyldChainedFixupPointerInfo.General64(rawValue: rawValue)
                switch pointerFormat {
                case ._64: fixupInfo = ._64(content)
                case ._64_offset: fixupInfo = ._64_offset(content)
                default: break
                }

            case ._64_kernel_cache, .x86_64_kernel_cache:
                let content = DyldChainedFixupPointerInfo.General64Cache(rawValue: rawValue)
                switch pointerFormat {
                case ._64_kernel_cache:
                    fixupInfo = ._64_kernel_cache(content)
                case .x86_64_kernel_cache:
                    fixupInfo = .x86_64_kernel_cache(content)
                default: break
                }

            case .arm64e_shared_cache:
                let content = DyldChainedFixupPointerInfo.ARM64ESharedCache(rawValue: rawValue)
                fixupInfo = .arm64e_shared_cache(content)

            default:
                break
            }
        } else {
            guard let rawValue: UInt32 = try? pagesFileSlice.read(
                offset: offset
            ) else {
                return nil
            }

            switch pointerFormat {
            case ._32:
                let content = DyldChainedFixupPointerInfo.General32(rawValue: rawValue)
                fixupInfo = ._32(content)
            case ._32_cache:
                let content = DyldChainedFixupPointerInfo.General32Cache(rawValue: rawValue)
                fixupInfo = ._32_cache(content)
            case ._32_firmware:
                let content = DyldChainedFixupPointerInfo.General32Firmware(rawValue: rawValue)
                fixupInfo = ._32_firmware(content)
            default:
                break
            }
        }

        return fixupInfo
    }
}
