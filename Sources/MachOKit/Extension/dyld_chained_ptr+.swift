//
//  dyld_chained_ptr+.swift
//
//
//  Created by p-x9 on 2024/02/19.
//
//

import Foundation
import MachOKitC

#if hasAttribute(retroactive)

extension dyld_chained_ptr_arm64e_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_rebase(target: \(target), high8: \(high8), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_bind: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_bind(ordinal: \(ordinal), zero: \(zero), addend: \(addend), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_auth_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_rebase(target: \(target), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_auth_bind: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_bind(ordinal: \(ordinal), zero: \(zero), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_64_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_64_rebase(target: \(target), high8: \(high8), reserved: \(reserved), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_arm64e_bind24: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_bind24(ordinal: \(ordinal), zero: \(zero), addend: \(addend), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_auth_bind24: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_bind24(ordinal: \(ordinal), zero: \(zero), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_64_bind: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_64_bind(ordinal: \(ordinal), addend: \(addend), reserved: \(reserved), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_64_kernel_cache_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_64_kernel_cache_rebase(target: \(target), cacheLevel: \(cacheLevel), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), isAuth: \(isAuth))"
    }
}

extension dyld_chained_ptr_32_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_rebase(target: \(target), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_32_bind: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_bind(ordinal: \(ordinal), addend: \(addend), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_32_cache_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_cache_rebase(target: \(target), next: \(next))"
    }
}

extension dyld_chained_ptr_32_firmware_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_firmware_rebase(target: \(target), next: \(next))"
    }
}

extension dyld_chained_ptr_arm64e_shared_cache_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_shared_cache_rebase(runtimeOffset: \(runtimeOffset), high8: \(high8), unused: \(unused), next: \(next), auth: \(auth)"
    }
}

extension dyld_chained_ptr_arm64e_shared_cache_auth_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_shared_cache_auth_rebase(runtimeOffset: \(runtimeOffset), diversity: \(diversity), addrDiv: \(addrDiv), key: \(keyIsData), next: \(next), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_segmented_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_segmented_rebase(targetSegOffset: \(targetSegOffset), targetSegIndex: \(targetSegIndex), padding: \(padding), next: \(next), auth: \(auth)"
    }
}

extension dyld_chained_ptr_arm64e_auth_segmented_rebase: @retroactive CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_segmented_rebase(targetSegOffset: \(targetSegOffset), targetSegIndex: \(targetSegIndex), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), auth: \(auth)"
    }
}

#else

extension dyld_chained_ptr_arm64e_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_rebase(target: \(target), high8: \(high8), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_bind: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_bind(ordinal: \(ordinal), zero: \(zero), addend: \(addend), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_auth_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_rebase(target: \(target), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_auth_bind: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_bind(ordinal: \(ordinal), zero: \(zero), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_64_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_64_rebase(target: \(target), high8: \(high8), reserved: \(reserved), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_arm64e_bind24: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_bind24(ordinal: \(ordinal), zero: \(zero), addend: \(addend), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_auth_bind24: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_bind24(ordinal: \(ordinal), zero: \(zero), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), bind: \(bind), auth: \(auth))"
    }
}

extension dyld_chained_ptr_64_bind: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_64_bind(ordinal: \(ordinal), addend: \(addend), reserved: \(reserved), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_64_kernel_cache_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_64_kernel_cache_rebase(target: \(target), cacheLevel: \(cacheLevel), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), isAuth: \(isAuth))"
    }
}

extension dyld_chained_ptr_32_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_rebase(target: \(target), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_32_bind: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_bind(ordinal: \(ordinal), addend: \(addend), next: \(next), bind: \(bind))"
    }
}

extension dyld_chained_ptr_32_cache_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_cache_rebase(target: \(target), next: \(next))"
    }
}

extension dyld_chained_ptr_32_firmware_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_32_firmware_rebase(target: \(target), next: \(next))"
    }
}

extension dyld_chained_ptr_arm64e_shared_cache_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_shared_cache_rebase(runtimeOffset: \(runtimeOffset), high8: \(high8), unused: \(unused), next: \(next), auth: \(auth)"
    }
}

extension dyld_chained_ptr_arm64e_shared_cache_auth_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_shared_cache_auth_rebase(runtimeOffset: \(runtimeOffset), diversity: \(diversity), addrDiv: \(addrDiv), key: \(keyIsData), next: \(next), auth: \(auth))"
    }
}

extension dyld_chained_ptr_arm64e_segmented_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_segmented_rebase(targetSegOffset: \(targetSegOffset), targetSegIndex: \(targetSegIndex), padding: \(padding), next: \(next), auth: \(auth)"
    }
}

extension dyld_chained_ptr_arm64e_auth_segmented_rebase: CustomStringConvertible {
    public var description: String {
        "dyld_chained_ptr_arm64e_auth_segmented_rebase(targetSegOffset: \(targetSegOffset), targetSegIndex: \(targetSegIndex), diversity: \(diversity), addrDiv: \(addrDiv), key: \(key), next: \(next), auth: \(auth)"
    }
}

#endif
