//
//  Section+Stubs.swift
//  MachOKit
//

import Foundation

extension SectionProtocol {
    public func stubs(in machO: MachOImage) -> [Stub]? {
        guard let data = data(in: machO) else { return nil }
        return _stubs(data: data, cpuType: machO.header.cpuType)
    }

    public func stubs(in machO: MachOFile) -> [Stub]? {
        guard let data = data(in: machO) else { return nil }
        return _stubs(data: data, cpuType: machO.header.cpuType)
    }

    public func objcStubs(
        in machO: MachOImage
    ) -> [ObjCStub]? {
        guard let data = data(in: machO) else { return nil }
        return _objcStubs(data: data, cpuType: machO.header.cpuType)
    }

    public func objcStubs(
        in machO: MachOFile
    ) -> [ObjCStub]? {
        guard let data = data(in: machO) else { return nil }
        return _objcStubs(data: data, cpuType: machO.header.cpuType)
    }
}

extension SectionProtocol {
    private func _stubs(
        data: Data,
        cpuType: CPUType?
    ) -> [Stub]? {
        guard flags.type == .symbol_stubs,
              let stubSize,
              stubSize > 0,
              size >= 0,
              size.isMultiple(of: stubSize),
              data.count == size,
              let sectionAddress = UInt64(exactly: address),
              !sectionAddress.addingReportingOverflow(UInt64(size)).overflow,
              let indirectSymbolIndex else {
            return nil
        }

        return stride(from: 0, to: data.count, by: stubSize).enumerated().map { index, offset in
            let address = sectionAddress + UInt64(offset)
            let bytes = data.subdata(in: offset ..< offset + stubSize)
            return Stub(
                address: address,
                size: stubSize,
                indirectSymbolIndex: indirectSymbolIndex + index,
                branch: StubDecoder.decode(
                    bytes,
                    address: address,
                    cpuType: cpuType
                )
            )
        }
    }

    private func _objcStubs(
        data: Data,
        cpuType: CPUType?
    ) -> [ObjCStub]? {
        let stubSize = StubDecoder.objcStubSize
        guard cpuType == .arm64,
              sectionName == "__objc_stubs",
              size >= 0,
              size.isMultiple(of: stubSize),
              data.count == size,
              let sectionAddress = UInt64(exactly: address),
              !sectionAddress.addingReportingOverflow(UInt64(size)).overflow else {
            return nil
        }

        var result: [ObjCStub] = []
        result.reserveCapacity(data.count / stubSize)
        for offset in stride(from: 0, to: data.count, by: stubSize) {
            let address = sectionAddress + UInt64(offset)
            let bytes = data.subdata(in: offset ..< offset + stubSize)
            guard let selectorReference = StubDecoder.selectorReference(
                in: bytes,
                stubAddress: address
            ) else {
                return nil
            }
            let branchBytes = bytes.subdata(in: 8 ..< bytes.count)
            result.append(.init(
                stub: .init(
                    address: address,
                    size: stubSize,
                    indirectSymbolIndex: nil,
                    branch: StubDecoder.decode(
                        branchBytes,
                        address: address + 8,
                        cpuType: cpuType
                    )
                ),
                selectorReference: selectorReference
            ))
        }
        return result
    }
}
