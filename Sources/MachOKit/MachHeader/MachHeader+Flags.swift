//
//  MachHeader+Flags.swift
//
//
//  Created by p-x9 on 2023/11/29.
//
//

import Foundation

extension MachHeader {
    public struct Flags: OptionSet {
        public typealias RawValue = UInt32

        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension MachHeader.Flags {
    public static let noundefs = MachHeader.Flags(
        rawValue: Bit.noundefs.rawValue
    )
    public static let incrlink = MachHeader.Flags(
        rawValue: Bit.incrlink.rawValue
    )
    public static let dyldlink = MachHeader.Flags(
        rawValue: Bit.dyldlink.rawValue
    )
    public static let bindatload = MachHeader.Flags(
        rawValue: Bit.bindatload.rawValue
    )
    public static let prebound = MachHeader.Flags(
        rawValue: Bit.prebound.rawValue
    )
    public static let split_segs = MachHeader.Flags(
        rawValue: Bit.split_segs.rawValue
    )
    public static let lazy_init = MachHeader.Flags(
        rawValue: Bit.lazy_init.rawValue
    )
    public static let twolevel = MachHeader.Flags(
        rawValue: Bit.twolevel.rawValue
    )
    public static let force_flat = MachHeader.Flags(
        rawValue: Bit.force_flat.rawValue
    )
    public static let nomultidefs = MachHeader.Flags(
        rawValue: Bit.nomultidefs.rawValue
    )
}

extension MachHeader.Flags {
    public var bits: [Bit] {
        MachHeader.Flags.Bit.allCases
            .lazy
            .filter {
                contains(.init(rawValue: $0.rawValue))
            }
    }
}
