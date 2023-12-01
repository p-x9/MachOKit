//
//  Magic.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public enum Magic: CaseIterable, Codable, Equatable {
    case magic
    case cigam

    case magic64
    case cigam64

    case fatMagic
    case fatCigam
}

extension Magic {
    public var isFat: Bool {
        [.fatMagic, .fatCigam].contains(self)
    }

    public var isMach: Bool {
        [.magic, .magic64, .cigam, .cigam64].contains(self)
    }

    public var is64BitMach: Bool {
        [.magic64, .cigam64].contains(self)
    }

    public var isSwapped: Bool {
        [.cigam, .cigam64, .fatCigam].contains(self)
    }
}

extension Magic: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: UInt32) {
        switch rawValue {
        case MH_MAGIC: self = .magic
        case MH_CIGAM: self = .cigam
        case MH_MAGIC_64: self = .magic64
        case MH_CIGAM_64: self = .cigam64
        case FAT_MAGIC: self = .fatMagic
        case FAT_CIGAM: self = .fatCigam
        default: return nil
        }
    }

    public var rawValue: UInt32 {
        switch self {
        case .magic: MH_MAGIC
        case .cigam: MH_CIGAM
        case .magic64: MH_MAGIC_64
        case .cigam64: MH_CIGAM_64
        case .fatMagic: FAT_MAGIC
        case .fatCigam: FAT_CIGAM
        }
    }
}

extension Magic: CustomStringConvertible {
    public var description: String {
        switch self {
        case .magic: "MH_MAGIC"
        case .cigam: "MH_CIGAM"
        case .magic64: "MH_MAGIC_64"
        case .cigam64: "MH_CIGAM_64"
        case .fatMagic: "FAT_MAGIC"
        case .fatCigam: "FAT_CIGAM"
        }
    }
}
