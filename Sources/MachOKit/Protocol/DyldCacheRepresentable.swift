//
//  DyldCacheRepresentable.swift
//
//
//  Created by p-x9 on 2024/10/06
//  
//

import Foundation

public protocol DyldCacheRepresentable {
    associatedtype MappingInfos: RandomAccessCollection<DyldCacheMappingInfo>
    associatedtype MappingAndSlideInfos: RandomAccessCollection<DyldCacheMappingAndSlideInfo>
    associatedtype ImageInfos: RandomAccessCollection<DyldCacheImageInfo>
    associatedtype ImageTextInfos: RandomAccessCollection<DyldCacheImageTextInfo>
    associatedtype SubCaches: RandomAccessCollection<DyldSubCacheEntry>
    associatedtype DylibsTrieEntries: TrieTreeProtocol<DylibsTrieNodeContent>
    associatedtype ProgramsTrieEntries: TrieTreeProtocol<ProgramsTrieNodeContent>

    /// Byte size of header
    var headerSize: Int { get }
    /// Header for dyld cache
    var header: DyldCacheHeader { get }
    /// Target CPU info.
    ///
    /// It is obtained based on magic in header.
    var cpu: CPU { get }
    /// Header for main dyld cache
    /// When this dyld cache is a subcache, represent the header of the main cache
    ///
    /// Some properties are only set for the main cache header
    /// https://github.com/apple-oss-distributions/dyld/blob/d552c40cd1de105f0ec95008e0e0c0972de43456/cache_builder/SubCache.cpp#L1353
    var mainCacheHeader: DyldCacheHeader { get }

    /// Sequence of mapping infos
    var mappingInfos: MappingInfos? { get }
    /// Sequence of mapping and slide infos
    var mappingAndSlideInfos: MappingAndSlideInfos? { get }

    /// Sequence of image infos.
    var imageInfos: ImageInfos? { get }
    /// Sequence of image text infos.
    var imageTextInfos: ImageTextInfos? { get }

    /// Sub cache type
    ///
    /// Check if entry type is `dyld_subcache_entry_v1` or `dyld_subcache_entry`
    var subCacheEntryType: DyldSubCacheEntryType? { get }
    /// Sequence of sub caches
    var subCaches: SubCaches? { get }

    /// Local symbol info
    var localSymbolsInfo: DyldCacheLocalSymbolsInfo? { get }

    /// Dylibs trie is for searching by dylib name.
    ///
    /// The ``dylibIndices`` are retrieved from this trie tree．
    var dylibsTrieEntries: DylibsTrieEntries? { get }
    /// Array of Dylib name-index pairs
    ///
    /// This index matches the index in the dylib image list that can be retrieved from imagesOffset.
    ///
    /// If an alias exists, there may be another element with an equal index.
    /// ```
    /// 0 /usr/lib/libobjc.A.dylib
    /// 0 /usr/lib/libobjc.dylib
    /// ```
    var dylibIndices: [DylibIndex] { get }

    /// Pair of program name/cdhash and offset to prebuiltLoaderSet
    ///
    /// The ``programOffsets`` are retrieved from this trie tree．
    var programsTrieEntries: ProgramsTrieEntries? { get }
    /// Pair of program name/cdhash and offset to prebuiltLoaderSet
    ///
    /// Example:
    /// ```
    /// 0 /System/Applications/App Store.app/Contents/MacOS/App Store
    /// 0 /cdhash/32caa391186c08b3b3cb7866995db1cb65b0376a
    /// 131776 /System/Applications/Automator.app/Contents/MacOS/Automator
    /// 131776 /cdhash/fed26a75645fed2a674b5c4d01001bfa69b9dbea
    /// ```
    var programOffsets: [ProgramOffset] { get }
    /// PrebuiltLoaderSet of all cached dylibs
    var dylibsPrebuiltLoaderSet: PrebuiltLoaderSet? { get }

