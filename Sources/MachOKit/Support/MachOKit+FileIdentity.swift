//
//  MachOKit+FileIdentity.swift
//  MachOKit
//
//  Created by p-x9 on 2026/06/30
//
//

import Foundation
internal import FileIO

// MARK: - file handle identity

/// A marker protocol for objects that identify a MachOKit backing file handle.
///
/// This identity represents the object identity of the handle shared by
/// MachOKit wrappers. It is not a file-system identity: separately opened
/// handles for the same path may have different identities.
@_spi(Support)
@_marker
public protocol FileHandleIdentity: AnyObject {}

@_spi(Support)
extension MemoryMappedFile: FileHandleIdentity {}
@_spi(Support)
extension ConcatenatedMemoryMappedFile: FileHandleIdentity {}

extension MachOFile {
    /// The identity of the backing file handle used by this Mach-O file.
    ///
    /// `MachOFile` instances created from a `DyldCache` share the cache's
    /// backing handle identity. Use this value as an owner key for external
    /// weak caches that should follow the lifetime of the shared handle, not as
    /// a path or inode equivalence check.
    @_spi(Support)
    public var fileHandleIdentity: any FileHandleIdentity { fileHandle }
}

extension DyldCache {
    /// The identity of the backing file handle used by this dyld cache file.
    ///
    /// Mach-O files produced from this cache inherit the same backing handle
    /// identity, allowing external SPI clients to share handle-scoped caches
    /// without exposing the file handle itself.
    @_spi(Support)
    public var fileHandleIdentity: any FileHandleIdentity { fileHandle }
}

extension FullDyldCache {
    /// The identity of the concatenated backing handle used by this full dyld cache.
    ///
    /// This identifies the `FullDyldCache`'s composite handle. Individual
    /// `DyldCache` values produced from it may expose the identity of their
    /// underlying cache-file handle instead.
    @_spi(Support)
    public var fileHandleIdentity: any FileHandleIdentity { fileHandle }
}

extension AotCache {
    /// The identity of the concatenated backing handle used by this aot cache.
    @_spi(Support)
    public var fileHandleIdentity: any FileHandleIdentity { fileHandle }
}
