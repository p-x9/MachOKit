//
//  CodeSignSpecialSlotType.swift
//
//
//  Created by p-x9 on 2024/03/04.
//  
//

import Foundation

/// Special slot in code directory
///
/// https://github.com/apple-oss-distributions/Security/blob/ef677c3d667a44e1737c1b0245e9ed04d11c51c1/OSX/libsecurity_codesigning/lib/codedirectory.h#L86
public enum CodeSignSpecialSlotType: Int {
    /// Info.plist
    case infoSlot = 1
    /// internal requirements
    case requirementsSlot = 2
    /// resource directory
    case resourceDirSlot = 3
    /// Application specific slot
    case topDirectorySlot = 4
    /// embedded entitlement configuration/
    case entitlementSlot = 5
    /// for use by disk rep/
    case repSpecificSlot = 6
    /// DER repreesentation of entitlements/
    case entitlementDERSlot = 7
    /// DER representation of LWCR on self/
    case launchConstraintSelf = 8
    /// DER representation of LWCR on the parent/
    case launchConstraintParent = 9
    /// DER representation of LWCR on the responsible process/
    case launchConstraintResponsible = 10
    /// DER representation of LWCR on libraries loaded in the process/
    case libraryConstraint = 11
    // (add further primary slot numbers here)
}
