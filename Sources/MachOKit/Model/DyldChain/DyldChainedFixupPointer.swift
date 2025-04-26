//
//  DyldChainedFixupPointer.swift
//
//
//  Created by p-x9 on 2024/02/19.
//  
//

import Foundation

public struct DyldChainedFixupPointer {
    public let offset: Int
    public let fixupInfo: DyldChainedFixupPointerInfo
}

extension DyldChainedFixupPointer {
    public func rebaseTargetRuntimeOffset(
        for cache: DyldCache, // dummy
        preferedLoadAddress: UInt64
    ) -> UInt64? {
        _rebaseTargetRuntimeOffset(
            cache: cache,
            machO: nil,
            preferedLoadAddress: preferedLoadAddress
        )
    }

    public func rebaseTargetRuntimeOffset(
        for machO: MachOFile,
        preferedLoadAddress: UInt64
    ) -> UInt64? {
        _rebaseTargetRuntimeOffset(
            cache: nil,
            machO: machO,
            preferedLoadAddress: preferedLoadAddress
        )
    }

    // https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/common/MachOLayout.cpp#L2087
    private func _rebaseTargetRuntimeOffset(
        cache: DyldCache?,
        machO: MachOFile?,
        preferedLoadAddress: UInt64
    ) -> UInt64? {
        guard let rebase = fixupInfo.rebase else {
            return nil
        }

        let format = fixupInfo.pointerFormat
        switch fixupInfo {
        case .arm64e: fallthrough
        case .arm64e_userland: fallthrough
        case .arm64e_userland24: fallthrough
        case .arm64e_kernel: fallthrough
        case .arm64e_firmware:
            if rebase.isAuth {
                return numericCast(rebase.target)
            } else {
                var unpacked = rebase.unpackedTarget
                if [.arm64e, .arm64e_firmware].contains(format) {
                    unpacked -= preferedLoadAddress
                }
                return unpacked
            }
        case ._64: fallthrough
        case ._64_offset:
            var unpacked = rebase.unpackedTarget
            if format == ._64 {
                unpacked -= preferedLoadAddress
            }
            return unpacked
        case ._64_kernel_cache: fallthrough
        case .x86_64_kernel_cache:
            return numericCast(rebase.target)
        case ._32:
            return numericCast(rebase.target) - preferedLoadAddress
        case ._32_firmware:
            return numericCast(rebase.target) - preferedLoadAddress
        case .arm64e_shared_cache:
            return numericCast(rebase.target)
        case .arm64e_segmented(let info): // FIXME: Check when new dylds are released.
            guard let machO else {
                return nil
            }
            let targetSegOffset: UInt32
            let targetSegIndex: UInt32

            switch info {
            case .rebase(let rebase):
                targetSegOffset = rebase.layout.targetSegOffset
                targetSegIndex = rebase.layout.targetSegIndex
            case .authRebase(let rebase):
                targetSegOffset = rebase.layout.targetSegOffset
                targetSegIndex = rebase.layout.targetSegIndex
            }
            let segment = machO.segments[numericCast(targetSegIndex)]
            return numericCast(segment.virtualMemoryAddress) - preferedLoadAddress + numericCast(targetSegOffset)
        default:
            return nil
        }
    }

    public func rebaseTargetRuntimeOffset(for machO: MachOFile) -> UInt64? {
        let preferedLoadAddress: UInt64
        if let text64 = machO.loadCommands.text64 {
            preferedLoadAddress = text64.vmaddr
        } else if let text = machO.loadCommands.text {
            preferedLoadAddress = numericCast(text.vmaddr)
        } else {
            return nil
        }
        return rebaseTargetRuntimeOffset(
            for: machO,
            preferedLoadAddress: preferedLoadAddress
        )
    }
}

extension DyldChainedFixupPointer {
    // https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/common/MachOLayout.cpp#L2139
    public func bindOrdinalAndAddend(
        for machO: MachOFile  // swiftlint:disable:this unused_parameter
    ) -> (ordinal: Int, addend: UInt64)? {
        guard let bind = fixupInfo.bind else {
            return nil
        }
        let ordinal: Int = bind.ordinal
        var addend: UInt64 = 0

        let format = fixupInfo.pointerFormat
        switch format {
        case .arm64e: fallthrough
        case .arm64e_userland: fallthrough
        case .arm64e_userland24: fallthrough
        case .arm64e_kernel: fallthrough
        case .arm64e_firmware:
            if !bind.isAuth {
                addend = bind.signExtendedAddend
            }
        case ._64: fallthrough
        case ._64_offset:
            addend = bind.addend
        case ._32:
            addend = bind.addend
        default:
            return nil
        }

        return (ordinal, addend)
    }
}
