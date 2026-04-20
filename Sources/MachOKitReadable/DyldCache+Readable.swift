import Foundation
import MachOKit

extension DyldCacheType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .development: "Development"
        case .production: "Production"
        case .multiCache: "Multi-Cache"
        }
    }
}

extension DyldCacheSubType: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .development: "Development"
        case .production: "Production"
        }
    }
}

extension DyldCacheMappingFlags.Bit: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .authData: "Authenticated Data"
        case .dirtyData: "Dirty Data"
        case .constData: "Const Data"
        case .textStubs: "Text Stubs"
        case .configData: "Dynamic Config Data"
        case .readOnlyData: "Read-Only Data"
        case .constTproData: "Const TPRO Data"
        }
    }
}

extension DyldCacheMappingFlags {
    public var readableDescriptions: [String] {
        bits.map(\.readableDescription)
    }
}

extension DyldCacheMappingFlags: ReadableDescriptionConvertible {
    public var readableDescription: String {
        readableDescriptions.joined(separator: ", ")
    }
}

extension DyldCacheSlideInfo.Version: ReadableDescriptionConvertible {
    public var readableDescription: String {
        switch self {
        case .none: "None"
        case .v1: "Version 1"
        case .v2: "Version 2"
        case .v3: "Version 3"
        case .v4: "Version 4"
        case .v5: "Version 5"
        }
    }
}
