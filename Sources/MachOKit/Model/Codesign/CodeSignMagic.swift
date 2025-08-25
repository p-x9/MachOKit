//
//  CodeSignMagic.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

public enum CodeSignMagic: Sendable {
    /// CSMAGIC_REQUIREMENT
    case requirement
    /// CSMAGIC_REQUIREMENTS
    case requirements
    /// CSMAGIC_CODEDIRECTORY
    case codedirectory
    /// CSMAGIC_EMBEDDED_SIGNATURE
    case embedded_signature
    /// CSMAGIC_EMBEDDED_SIGNATURE_OLD
    case embedded_signature_old
    /// CSMAGIC_EMBEDDED_ENTITLEMENTS
    case embedded_entitlements
    /// CSMAGIC_EMBEDDED_DER_ENTITLEMENTS
    case embedded_der_entitlements
    /// CSMAGIC_DETACHED_SIGNATURE
    case detached_signature
    /// CSMAGIC_BLOBWRAPPER
    case blobwrapper
    /// CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT
    case embedded_launch_constraint
}

extension CodeSignMagic: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(CSMAGIC_REQUIREMENT): self = .requirement
        case RawValue(CSMAGIC_REQUIREMENTS): self = .requirements
        case RawValue(CSMAGIC_CODEDIRECTORY): self = .codedirectory
        case RawValue(CSMAGIC_EMBEDDED_SIGNATURE): self = .embedded_signature
        case RawValue(CSMAGIC_EMBEDDED_SIGNATURE_OLD): self = .embedded_signature_old
        case RawValue(CSMAGIC_EMBEDDED_ENTITLEMENTS): self = .embedded_entitlements
        case RawValue(CSMAGIC_EMBEDDED_DER_ENTITLEMENTS): self = .embedded_der_entitlements
        case RawValue(CSMAGIC_DETACHED_SIGNATURE): self = .detached_signature
        case RawValue(CSMAGIC_BLOBWRAPPER): self = .blobwrapper
        case RawValue(CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT): self = .embedded_launch_constraint
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .requirement: RawValue(CSMAGIC_REQUIREMENT)
        case .requirements: RawValue(CSMAGIC_REQUIREMENTS)
        case .codedirectory: RawValue(CSMAGIC_CODEDIRECTORY)
        case .embedded_signature: RawValue(CSMAGIC_EMBEDDED_SIGNATURE)
        case .embedded_signature_old: RawValue(CSMAGIC_EMBEDDED_SIGNATURE_OLD)
        case .embedded_entitlements: RawValue(CSMAGIC_EMBEDDED_ENTITLEMENTS)
        case .embedded_der_entitlements: RawValue(CSMAGIC_EMBEDDED_DER_ENTITLEMENTS)
        case .detached_signature: RawValue(CSMAGIC_DETACHED_SIGNATURE)
        case .blobwrapper: RawValue(CSMAGIC_BLOBWRAPPER)
        case .embedded_launch_constraint: RawValue(CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT)
        }
    }
}

extension CodeSignMagic: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requirement: "CSMAGIC_REQUIREMENT"
        case .requirements: "CSMAGIC_REQUIREMENTS"
        case .codedirectory: "CSMAGIC_CODEDIRECTORY"
        case .embedded_signature: "CSMAGIC_EMBEDDED_SIGNATURE"
        case .embedded_signature_old: "CSMAGIC_EMBEDDED_SIGNATURE_OLD"
        case .embedded_entitlements: "CSMAGIC_EMBEDDED_ENTITLEMENTS"
        case .embedded_der_entitlements: "CSMAGIC_EMBEDDED_DER_ENTITLEMENTS"
        case .detached_signature: "CSMAGIC_DETACHED_SIGNATURE"
        case .blobwrapper: "CSMAGIC_BLOBWRAPPER"
        case .embedded_launch_constraint: "CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT"
        }
    }
}
