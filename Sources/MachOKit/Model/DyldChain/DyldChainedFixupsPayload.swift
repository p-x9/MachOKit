import MachOKitC

/// Bounds metadata reads to the LC_DYLD_CHAINED_FIXUPS payload.
struct DyldChainedFixupsPayload {
    let bytes: UnsafeRawBufferPointer
    let isSwapped: Bool
}

extension DyldChainedFixupsPayload {
    var header: DyldChainedFixupsHeader? {
        guard let layout = read(DyldChainedFixupsHeader.Layout.self, at: 0) else { return nil }
        let result = DyldChainedFixupsHeader(layout: layout)
        return isSwapped ? result.swapped : result
    }

    var startsInImage: DyldChainedStartsInImage? {
        guard let header else { return nil }
        guard let offset = Int(exactly: header.starts_offset),
              let layout = read(DyldChainedStartsInImage.Layout.self, at: offset) else { return nil }
        let result = DyldChainedStartsInImage(layout: layout, offset: offset)
        return isSwapped ? result.swapped : result
    }

    func startsInSegments(of startsInImage: DyldChainedStartsInImage?) -> [DyldChainedStartsInSegment] {
        guard let startsInImage else { return [] }
        let tableOffset = DyldChainedStartsInImage.layoutOffset(of: \.seg_info_offset)
        guard let count = Int(exactly: startsInImage.seg_count),
              contains(offset: startsInImage.offset, length: tableOffset) else {
                return []
        }
        let offsets = read(UInt32.self, at: startsInImage.offset + tableOffset, count: count)
        return offsets.enumerated().compactMap { index, rawOffset in
            guard let relativeOffset = Int(exactly: isSwapped ? rawOffset.byteSwapped : rawOffset) else {
                return nil
            }
            if relativeOffset == 0 {
                return .init(layout: .init(), offset: startsInImage.offset, segmentIndex: index)
            }

            let (offset, overflow) = startsInImage.offset.addingReportingOverflow(relativeOffset)
            guard !overflow,
                  let layout = read(DyldChainedStartsInSegment.Layout.self, at: offset) else { return nil }

            let result = DyldChainedStartsInSegment(layout: layout, offset: offset, segmentIndex: index)
            return isSwapped ? result.swapped : result
        }
    }

    func pages(of segment: DyldChainedStartsInSegment?) -> [DyldChainedPage] {
        guard let segment else { return [] }
        guard let range = pageStartRange(of: segment) else { return [] }
        return read(UInt16.self, at: range.lowerBound, count: Int(segment.page_count))
            .enumerated()
            .map { .init(offset: isSwapped ? $1.byteSwapped : $1, index: $0) }
    }

    func chainStarts(for page: DyldChainedPage, in segment: DyldChainedStartsInSegment) -> [Int] {
        guard !page.isNone else { return [] }
        guard page.isMulti else {
            return page.offset < segment.page_size ? [Int(page.offset)] : []
        }
        guard let range = pageStartRange(of: segment) else { return [] }

        // dyld indexes the combined page_start and overflow entries.
        let last = UInt16(DYLD_CHAINED_PTR_START_LAST)
        let index = Int(page.offset & ~UInt16(DYLD_CHAINED_PTR_START_MULTI))

        guard index >= Int(segment.page_count), index < range.count / 2 else { return [] }

        var starts: [Int] = []
        for offset in stride(from: range.lowerBound + index * 2, to: range.upperBound, by: 2) {
            let raw = bytes.loadUnaligned(fromByteOffset: offset, as: UInt16.self)
            let entry = isSwapped ? raw.byteSwapped : raw
            let start = entry & ~last
            guard start < segment.page_size else { return [] }
            starts.append(Int(start))
            if entry & last != 0 { return starts }
        }
        return []
    }

    var imports: [DyldChainedImport] {
        guard let header,
              let format = header.importsFormat,
              let offset = Int(exactly: header.imports_offset),
              let count = Int(exactly: header.imports_count) else {
            return []
        }
        switch format {
        case .general:
            return read(DyldChainedImportGeneral.self, at: offset, count: count)
                .map { .general(isSwapped ? $0.swapped : $0) }
        case .addend:
            return read(DyldChainedImportAddend.self, at: offset, count: count)
                .map { .addend(isSwapped ? $0.swapped : $0) }
        case .addend64:
            return read(DyldChainedImportAddend64.self, at: offset, count: count)
                .map { .addend64(isSwapped ? $0.swapped : $0) }
        }
    }

    func symbolName(for nameOffset: Int) -> String? {
        guard let header else { return nil }
        guard let base = Int(exactly: header.symbols_offset),
              nameOffset >= 0 else {
            return nil
        }
        let (offset, overflow) = base.addingReportingOverflow(nameOffset)
        guard !overflow, contains(offset: offset, length: 1),
              let end = bytes[offset...].firstIndex(of: 0) else { return nil }
        return String(decoding: bytes[offset ..< end], as: UTF8.self)
    }
}

extension DyldChainedFixupsPayload {
    private func pageStartRange(of segment: DyldChainedStartsInSegment) -> Range<Int>? {
        let fixedSize = DyldChainedStartsInSegment.layoutOffset(of: \.page_start)
        guard let size = Int(exactly: segment.size),
              size >= fixedSize + 2 * Int(segment.page_count),
              contains(offset: segment.offset, length: size) else { return nil }
        let start = segment.offset + fixedSize
        let end = segment.offset + size
        return start ..< end - (end - start) % 2
    }
}

extension DyldChainedFixupsPayload {
    private func contains(offset: Int, length: Int) -> Bool {
        offset >= 0 && offset <= bytes.count && length >= 0 && length <= bytes.count - offset
    }

    private func read<T>(_ type: T.Type, at offset: Int) -> T? {
        guard contains(offset: offset, length: MemoryLayout<T>.size) else { return nil }
        return bytes.loadUnaligned(fromByteOffset: offset, as: type)
    }

    private func read<T>(_ type: T.Type, at offset: Int, count: Int) -> [T] {
        let stride = MemoryLayout<T>.stride
        let (length, overflow) = count.multipliedReportingOverflow(by: stride)
        guard !overflow, contains(offset: offset, length: length) else { return [] }
        return (0 ..< count).map {
            bytes.loadUnaligned(fromByteOffset: offset + $0 * stride, as: type)
        }
    }
}
