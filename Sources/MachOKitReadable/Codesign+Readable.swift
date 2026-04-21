import Foundation
import MachOKit

extension CodeSignMagic: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .requirement: "Requirement"
        case .requirements: "Requirements"
        case .codedirectory: "Code Directory"
        case .embedded_signature: "Embedded Signature"
        case .embedded_signature_old: "Embedded Signature (Old)"
        case .embedded_entitlements: "Embedded Entitlements"
        case .embedded_der_entitlements: "Embedded DER Entitlements"
        case .detached_signature: "Detached Signature"
        case .blobwrapper: "Blob Wrapper"
        case .embedded_launch_constraint: "Embedded Launch Constraint"
        }
    }
}

extension CodeSignSlot: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .codedirectory: "Code Directory"
        case .infoslot: "Info.plist"
        case .requirements: "Requirements"
        case .resourcedir: "Resource Directory"
        case .application: "Application"
        case .entitlements: "Entitlements"
        case .der_entitlements: "DER Entitlements"
        case .launch_constraint_self: "Launch Constraint (Self)"
        case .launch_constraint_parent: "Launch Constraint (Parent)"
        case .launch_constraint_responsible: "Launch Constraint (Responsible)"
        case .library_constraint: "Library Constraint"
        case .alternate_codedirectories: "Alternate Code Directories"
        case .alternate_codedirectory_max: "Alternate Code Directory Max"
        case .alternate_codedirectory_limit: "Alternate Code Directory Limit"
        case .signatureslot: "Signature"
        case .identificationslot: "Identification"
        case .ticketslot: "Ticket"
        }
    }
}

extension CodeSignHashType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .sha1: "SHA-1"
        case .sha256: "SHA-256"
        case .sha256_truncated: "SHA-256 (Truncated)"
        case .sha384: "SHA-384"
        }
    }
}

extension CodeSignSpecialSlotType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .infoSlot: "Info.plist"
        case .requirementsSlot: "Requirements"
        case .resourceDirSlot: "Resource Directory"
        case .topDirectorySlot: "Top Directory"
        case .entitlementSlot: "Entitlements"
        case .repSpecificSlot: "Rep-Specific"
        case .entitlementDERSlot: "Entitlements (DER)"
        case .launchConstraintSelf: "Launch Constraint (Self)"
        case .launchConstraintParent: "Launch Constraint (Parent)"
        case .launchConstraintResponsible: "Launch Constraint (Responsible)"
        case .libraryConstraint: "Library Constraint"
        }
    }
}

extension CodeSignExecSegmentFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .main_binary: "Main Binary"
        case .allow_unsigned: "Allow Unsigned"
        case .debugger: "Debugger"
        case .jit: "JIT"
        case .skip_lv: "Skip Library Validation"
        case .can_load_cdhash: "Can Load CDHash"
        case .can_exec_cdhash: "Can Exec CDHash"
        }
    }
}

extension CodeSignExecSegmentFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension CodeSignExecSegmentFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
