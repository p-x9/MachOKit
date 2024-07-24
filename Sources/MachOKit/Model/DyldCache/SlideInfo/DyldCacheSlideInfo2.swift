//
//  DyldCacheSlideInfo2.swift
//
//
//  Created by p-x9 on 2024/07/23
//  
//

import Foundation
import MachOKitC

public struct DyldCacheSlideInfo2: LayoutWrapper {
    public typealias Layout = dyld_cache_slide_info2

    public var layout: Layout
    public var offset: Int
}

// MARK: - PageAttributes
extension DyldCacheSlideInfo2 {
    public struct PageAttributes: BitFlags {
        public typealias RawValue = UInt16

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension DyldCacheSlideInfo2.PageAttributes {
    /// DYLD_CACHE_SLIDE_PAGE_ATTR_EXTRA
    public static let extra = Self(
        rawValue: Bit.extra.rawValue
    )

    /// DYLD_CACHE_SLIDE_PAGE_ATTR_NO_REBASE
    public static let no_rebase = Self(
        rawValue: Bit.no_rebase.rawValue
    )

    /// DYLD_CACHE_SLIDE_PAGE_ATTR_END
    public static let end = Self(
        rawValue: Bit.end.rawValue
    )
}

extension DyldCacheSlideInfo2.PageAttributes {
    public enum Bit: CaseIterable {
        /// DYLD_CACHE_SLIDE_PAGE_ATTR_EXTRA
        case extra
        /// DYLD_CACHE_SLIDE_PAGE_ATTR_NO_REBASE
        case no_rebase
        /// DYLD_CACHE_SLIDE_PAGE_ATTR_END
        case end
    }
}

extension DyldCacheSlideInfo2.PageAttributes.Bit: RawRepresentable {
    public typealias RawValue = UInt16

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(DYLD_CACHE_SLIDE_PAGE_ATTR_EXTRA): self = .extra
        case RawValue(DYLD_CACHE_SLIDE_PAGE_ATTR_NO_REBASE): self = .no_rebase
        case RawValue(DYLD_CACHE_SLIDE_PAGE_ATTR_END): self = .end
        default:
            return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .extra: RawValue(DYLD_CACHE_SLIDE_PAGE_ATTR_EXTRA)
        case .no_rebase: RawValue(DYLD_CACHE_SLIDE_PAGE_ATTR_NO_REBASE)
        case .end: RawValue(DYLD_CACHE_SLIDE_PAGE_ATTR_END)
        }
    }
}

extension DyldCacheSlideInfo2.PageAttributes.Bit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .extra: "DYLD_CACHE_SLIDE_PAGE_ATTR_EXTRA"
        case .no_rebase: "DYLD_CACHE_SLIDE_PAGE_ATTR_NO_REBASE"
        case .end: "DYLD_CACHE_SLIDE_PAGE_ATTR_END"
        }
    }
}

// MARK: - PageStart
extension DyldCacheSlideInfo2 {
    public struct PageStart {
        public let value: UInt16

        public var attributes: PageAttributes {
            .init(rawValue: value & numericCast(DYLD_CACHE_SLIDE_PAGE_ATTRS))
        }
    }
}

// MARK: - function & proerty
extension DyldCacheSlideInfo2 {
    public var numberOfPageStarts: Int {
        numericCast(layout.page_starts_count)
    }

    public func pageStarts(in cache: DyldCache) -> DataSequence<PageStart>? {
        guard layout.page_starts_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.page_starts_offset),
            numberOfElements: numberOfPageStarts
        )
    }
}

extension DyldCacheSlideInfo2 {
    public var numberOfPageExtras: Int {
        numericCast(layout.page_extras_count)
    }

    public func pageExtras(in cache: DyldCache) -> DataSequence<UInt16>? {
        guard layout.page_starts_offset > 0 else { return nil }
        return cache.fileHandle.readDataSequence(
            offset: numericCast(offset) + numericCast(layout.page_extras_offset),
            numberOfElements: numberOfPageExtras
        )
    }
}
