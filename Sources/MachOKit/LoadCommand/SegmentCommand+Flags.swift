//
//  SegmentCommand+Flags.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public struct SegmentCommandFlags: BitFlags {
    public typealias RawValue = UInt32

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension SegmentCommandFlags {
    /// SG_HIGHVM
    public static let highvm = SegmentCommandFlags(
        rawValue: Bit.highvm.rawValue
    )
    /// SG_FVMLIB
    public static let fvmlib = SegmentCommandFlags(
        rawValue: Bit.fvmlib.rawValue
    )
    /// SG_NORELOC
    public static let noreloc = SegmentCommandFlags(
        rawValue: Bit.noreloc.rawValue
    )
    /// SG_PROTECTED_VERSION_1
    public static let protected_version_1 = SegmentCommandFlags(
        rawValue: Bit.protected_version_1.rawValue
    )
    /// SG_READ_ONLY
    public static let read_only = SegmentCommandFlags(
        rawValue: Bit.read_only.rawValue
    )
}

extension SegmentCommandFlags {
    public enum Bit: CaseIterable {
        /// SG_HIGHVM
        case highvm
        /// SG_FVMLIB
        case fvmlib
        /// SG_NORELOC
        case noreloc
        /// SG_PROTECTED_VERSION_1
        case protected_version_1
        /// SG_READ_ONLY
        case read_only
    }
}

extension SegmentCommandFlags.Bit: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: UInt32) {
        switch rawValue {
        case RawValue(SG_HIGHVM): self = .highvm
        case RawValue(SG_FVMLIB): self = .fvmlib
        case RawValue(SG_NORELOC): self = .noreloc
        case RawValue(SG_PROTECTED_VERSION_1): self = .protected_version_1
        case RawValue(SG_READ_ONLY): self = .read_only
        default: return nil
        }
    }

    public var rawValue: UInt32 {
        switch self {
        case .highvm: RawValue(SG_HIGHVM)
        case .fvmlib: RawValue(SG_FVMLIB)
        case .noreloc: RawValue(SG_NORELOC)
        case .protected_version_1: RawValue(SG_PROTECTED_VERSION_1)
        case .read_only: RawValue(SG_READ_ONLY)
        }
    }
}

extension SegmentCommandFlags.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .highvm: "SG_HIGHVM"
        case .fvmlib: "SG_FVMLIB"
        case .noreloc: "SG_NORELOC"
        case .protected_version_1: "SG_PROTECTED_VERSION_1"
        case .read_only: "SG_READ_ONLY"
        }
    }
}
