//
//  Section+Data.swift
//  MachOKit
//

import Foundation

extension SectionProtocol {
    /// Returns the file-backed contents of this section.
    ///
    /// Sections without file-backed storage, such as `S_ZEROFILL` sections,
    /// return `nil`.
    @_spi(Support)
    public func data(in machO: MachOFile) -> Data? {
        guard size >= 0,
              offset >= 0,
              let address = UInt64(exactly: address),
              let sectionSize = UInt64(exactly: size) else {
            return nil
        }
        let (addressEnd, addressOverflow) = address.addingReportingOverflow(sectionSize)
        guard !addressOverflow,
              machO.segments.contains(where: { segment in
                  guard let range = segment.fileBackedVirtualMemoryRange else {
                      return false
                  }
                  return range.lowerBound <= address && addressEnd <= range.upperBound
              }) else {
            return nil
        }

        let fileOffset: UInt64
        if machO.isLoadedFromDyldCache {
            guard let cache = machO.cache,
                  let located = try? cache.locateValue({ $0.fileOffset(of: address) }),
                  let offset = Int(exactly: located.value) else {
                return nil
            }
            return try? located.cache.fileHandle.readData(offset: offset, length: size)
        } else {
            guard machO.headerStartOffset >= 0 else { return nil }
            let (resolvedOffset, overflow) = UInt64(offset).addingReportingOverflow(
                UInt64(machO.headerStartOffset)
            )
            guard !overflow else { return nil }
            fileOffset = resolvedOffset
        }

        guard let offset = Int(exactly: fileOffset) else { return nil }
        return try? machO.fileHandle.readData(offset: offset, length: size)
    }

    /// Returns the mapped in-memory contents of this section.
    @_spi(Support)
    public func data(in machO: MachOImage) -> Data? {
        guard size >= 0,
              let address = UInt64(exactly: address),
              let sectionSize = UInt64(exactly: size) else {
            return nil
        }
        let (addressEnd, addressOverflow) = address.addingReportingOverflow(sectionSize)
        guard !addressOverflow,
              machO.segments.contains(where: { segment in
                  guard let range = segment.virtualMemoryRange else {
                      return false
                  }
                  return range.lowerBound <= address && addressEnd <= range.upperBound
              }),
              let vmaddrSlide = machO.vmaddrSlide else {
            return nil
        }
        let (runtimeAddress, runtimeOverflow) = self.address.addingReportingOverflow(vmaddrSlide)
        guard !runtimeOverflow,
              let pointer = UnsafeRawPointer(bitPattern: runtimeAddress) else {
            return nil
        }
        return Data(bytes: pointer, count: size)
    }
}
