import Foundation
import MachOKit

extension DyldChainedImportFormat: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .general: "General"
        case .addend: "With Addend"
        case .addend64: "With 64-bit Addend"
        }
    }
}

extension DyldChainedSymbolsFormat: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .uncompressed: "Uncompressed"
        case .zlibCompressed: "Zlib Compressed"
        }
    }
}

extension DyldChainedFixupPointerFormat: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .arm64e: "ARM64e"
        case ._64: "64-bit"
        case ._32: "32-bit"
        case ._32_cache: "32-bit Cache"
        case ._32_firmware: "32-bit Firmware"
        case ._64_offset: "64-bit (Offset)"
        case .arm64e_kernel: "ARM64e Kernel"
        case ._64_kernel_cache: "64-bit Kernel Cache"
        case .arm64e_userland: "ARM64e Userland"
        case .arm64e_firmware: "ARM64e Firmware"
        case .x86_64_kernel_cache: "x86-64 Kernel Cache"
        case .arm64e_userland24: "ARM64e Userland (24-bit)"
        case .arm64e_shared_cache: "ARM64e Shared Cache"
        case .arm64e_segmented: "ARM64e Segmented"
        }
    }
}
