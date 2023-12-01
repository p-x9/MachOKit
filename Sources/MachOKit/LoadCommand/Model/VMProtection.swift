//
//  VMProtection.swift
//
//
//  Created by p-x9 on 2023/12/01.
//  
//

import Foundation

public struct VMProtection: OptionSet {
    public typealias RawValue = vm_prot_t

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension VMProtection {
    public static let none = VMProtection([])
    public static let read = VMProtection(
        rawValue: Bit.read.rawValue
    )
    public static let write = VMProtection(
        rawValue: Bit.write.rawValue
    )
    public static let execute = VMProtection(
        rawValue: Bit.execute.rawValue
    )
    public static let `default` = VMProtection(
        [.read, .write]
    )
    public static let all = VMProtection(
        [.read, .write, .execute]
    )
    public static let no_change = VMProtection(
        rawValue: Bit.no_change.rawValue
    )
    public static let copy = VMProtection(
        rawValue: Bit.copy.rawValue
    )
    public static let is_mask = VMProtection(
        rawValue: Bit.is_mask.rawValue
    )
    public static let strip_read = VMProtection(
        rawValue: Bit.strip_read.rawValue
    )
    public static let execute_only = VMProtection(
        [.execute, .strip_read]
    )
}

extension VMProtection {
    public var bits: [Bit] {
        VMProtection.Bit.allCases
            .lazy
            .filter {
                contains(.init(rawValue: $0.rawValue))
            }
    }
}

extension VMProtection {
    public enum Bit: CaseIterable {
        case read
        case write
        case execute
        case no_change
        case copy
        case is_mask
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
