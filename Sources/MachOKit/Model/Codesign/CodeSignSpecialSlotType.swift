//
//  CodeSignSpecialSlotType.swift
//
//
//  Created by p-x9 on 2024/03/04.
//  
//

import Foundation

// https://github.com/apple-oss-distributions/Security/blob/ef677c3d667a44e1737c1b0245e9ed04d11c51c1/OSX/libsecurity_codesigning/lib/codedirectory.h#L86
public enum CodeSignSpecialSlotType: Int {
    case infoSlot = 1                        // Info.plist
    case requirementsSlot = 2                // internal requirements
    case resourceDirSlot = 3                // resource directory
    case topDirectorySlot = 4                // Application specific slot
    case entitlementSlot = 5                // embedded entitlement configuration
    case repSpecificSlot = 6                // for use by disk rep
    case entitlementDERSlot = 7            // DER repreesentation of entitlements
    case launchConstraintSelf = 8            // DER representation of LWCR on self
    case launchConstraintParent = 9        // DER representation of LWCR on the parent
    case launchConstraintResponsible = 10    // DER representation of LWCR on the responsible process
    case libraryConstraint = 11           // DER representation of LWCR on libraries loaded in the process
    // (add further primary slot numbers here)
}
