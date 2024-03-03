//
//  CodeSignSlot.swift
//
//
//  Created by p-x9 on 2024/03/03.
//  
//

import Foundation
import MachOKitC

public enum CodeSignSlot: UInt32 {
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
