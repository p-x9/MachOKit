//
//  CodeSignMagic.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

public enum CodeSignMagic: UInt32 {
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
