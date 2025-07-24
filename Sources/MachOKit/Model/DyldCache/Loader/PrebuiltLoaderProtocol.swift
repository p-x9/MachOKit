//
//  PrebuiltLoaderProtocol.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/09
//  
//


import Foundation

public protocol PrebuiltLoaderProtocol {
    /// Address where this loader is located.
    ///
    /// Slides after loading are not included.
    var address: Int { get }

    /// magic of loader starts
    var magic: String? { get }
    /// PrebuiltLoader vs JustInTimeLoader
    var isPrebuilt: Bool { get }
    var neverUnload: Bool { get }
    var isPremapped: Bool { get }

    var ref: LoaderRef { get }

    // Information for all pre-calculated sections that we know about
    var sectionLocations: SectionLocations { get }

    /// path for target mach-o image
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: path name
    func path(in cache: DyldCache) -> String?
    /// alternative path for target mach-o image if install_name does not match real path
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: path name
    func altPath(in cache: DyldCache) -> String?
    /// loader reference list of target 's dependencies
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: sequence of loader reference
    func dependentLoaderRefs(in cache: DyldCache) -> DataSequence<LoaderRef>?
    /// Stores information about the layout of the objc sections in a binary
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: binary info for objc
    func objcBinaryInfo(in cache: DyldCache) -> ObjCBinaryInfo?

    /// path for target mach-o image
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: path name
    func path(in cache: DyldCacheLoaded) -> String?
    /// alternative path for target mach-o image if install_name does not match real path
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: path name
    func altPath(in cache: DyldCacheLoaded) -> String?
    /// loader reference list of target 's dependencies
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: sequence of loader reference
    func dependentLoaderRefs(in cache: DyldCacheLoaded) -> MemorySequence<LoaderRef>?
    /// Stores information about the layout of the objc sections in a binary
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: binary info for objc
    func objcBinaryInfo(in cache: DyldCacheLoaded) -> ObjCBinaryInfo?

    /// path for target mach-o image
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: path name
    func path(in cache: FullDyldCache) -> String?
    /// alternative path for target mach-o image if install_name does not match real path
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: path name
    func altPath(in cache: FullDyldCache) -> String?
    /// loader reference list of target 's dependencies
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: sequence of loader reference
    func dependentLoaderRefs(in cache: FullDyldCache) -> DataSequence<LoaderRef>?
    /// Stores information about the layout of the objc sections in a binary
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: binary info for objc
    func objcBinaryInfo(in cache: FullDyldCache) -> ObjCBinaryInfo?
}