    /// Optimization info for Objective-C
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L1892-L1898)
    var objcOptimization: ObjCOptimization? { get }
    /// Old style of optimization info for Objective-C
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L1906-L1942)
    var oldObjcOptimization: OldObjCOptimization? { get }
    /// Optimization info for Swift
    ///
    /// [dyld implementation](https://github.com/apple-oss-distributions/dyld/blob/65bbeed63cec73f313b1d636e63f243964725a9d/common/DyldSharedCache.cpp#L2088-L2098)
    var swiftOptimization: SwiftOptimization? { get }

    /// Get the prebuiltLoaderSet indicated by programOffset.
    /// - Parameter programOffset: program name and offset pair
    /// - Returns: prebuiltLoaderSet
    func prebuiltLoaderSet(for programOffset: ProgramOffset) -> PrebuiltLoaderSet?

    /// Expected file size of this cache
    ///
    /// mapping information is used in the calculation.
    /// Does not include subcache size.
    var expectedCacheFileSize: Int? { get }

    /// Convert vmaddr to file offset
    /// - Parameter address: vmaddr
    /// - Returns: file offset
    ///
    /// If nil is returned, it may be that a non-valid address was given or
    /// an address that exists in the subcache.
    func fileOffset(of address: UInt64) -> UInt64?
    /// Convert file offset to vmaddr
    /// - Parameter fileOffset: file offset
    /// - Returns: vmaddr
    ///
    /// - Warning: If you want to convert a file offset read from one section or another,
    /// you need to check that it is really contained in this file before using it.
    /// Otherwise you may get the wrong address.
    func address(of fileOffset: UInt64) -> UInt64?
    /// Get mapping info containing the specified vmaddr
    /// - Parameter address: vmaddr
    /// - Returns: mapping info
    func mappingInfo(for address: UInt64) -> DyldCacheMappingInfo?
    /// Get mapping info containing the specified file offset
    /// - Parameter offset: file offset
    /// - Returns: mapping info
    func mappingInfo(forFileOffset offset: UInt64) -> DyldCacheMappingInfo?
    /// Get mapping and slideinfo containing the specified vmaddr
    /// - Parameter address: vmaddr
    /// - Returns: mapping and slide info
    func mappingAndSlideInfo(for address: UInt64) -> DyldCacheMappingAndSlideInfo?
    /// Get mapping and slide info containing the specified file offset
    /// - Parameter offset: file offset
    /// - Returns: mapping and slide info
    func mappingAndSlideInfo(forFileOffset offset: UInt64) -> DyldCacheMappingAndSlideInfo?
}

extension DyldCacheRepresentable {
    public var expectedCacheFileSize: Int? {
        guard let map = mappingAndSlideInfos?.max(
            by: { lhs, rhs in lhs.fileOffset < rhs.fileOffset }
        ) else { return nil }
        return numericCast(map.fileOffset + map.size + header.codeSignatureSize)
    }
}

extension DyldCacheRepresentable {
    public func fileOffset(of address: UInt64) -> UInt64? {
        guard let mapping = mappingInfo(for: address) else {
            return nil
        }
        return address - mapping.address + mapping.fileOffset
    }

    public func address(of fileOffset: UInt64) -> UInt64? {
        guard let mapping = mappingInfo(forFileOffset: fileOffset) else {
            return nil
        }
        return fileOffset - mapping.fileOffset + mapping.address
    }

    public func mappingInfo(for address: UInt64) -> DyldCacheMappingInfo? {
        guard let mappings = self.mappingInfos else { return nil }
        for mapping in mappings {
            if mapping.address <= address,
               address < mapping.address + mapping.size {
                return mapping
            }
        }
        return nil
    }

    public func mappingInfo(
        forFileOffset offset: UInt64
    ) -> DyldCacheMappingInfo? {
        guard let mappings = self.mappingInfos else { return nil }
        for mapping in mappings {
            if mapping.fileOffset <= offset,
               offset < mapping.fileOffset + mapping.size {
                return mapping
            }
        }
        return nil
    }

    public func mappingAndSlideInfo(
        for address: UInt64
    ) -> DyldCacheMappingAndSlideInfo? {
        guard let mappings = self.mappingAndSlideInfos else { return nil }
        for mapping in mappings {
            if mapping.address <= address,
               address < mapping.address + mapping.size {
                return mapping
            }
        }
        return nil
    }

    public func mappingAndSlideInfo(
        forFileOffset offset: UInt64
    ) -> DyldCacheMappingAndSlideInfo? {
        guard let mappings = self.mappingAndSlideInfos else { return nil }
        for mapping in mappings {
            if mapping.fileOffset <= offset,
               offset < mapping.fileOffset + mapping.size {
                return mapping
            }
        }
        return nil
    }
}
