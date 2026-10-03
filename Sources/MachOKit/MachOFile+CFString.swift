//
//  MachOFile+CFString.swift
//  MachOKit
//

import Foundation

extension MachOFile {
    /// Raw constant strings with their unslid record addresses.
    public var cfStrings64: CFStringCollection<CFString64>? {
        guard let section = sections64.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }

        return _cfStrings(in: section, makeValue: { CFString64(layout: $0, address: $1) })
    }

    /// Raw constant strings with their unslid record addresses.
    public var cfStrings32: CFStringCollection<CFString32>? {
        guard let section = sections32.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }
        return _cfStrings(in: section, makeValue: { CFString32(layout: $0, address: $1) })
    }

    private func _cfStrings<Value: LayoutWrapper & CFStringProtocol>(
        in section: any SectionProtocol,
        makeValue: @escaping (Value.Layout, UInt64) -> Value
    ) -> CFStringCollection<Value>? {
        guard let data = section.data(in: self) else { return nil }
        return .init(data: data, address: numericCast(section.address), makeValue: makeValue)
    }
}
