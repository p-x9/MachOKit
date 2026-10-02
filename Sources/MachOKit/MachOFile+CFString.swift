//
//  MachOFile+CFString.swift
//  MachOKit
//

import Foundation

extension MachOFile {
    public var cfStrings64: DataSequence<CFString64>? {
        guard let section = sections64.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }

        let offset = headerStartOffset + section.offset
        let count = section.size / CFString64.layoutSize

        return fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: count
        )
    }

    public var cfStrings32: DataSequence<CFString32>? {
        guard let section = sections32.first(where: {
            $0.sectionName == "__cfstring"
        }) else { return nil }

        let offset = headerStartOffset + section.offset
        let count = section.size / CFString32.layoutSize

        return fileHandle.readDataSequence(
            offset: numericCast(offset),
            numberOfElements: count
        )
    }
}
