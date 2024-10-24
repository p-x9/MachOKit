//
//  VMProtection.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public struct VMProtection: BitFlags {
    public typealias RawValue = vm_prot_t

    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension VMProtection {
    /// VM_PROT_NONE
    public static let none = VMProtection([])
    /// VM_PROT_READ
    public static let read = VMProtection(
        rawValue: Bit.read.rawValue
    )
    /// VM_PROT_WRITE
    public static let write = VMProtection(
        rawValue: Bit.write.rawValue
    )
    /// VM_PROT_EXECUTE
    public static let execute = VMProtection(
        rawValue: Bit.execute.rawValue
    )
    /// VM_PROT_DEFAULT
    public static let `default` = VMProtection(
        [.read, .write]
    )
    /// VM_PROT_ALL
    public static let all = VMProtection(
        [.read, .write, .execute]
    )
    /// VM_PROT_NO_CHANGE
    public static let no_change = VMProtection(
        rawValue: Bit.no_change.rawValue
    )
    /// VM_PROT_COPY
    public static let copy = VMProtection(
        rawValue: Bit.copy.rawValue
    )
    /// VM_PROT_IS_MASK
    public static let is_mask = VMProtection(
        rawValue: Bit.is_mask.rawValue
    )
    /// VM_PROT_STRIP_READ
    public static let strip_read = VMProtection(
        rawValue: Bit.strip_read.rawValue
    )
    /// VM_PROT_EXECUTE_ONLY
    public static let execute_only = VMProtection(
        [.execute, .strip_read]
    )
}

extension VMProtection {
    public enum Bit: CaseIterable {
        /// VM_PROT_READ
        case read
        /// VM_PROT_WRITE
        case write
        /// VM_PROT_EXECUTE
        case execute
        /// VM_PROT_NO_CHANGE
        case no_change
        /// VM_PROT_COPY
        case copy
        /// VM_PROT_IS_MASK
        case is_mask
        /// VM_PROT_STRIP_READ
        case strip_read
    }
}

extension VMProtection.Bit: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(VM_PROT_READ): self = .read
        case RawValue(VM_PROT_WRITE): self = .write
        case RawValue(VM_PROT_EXECUTE): self = .execute
        case RawValue(VM_PROT_NO_CHANGE): self = .no_change
        case RawValue(VM_PROT_COPY): self = .copy
        case RawValue(VM_PROT_IS_MASK): self = .is_mask
        case RawValue(VM_PROT_STRIP_READ): self = .strip_read
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .read: RawValue(VM_PROT_READ)
        case .write: RawValue(VM_PROT_WRITE)
        case .execute: RawValue(VM_PROT_EXECUTE)
        case .no_change: RawValue(VM_PROT_NO_CHANGE)
        case .copy: RawValue(VM_PROT_COPY)
        case .is_mask: RawValue(VM_PROT_IS_MASK)
        case .strip_read: RawValue(VM_PROT_STRIP_READ)
        }
    }
}

extension VMProtection.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .read: "VM_PROT_READ"
        case .write: "VM_PROT_WRITE"
        case .execute: "VM_PROT_EXECUTE"
        case .no_change: "VM_PROT_NO_CHANGE"
        case .copy: "VM_PROT_COPY"
        case .is_mask: "VM_PROT_IS_MASK"
        case .strip_read: "VM_PROT_STRIP_READ"
        }
    }
}
