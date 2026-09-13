//
//  MachOKit+FileIdentity.swift
//  MachOKit
//
//  Created by p-x9 on 2026/06/30
//
//

import Foundation

// MARK: - file handle identity

/// A marker protocol for objects that identify a MachOKit backing file handle.
///
/// This identity represents a MachOKit-owned token associated with the backing
/// handle shared by MachOKit wrappers. It is not the file handle itself, and it
/// is not a file-system identity: separately opened handles for the same path
/// may have different identities.
///
/// Example:
/// ```swift
/// @_spi(Support) import MachOKit
///
/// final class ParsedFileCache {}
///
/// final class ExternalCacheStore {
///     private let caches = WeakMapTable<any FileHandleIdentity, ParsedFileCache>()
///
///     func cache(for machO: MachOFile) -> ParsedFileCache {
///         let owner = machO.fileHandleIdentity
///         if let cache = caches[owner] {
///             return cache
///         }
///         let cache = ParsedFileCache()
///         caches[owner] = cache
///         return cache
///     }
/// }
/// ```
@_spi(Support)
@_marker
public protocol FileHandleIdentity: AnyObject {}

final class FileHandleIdentityBox: FileHandleIdentity {}

private final class FileHandleIdentityStorage: @unchecked Sendable {
    private let lock = NSLock()
    #if canImport(ObjectiveC)
    private let entries = NSMapTable<AnyObject, FileHandleIdentityBox>.weakToStrongObjects()
    #else
    private var entries = WeakKeyStrongValueMap<AnyObject, FileHandleIdentityBox>()
    #endif

    @inline(__always)
    func identity(for fileHandle: AnyObject) -> FileHandleIdentityBox {
        lock.lock()
        defer { lock.unlock() }

        if let identity = entries.object(forKey: fileHandle) {
            return identity
        }

        let identity = FileHandleIdentityBox()
        entries.setObject(identity, forKey: fileHandle)
        return identity
    }
}

enum FileHandleIdentityStore {
    private static let storage = FileHandleIdentityStorage()

    @inline(__always)
    static func identity(for fileHandle: AnyObject) -> FileHandleIdentityBox {
        storage.identity(for: fileHandle)
    }
}

extension MachOFile {
    /// The identity of the backing file handle used by this Mach-O file.
    ///
    /// `MachOFile` instances created from a `DyldCache` share the cache's
    /// backing handle identity. Use this value as an owner key for external
    /// weak caches that should follow the lifetime of the shared handle, not as
    /// a path or inode equivalence check.
    @_spi(Support)
    @inline(__always)
    public var fileHandleIdentity: any FileHandleIdentity {
        _fileHandleIdentity
    }
}

extension DyldCache {
    /// The identity of the backing file handle used by this dyld cache file.
    ///
    /// Mach-O files produced from this cache inherit the same backing handle
    /// identity, allowing external SPI clients to share handle-scoped caches
    /// without exposing the file handle itself.
    @_spi(Support)
    @inline(__always)
    public var fileHandleIdentity: any FileHandleIdentity {
        _fileHandleIdentity
    }
}

extension FullDyldCache {
    /// The identity of the concatenated backing handle used by this full dyld cache.
    ///
    /// This identifies the `FullDyldCache`'s composite handle. Individual
    /// `DyldCache` values produced from it may expose the identity of their
    /// underlying cache-file handle instead.
    @_spi(Support)
    @inline(__always)
    public var fileHandleIdentity: any FileHandleIdentity {
        _fileHandleIdentity
    }
}

extension AotCache {
    /// The identity of the backing file handle used by this AOT cache file.
    ///
    /// Use this value as an owner key for external weak caches that should
    /// follow the lifetime of the AOT cache's mapped file handle, not as a path
    /// or inode equivalence check.
    @_spi(Support)
    @inline(__always)
    public var fileHandleIdentity: any FileHandleIdentity {
        _fileHandleIdentity
    }
}
