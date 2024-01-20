//
//  SymbolDescription.swift
//  
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public struct SymbolDescription: BitFlags {
    public typealias RawValue = Int32

    public let rawValue: RawValue

    public var referenceFlag: SymbolReferenceFlag? {
        .init(rawValue: rawValue & REFERENCE_TYPE)
    }

    /// When included in indices, you can retrieve library information as follows
    /// 
    /// ```swift
    /// machO.dependencies[libraryOrdinal - 1]
    /// ```
    public var libraryOrdinal: Int32 {
        (rawValue >> 8) & 0xff
    }

    public var libraryOrdinalType: SymbolLibraryOrdinalType? {
        .init(rawValue: libraryOrdinal)
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension SymbolDescription {
    /// REFERENCED_DYNAMICALLY
    public static let referenced_dynamically = SymbolDescription(
        rawValue: Bit.referenced_dynamically.rawValue
    )
    /// N_NO_DEAD_STRIP
    public static let no_dead_strip = SymbolDescription(
        rawValue: Bit.no_dead_strip.rawValue
    )
    /// N_DESC_DISCARDED
    public static let desc_discarded = SymbolDescription(
        rawValue: Bit.desc_discarded.rawValue
    )
    /// N_WEAK_REF
    public static let weak_ref = SymbolDescription(
        rawValue: Bit.weak_ref.rawValue
    )
    /// N_WEAK_DEF
    public static let weak_def = SymbolDescription(
        rawValue: Bit.weak_def.rawValue
    )
    /// N_REF_TO_WEAK
    public static let ref_to_weak = SymbolDescription(
        rawValue: Bit.ref_to_weak.rawValue
    )
    /// N_ARM_THUMB_DEF
    public static let arm_thumb_def = SymbolDescription(
        rawValue: Bit.arm_thumb_def.rawValue
    )
    /// N_SYMBOL_RESOLVER
    public static let symbol_resolver = SymbolDescription(
        rawValue: Bit.symbol_resolver.rawValue
    )
    /// N_ALT_ENTRY
    public static let alt_entry = SymbolDescription(
        rawValue: Bit.alt_entry.rawValue
    )
    /// N_COLD_FUNC
    public static let cold_func = SymbolDescription(
        rawValue: Bit.cold_func.rawValue
    )
}

extension SymbolDescription {
    public enum Bit: CaseIterable {
        /// REFERENCED_DYNAMICALLY
        case referenced_dynamically
        /// N_NO_DEAD_STRIP
        case no_dead_strip
        /// N_DESC_DISCARDED
        case desc_discarded
        /// N_WEAK_REF
        case weak_ref
        /// N_WEAK_DEF
        case weak_def
        /// N_REF_TO_WEAK
        case ref_to_weak
        /// N_ARM_THUMB_DEF
        case arm_thumb_def
        /// N_SYMBOL_RESOLVER
        case symbol_resolver
        /// N_ALT_ENTRY
        case alt_entry
        /// N_COLD_FUNC
        case cold_func
    }
}

extension SymbolDescription.Bit: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(REFERENCED_DYNAMICALLY): self = .referenced_dynamically
        case RawValue(N_NO_DEAD_STRIP): self = .no_dead_strip
        case RawValue(N_DESC_DISCARDED): self = .desc_discarded
        case RawValue(N_WEAK_REF): self = .weak_ref
        case RawValue(N_WEAK_DEF): self = .weak_def
        case RawValue(N_REF_TO_WEAK): self = .ref_to_weak
        case RawValue(N_ARM_THUMB_DEF): self = .arm_thumb_def
        case RawValue(N_SYMBOL_RESOLVER): self = .symbol_resolver
        case RawValue(N_ALT_ENTRY): self = .alt_entry
        case RawValue(N_COLD_FUNC): self = .cold_func
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .referenced_dynamically: RawValue(REFERENCED_DYNAMICALLY)
        case .no_dead_strip: RawValue(N_NO_DEAD_STRIP)
        case .desc_discarded: RawValue(N_DESC_DISCARDED)
        case .weak_ref: RawValue(N_WEAK_REF)
        case .weak_def: RawValue(N_WEAK_DEF)
        case .ref_to_weak: RawValue(N_REF_TO_WEAK)
        case .arm_thumb_def: RawValue(N_ARM_THUMB_DEF)
        case .symbol_resolver: RawValue(N_SYMBOL_RESOLVER)
        case .alt_entry: RawValue(N_ALT_ENTRY)
        case .cold_func: RawValue(N_COLD_FUNC)
        }
    }
}

extension SymbolDescription.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .referenced_dynamically: "REFERENCED_DYNAMICALLY"
        case .no_dead_strip: "N_NO_DEAD_STRIP"
        case .desc_discarded: "N_DESC_DISCARDED"
        case .weak_ref: "N_WEAK_REF"
        case .weak_def: "N_WEAK_DEF"
        case .ref_to_weak: "N_REF_TO_WEAK"
        case .arm_thumb_def: "N_ARM_THUMB_DEF"
        case .symbol_resolver: "N_SYMBOL_RESOLVER"
        case .alt_entry: "N_ALT_ENTRY"
        case .cold_func: "N_COLD_FUNC"
        }
    }
}
