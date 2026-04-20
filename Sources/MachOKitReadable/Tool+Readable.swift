import Foundation
import MachOKit

extension Tool: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .clang: "Clang"
        case .swift: "Swift"
        case .ld: "ld"
        case .lld: "LLD"
        case .metal: "Metal"
        case .airLld: "AIR LLD"
        case .airNt: "AIR NT"
        case .airNtPlugin: "AIR NT Plugin"
        case .airPack: "AIR Pack"
        case .gpuArchiver: "GPU Archiver"
        case .metalFramework: "Metal Framework"
        }
    }
}
