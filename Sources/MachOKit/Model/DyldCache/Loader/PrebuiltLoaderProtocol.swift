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
    ///  PrebuiltLoader vs JustInTimeLoader
    var isPrebuilt: Bool { get }
    var ref: LoaderRef { get }

    /// path for target mach-o image
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: path name
    func path(in cache: DyldCache) -> String?
    /// loader reference list of target 's dependencies
    /// - Parameter cache: DyldCache to which `self` belongs
    /// - Returns: sequence of loader reference
    func dependentLoaderRefs(in cache: DyldCache) -> DataSequence<LoaderRef>?

    /// path for target mach-o image
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: path name
    func path(in cache: DyldCacheLoaded) -> String?
    /// loader reference list of target 's dependencies
    /// - Parameter cache: DyldCacheLoaded to which `self` belongs
    /// - Returns: sequence of loader reference
    func dependentLoaderRefs(in cache: DyldCacheLoaded) -> MemorySequence<LoaderRef>?
}
