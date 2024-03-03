//
//  CodeSignSlot.swift
//
//
//  Created by p-x9 on 2024/03/03.
//  
//

import Foundation
import MachOKitC

public enum CodeSignSlot {
    /// CSSLOT_CODEDIRECTORY
    case codedirectory
    /// CSSLOT_INFOSLOT
    case infoslot
    /// CSSLOT_REQUIREMENTS
    case requirements
    /// CSSLOT_RESOURCEDIR
    case resourcedir
    /// CSSLOT_APPLICATION
    case application
    /// CSSLOT_ENTITLEMENTS
    case entitlements
    /// CSSLOT_DER_ENTITLEMENTS
    case der_entitlements
    /// CSSLOT_LAUNCH_CONSTRAINT_SELF
    case launch_constraint_self
    /// CSSLOT_LAUNCH_CONSTRAINT_PARENT
    case launch_constraint_parent
    /// CSSLOT_LAUNCH_CONSTRAINT_RESPONSIBLE
    case launch_constraint_responsible
    /// CSSLOT_LIBRARY_CONSTRAINT
    case library_constraint
    /// CSSLOT_ALTERNATE_CODEDIRECTORIES
    case alternate_codedirectories
    /// CSSLOT_ALTERNATE_CODEDIRECTORY_MAX
    case alternate_codedirectory_max
    /// CSSLOT_ALTERNATE_CODEDIRECTORY_LIMIT
    case alternate_codedirectory_limit
    /// CSSLOT_SIGNATURESLOT
    case signatureslot
    /// CSSLOT_IDENTIFICATIONSLOT
    case identificationslot
    /// CSSLOT_TICKETSLOT
    case ticketslot
}

extension CodeSignSlot: RawRepresentable {
    public typealias RawValue = UInt32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(CSSLOT_CODEDIRECTORY): self = .codedirectory
        case RawValue(CSSLOT_INFOSLOT): self = .infoslot
        case RawValue(CSSLOT_REQUIREMENTS): self = .requirements
        case RawValue(CSSLOT_RESOURCEDIR): self = .resourcedir
        case RawValue(CSSLOT_APPLICATION): self = .application
        case RawValue(CSSLOT_ENTITLEMENTS): self = .entitlements
        case RawValue(CSSLOT_DER_ENTITLEMENTS): self = .der_entitlements
        case RawValue(CSSLOT_LAUNCH_CONSTRAINT_SELF): self = .launch_constraint_self
        case RawValue(CSSLOT_LAUNCH_CONSTRAINT_PARENT): self = .launch_constraint_parent
        case RawValue(CSSLOT_LAUNCH_CONSTRAINT_RESPONSIBLE): self = .launch_constraint_responsible
        case RawValue(CSSLOT_LIBRARY_CONSTRAINT): self = .library_constraint
        case RawValue(CSSLOT_ALTERNATE_CODEDIRECTORIES): self = .alternate_codedirectories
        case RawValue(CSSLOT_ALTERNATE_CODEDIRECTORY_MAX): self = .alternate_codedirectory_max
        case RawValue(CSSLOT_ALTERNATE_CODEDIRECTORY_LIMIT): self = .alternate_codedirectory_limit
        case RawValue(CSSLOT_SIGNATURESLOT): self = .signatureslot
        case RawValue(CSSLOT_IDENTIFICATIONSLOT): self = .identificationslot
        case RawValue(CSSLOT_TICKETSLOT): self = .ticketslot
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .codedirectory: RawValue(CSSLOT_CODEDIRECTORY)
        case .infoslot: RawValue(CSSLOT_INFOSLOT)
        case .requirements: RawValue(CSSLOT_REQUIREMENTS)
        case .resourcedir: RawValue(CSSLOT_RESOURCEDIR)
        case .application: RawValue(CSSLOT_APPLICATION)
        case .entitlements: RawValue(CSSLOT_ENTITLEMENTS)
        case .der_entitlements: RawValue(CSSLOT_DER_ENTITLEMENTS)
        case .launch_constraint_self: RawValue(CSSLOT_LAUNCH_CONSTRAINT_SELF)
        case .launch_constraint_parent: RawValue(CSSLOT_LAUNCH_CONSTRAINT_PARENT)
        case .launch_constraint_responsible: RawValue(CSSLOT_LAUNCH_CONSTRAINT_RESPONSIBLE)
        case .library_constraint: RawValue(CSSLOT_LIBRARY_CONSTRAINT)
        case .alternate_codedirectories: RawValue(CSSLOT_ALTERNATE_CODEDIRECTORIES)
        case .alternate_codedirectory_max: RawValue(CSSLOT_ALTERNATE_CODEDIRECTORY_MAX)
        case .alternate_codedirectory_limit: RawValue(CSSLOT_ALTERNATE_CODEDIRECTORY_LIMIT)
        case .signatureslot: RawValue(CSSLOT_SIGNATURESLOT)
        case .identificationslot: RawValue(CSSLOT_IDENTIFICATIONSLOT)
        case .ticketslot: RawValue(CSSLOT_TICKETSLOT)
        }
    }
}

extension CodeSignSlot: CustomStringConvertible {
    public var description: String {
        switch self {
        case .codedirectory: "CSSLOT_CODEDIRECTORY"
        case .infoslot: "CSSLOT_INFOSLOT"
        case .requirements: "CSSLOT_REQUIREMENTS"
        case .resourcedir: "CSSLOT_RESOURCEDIR"
        case .application: "CSSLOT_APPLICATION"
        case .entitlements: "CSSLOT_ENTITLEMENTS"
        case .der_entitlements: "CSSLOT_DER_ENTITLEMENTS"
        case .launch_constraint_self: "CSSLOT_LAUNCH_CONSTRAINT_SELF"
        case .launch_constraint_parent: "CSSLOT_LAUNCH_CONSTRAINT_PARENT"
        case .launch_constraint_responsible: "CSSLOT_LAUNCH_CONSTRAINT_RESPONSIBLE"
        case .library_constraint: "CSSLOT_LIBRARY_CONSTRAINT"
        case .alternate_codedirectories: "CSSLOT_ALTERNATE_CODEDIRECTORIES"
        case .alternate_codedirectory_max: "CSSLOT_ALTERNATE_CODEDIRECTORY_MAX"
        case .alternate_codedirectory_limit: "CSSLOT_ALTERNATE_CODEDIRECTORY_LIMIT"
        case .signatureslot: "CSSLOT_SIGNATURESLOT"
        case .identificationslot: "CSSLOT_IDENTIFICATIONSLOT"
        case .ticketslot: "CSSLOT_TICKETSLOT"
        }
    }
    }
