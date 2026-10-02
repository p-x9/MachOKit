//
//  MachOImage+CFString.swift
//  MachOKit
//

import Foundation

extension MachOImage {
    public var cfStrings64: MemorySequence<CFString64>? {
        guard let section = sections64.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }
        guard let vmaddrSlide else { return nil }

        guard let ptr = section.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }
        let count = section.size / CFString64.layoutSize

        return .init(
            basePointer: ptr
                .assumingMemoryBound(to: CFString64.self),
            numberOfElements: count
        )
    }

    public var cfStrings32: MemorySequence<CFString32>? {
        guard let section = sections32.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }
        guard let vmaddrSlide else { return nil }

        guard let ptr = section.startPtr(vmaddrSlide: vmaddrSlide) else {
            return nil
        }
        let count = section.size / CFString32.layoutSize

        return .init(
            basePointer: ptr
                .assumingMemoryBound(to: CFString32.self),
            numberOfElements: count
        )
    }
}
