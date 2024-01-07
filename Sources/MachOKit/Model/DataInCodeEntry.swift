//
//  DataInCodeEntry.swift
//
//
//  Created by p-x9 on 2024/01/07.
//  
//

import Foundation

public struct DataInCodeEntry: LayoutWrapper {
    public typealias Layout = data_in_code_entry
    public var layout: Layout
}

extension DataInCodeEntry {
    public var kind: Kind? {
        .init(rawValue: numericCast(layout.kind))
    }
}

extension DataInCodeEntry {
    public enum Kind {
        case data
        case jumpTable8
        case jumpTable16
        case jumpTable32
        case absJumpTable32
    }
}

extension DataInCodeEntry.Kind: RawRepresentable {
    public typealias RawValue = Int32

    public var rawValue: RawValue {
        switch self {
        case .data: DICE_KIND_DATA
        case .jumpTable8: DICE_KIND_JUMP_TABLE8
        case .jumpTable16: DICE_KIND_JUMP_TABLE16
        case .jumpTable32: DICE_KIND_JUMP_TABLE32
        case .absJumpTable32: DICE_KIND_ABS_JUMP_TABLE32
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case DICE_KIND_DATA: self = .data
        case DICE_KIND_JUMP_TABLE8: self = .jumpTable8
        case DICE_KIND_JUMP_TABLE16: self = .jumpTable16
        case DICE_KIND_JUMP_TABLE32: self = .jumpTable32
        case DICE_KIND_ABS_JUMP_TABLE32: self = .absJumpTable32
        default: return nil
        }
    }
}

extension DataInCodeEntry.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .data: "DICE_KIND_DATA"
        case .jumpTable8: "DICE_KIND_JUMP_TABLE8"
        case .jumpTable16: "DICE_KIND_JUMP_TABLE16"
        case .jumpTable32: "DICE_KIND_JUMP_TABLE32"
        case .absJumpTable32: "DICE_KIND_ABS_JUMP_TABLE32"
        }
    }
}
