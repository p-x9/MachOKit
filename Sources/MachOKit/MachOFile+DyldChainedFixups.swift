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
internal import FileIOBinary
#else
@_implementationOnly import FileIO
@_implementationOnly import FileIOBinary
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
    private var payload: DyldChainedFixupsPayload {
        .init(bytes: .init(start: fileSlice.ptr, count: fileSlice.size), isSwapped: isSwapped)
    }

    public var header: DyldChainedFixupsHeader? { payload.header }
    public var startsInImage: DyldChainedStartsInImage? { payload.startsInImage }
    public var imports: [DyldChainedImport] { payload.imports }

    public func startsInSegments(
        of startsInImage: DyldChainedStartsInImage?
    ) -> [DyldChainedStartsInSegment] {
        payload.startsInSegments(of: startsInImage)
    }

    public func pages(of startsInSegment: DyldChainedStartsInSegment?) -> [DyldChainedPage] {
        payload.pages(of: startsInSegment)
    }

    public func symbolName(for nameOffset: Int) -> String? {
        payload.symbolName(for: nameOffset)
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
        guard !pages.isEmpty,
              let pagesFileSlice = pagesFileSlice(of: startsInSegment, in: machO) else {
            return []
        }

        var pointers: [DyldChainedFixupPointer] = []
        for page in pages {
            for start in payload.chainStarts(for: page, in: startsInSegment) {
                let chainOffset = page.index * Int(startsInSegment.page_size) + Int(start)
                walkChain(offset: chainOffset, pagesFileSlice: pagesFileSlice, of: startsInSegment, pointers: &pointers)
            }
        }

        return pointers
    }

    private func pagesFileSlice(
        of segment: DyldChainedStartsInSegment,
        in machO: MachOFile
    ) -> FileSlice? {
        guard segment.page_size > 0,
              let segmentOffset = Int(exactly: segment.segment_offset) else {
            return nil
        }
        let (offset, overflow) = machO.headerStartOffset.addingReportingOverflow(segmentOffset)
        let (length, lengthOverflow) = Int(segment.page_count)
            .multipliedReportingOverflow(by: Int(segment.page_size))
        let file = machO.fileHandle
        guard !overflow, !lengthOverflow, offset >= 0, offset < file.size else {
            return nil
        }
        // The final page may be only partially backed by file bytes.
        return try? file.fileSlice(offset: offset, length: min(length, file.size - offset))
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
        let pageSize = Int(startsInSegment.page_size)
        let pageStart = offset / pageSize * pageSize
        let width = pointerFormat.is64Bit ? 8 : 4
        _ = DyldChainedFixupPointer.walkChain(
            startOffset: offset,
            pointerOffsetBias: numericCast(startsInSegment.segment_offset),
            pointerFormat: pointerFormat,
            pointers: &pointers
        ) { offset in
            guard offset - pageStart <= pageSize - width else { return nil }
            return _fixupInfo(
                at: offset,
                in: pagesFileSlice,
                pointerFormat: pointerFormat
            )
        }
    }
}

extension MachOFile.DyldChainedFixups {
    public func pointer(for offset: UInt64, in machO: MachOFile) -> DyldChainedFixupPointer? {
        guard let startsInImage = startsInImage else { return nil }
        guard let startsInSegment = startsInSegments(of: startsInImage)
            .first(where: {
                let segmentSize = UInt64($0.page_size) * UInt64($0.page_count)
                return $0.segment_offset <= offset && offset - $0.segment_offset < segmentSize
            }) else {
            return nil
        }

        let pages = pages(of: startsInSegment)
        let pageSize = Int(startsInSegment.page_size)
        let pageIndex = Int((offset - startsInSegment.segment_offset) / UInt64(pageSize))
        guard pages.indices.contains(pageIndex) else { return nil }
        let page = pages[pageIndex]
        guard !page.isNone,
              let pagesFileSlice = pagesFileSlice(of: startsInSegment, in: machO) else { return nil }

        for start in payload.chainStarts(for: page, in: startsInSegment) {
            let chainOffset = pageIndex * pageSize + Int(start)
            if let pointer = walkChainAndFindPointer(
                for: offset,
                chainOffset: chainOffset,
                pagesFileSlice: pagesFileSlice,
                of: startsInSegment
            ) {
                return pointer
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
        let pageSize = Int(startsInSegment.page_size)
        let pageStart = chainOffset / pageSize * pageSize
        let width = pointerFormat.is64Bit ? 8 : 4
        var stop = false
        var chainEnd = false

        while !stop && !chainEnd {
            guard chainOffset - pageStart <= pageSize - width else { return nil }
            guard let fixupInfo = _fixupInfo(
                at: chainOffset,
                in: pagesFileSlice,
                pointerFormat: pointerFormat
            ) else {
                stop = true
                continue
            }

            let (pointerOffset, overflow) = startsInSegment.segment_offset
                .addingReportingOverflow(UInt64(chainOffset))
            guard !overflow, let resultOffset = Int(exactly: pointerOffset) else { return nil }

            if pointerOffset == targetOffset {
                return DyldChainedFixupPointer(
                    offset: resultOffset,
                    fixupInfo: fixupInfo
                )
            }

            if fixupInfo.next == 0 {
                chainEnd = true
            } else {
                let (nextOffset, overflow) = chainOffset.addingReportingOverflow(stride * fixupInfo.next)
                guard !overflow, nextOffset > chainOffset else { return nil }
                chainOffset = nextOffset
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
        let width = pointerFormat.is64Bit ? 8 : 4
        guard offset >= 0, offset <= pagesFileSlice.size,
              width <= pagesFileSlice.size - offset else { return nil }
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
            return .init(rawValue: rawValue, pointerFormat: pointerFormat)
        } else {
            guard let rawValue: UInt32 = try? pagesFileSlice.read(
                offset: offset
            ) else {
                return nil
            }
            return .init(rawValue: rawValue, pointerFormat: pointerFormat)
        }
    }
}
