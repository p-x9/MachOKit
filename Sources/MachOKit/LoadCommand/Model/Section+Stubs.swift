//
//  Section+Stubs.swift
//  MachOKit
//

import Foundation

extension SectionProtocol {
    public func stubs(in machO: MachOImage) -> StubCollection? {
        guard let data = data(in: machO) else { return nil }
        return _stubs(data: data, cpuType: machO.header.cpuType)
    }

    public func stubs(in machO: MachOFile) -> StubCollection? {
        guard let data = data(in: machO) else { return nil }
        return _stubs(data: data, cpuType: machO.header.cpuType)
    }

    public func objcStubs(
        in machO: MachOImage
    ) -> ObjCStubCollection? {
        guard let data = data(in: machO) else { return nil }
        return _objcStubs(data: data, cpuType: machO.header.cpuType)
    }

    public func objcStubs(
        in machO: MachOFile
    ) -> ObjCStubCollection? {
        guard let data = data(in: machO) else { return nil }
        return _objcStubs(data: data, cpuType: machO.header.cpuType)
    }
}

extension SectionProtocol {
    private func _stubs(
        data: Data,
        cpuType: CPUType?
    ) -> StubCollection? {
        guard flags.type == .symbol_stubs,
              let stubSize,
              stubSize > 0,
              size >= 0,
              data.count == size,
              let sectionAddress = UInt64(exactly: address),
              !sectionAddress.addingReportingOverflow(UInt64(size)).overflow,
              let indirectSymbolIndex else {
            return nil
        }

        return .init(
            rawData: data,
            address: sectionAddress,
            entrySize: stubSize,
            indirectSymbolIndex: indirectSymbolIndex,
            cpuType: cpuType
        )
    }

    private func _objcStubs(
        data: Data,
        cpuType: CPUType?
    ) -> ObjCStubCollection? {
        guard sectionName == "__objc_stubs",
              size >= 0,
              data.count == size,
              let sectionAddress = UInt64(exactly: address),
              !sectionAddress.addingReportingOverflow(UInt64(size)).overflow else {
            return nil
        }
        return .init(
            rawData: data,
            address: sectionAddress,
            layout: StubDecoder.objcStubLayout(in: data, cpuType: cpuType),
            cpuType: cpuType
        )
    }
}
