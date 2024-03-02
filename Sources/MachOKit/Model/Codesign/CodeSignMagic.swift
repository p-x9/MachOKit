//
//  CodeSignMagic.swift
//
//
//  Created by p-x9 on 2024/03/03.
//
//

import Foundation
import MachOKitC

public enum CodeSignMagic {
    case requirement
    case requirements
    case codeDirectory
    case embeddedSignature
    case embeddedSignatureOld
    case embeddedEntitlements
    case derEntitlements
    case detachedSignature
    case blobWrapper
    case embeddedLaunchConstraint
}

extension CodeSignMagic: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: UInt32) {
        switch rawValue {
        case CSMAGIC_REQUIREMENT: self = .requirement
        case CSMAGIC_REQUIREMENTS: self = .requirements
        case CSMAGIC_CODEDIRECTORY: self = .codeDirectory
        case CSMAGIC_EMBEDDED_SIGNATURE: self = .embeddedSignature
        case CSMAGIC_EMBEDDED_SIGNATURE_OLD: self = .embeddedSignatureOld
        case CSMAGIC_EMBEDDED_ENTITLEMENTS: self = .embeddedEntitlements
        case CSMAGIC_EMBEDDED_DER_ENTITLEMENTS: self = .derEntitlements
        case CSMAGIC_DETACHED_SIGNATURE: self = .detachedSignature
        case CSMAGIC_BLOBWRAPPER: self = .blobWrapper
        case CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT: self = .embeddedLaunchConstraint
        default:
            return nil
        }
    }

    public var rawValue: UInt32 {
        switch self {
        case .requirement: CSMAGIC_REQUIREMENT
        case .requirements: CSMAGIC_REQUIREMENTS
        case .codeDirectory: CSMAGIC_CODEDIRECTORY
        case .embeddedSignature: CSMAGIC_EMBEDDED_SIGNATURE
        case .embeddedSignatureOld: CSMAGIC_EMBEDDED_SIGNATURE_OLD
        case .embeddedEntitlements: CSMAGIC_EMBEDDED_ENTITLEMENTS
        case .derEntitlements: CSMAGIC_EMBEDDED_DER_ENTITLEMENTS
        case .detachedSignature: CSMAGIC_DETACHED_SIGNATURE
        case .blobWrapper: CSMAGIC_BLOBWRAPPER
        case .embeddedLaunchConstraint: CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT
        }
    }
}

extension CodeSignMagic: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requirement: "CSMAGIC_REQUIREMENT"
        case .requirements: "CSMAGIC_REQUIREMENTS"
        case .codeDirectory: "CSMAGIC_CODEDIRECTORY"
        case .embeddedSignature: "CSMAGIC_EMBEDDED_SIGNATURE"
        case .embeddedSignatureOld: "CSMAGIC_EMBEDDED_SIGNATURE_OLD"
        case .embeddedEntitlements: "CSMAGIC_EMBEDDED_ENTITLEMENTS"
        case .derEntitlements: "CSMAGIC_EMBEDDED_DER_ENTITLEMENTS"
        case .detachedSignature: "CSMAGIC_DETACHED_SIGNATURE"
        case .blobWrapper: "CSMAGIC_BLOBWRAPPER"
        case .embeddedLaunchConstraint: "CSMAGIC_EMBEDDED_LAUNCH_CONSTRAINT"
        }
    }
}
