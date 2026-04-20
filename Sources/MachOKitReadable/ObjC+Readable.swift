import Foundation
import MachOKit

extension ObjCOptimizationFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .isProduction: "Production"
        case .noMissingWeakSuperclasses: "No Missing Weak Superclasses"
        case .largeSharedCache: "Large Shared Cache"
        }
    }
}

extension ObjCOptimizationFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension ObjCOptimizationFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}

extension ObjCImageInfoFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .dyldCategoriesOptimized: "Dyld-Optimized Categories"
        case .supportsGC: "Supports Garbage Collection"
        case .requiresGC: "Requires Garbage Collection"
        case .optimizedByDyld: "Optimized by Dyld"
        case .signedClassRO: "Signed Class RO"
        case .isSimulated: "Simulator Image"
        case .hasCategoryClassProperties: "Has Category Class Properties"
        case .optimizedByDyldClosure: "Optimized by Dyld Closure"
        }
    }
}

extension ObjCImageInfoFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension ObjCImageInfoFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}
