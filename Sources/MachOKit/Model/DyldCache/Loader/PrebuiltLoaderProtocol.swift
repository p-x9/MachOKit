//
//  PrebuiltLoaderProtocol.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/09
//  
//


import Foundation

public protocol PrebuiltLoaderProtocol {
    var address: Int { get }

    var magic: String? { get }
    var isPrebuilt: Bool { get }
    var ref: LoaderRef { get }

    func path(in cache: DyldCache) -> String?
    func dependentLoaderRefs(in cache: DyldCache) -> DataSequence<LoaderRef>?

    func path(in cache: DyldCacheLoaded) -> String?
    func dependentLoaderRefs(in cache: DyldCacheLoaded) -> MemorySequence<LoaderRef>?
}
