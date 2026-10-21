//
//  ObjCStringHashTable.swift
//  MachOKit
//
//  Created by p-x9 on 2026/10/20
//
//

import Foundation
import MachOKitC
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
internal import FileIOBinary
#else
@_implementationOnly import FileIO
@_implementationOnly import FileIOBinary
#endif

/// Precomputed perfect hash table of strings built by the shared cache builder.
///
/// Base of precomputed selector, class and protocol tables.
///
/// https://github.com/apple-oss-distributions/dyld/blob/fd8d0c4d52320ebf64db34f3cb280310d905c5ae/common/OptimizerObjC.h#L45
public protocol ObjCStringHashTableProtocol: Sendable {
    /// offset from start address of main cache
    var offset: Int { get }
    /// number of buckets
    var capacity: Int { get }
    /// number of occupied buckets
    var occupied: Int { get }
}

extension ObjCStringHashTableProtocol where Self: LayoutWrapper, Layout == objc_string_hash_table {
    public var capacity: Int {
        numericCast(layout.capacity)
    }

    public var occupied: Int {
        numericCast(layout.occupied)
    }
}

extension ObjCStringHashTableProtocol where Self: LayoutWrapper, Layout == objc_string_hash_table {
    internal var _geometry: _ObjCStringHashTableGeometry {
        .init(
            capacity: capacity,
            shift: layout.shift,
            mask: layout.mask,
            salt: layout.salt,
            scrambleOffset: layoutOffset(of: \.scramble),
            tabOffset: layoutSize
        )
    }
}

extension ObjCStringHashTableProtocol {
    internal func _reader<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> _ObjCHashTableFileReader<Cache>? {
        .init(cache: cache, tableOffset: offset)
    }

    internal func _reader(
        in cache: DyldCacheLoaded
    ) -> _ObjCHashTableMemoryReader {
        .init(basePointer: cache.ptr.advanced(by: offset))
    }
}

// MARK: - Geometry

/// Hash parameters and placement of the arrays following the header.
///
/// Kept independent from a concrete layout so that tables of other formats
/// can share the lookup logic.
internal struct _ObjCStringHashTableGeometry {
    let capacity: Int
    let shift: UInt32
    let mask: UInt32
    let salt: UInt64
    /// offset of `scramble[256]` from start of the table
    ///
    /// Only one element is needed per lookup, so it is read on demand
    /// instead of copying the whole array.
    let scrambleOffset: Int
    /// offset of `tab[mask+1]` from start of the table
    let tabOffset: Int

    /// offset of `checkbytes[capacity]` from start of the table
    var checkBytesOffset: Int {
        tabOffset + numericCast(mask) + 1
    }

    /// offset of `offsets[capacity]` from start of the table
    var stringOffsetsOffset: Int {
        checkBytesOffset + capacity * MemoryLayout<UInt8>.size
    }

    /// offset of the end of string hash table part from start of the table
    var stringHashTableEndOffset: Int {
        stringOffsetsOffset + capacity * MemoryLayout<Int32>.size
    }
}

extension _ObjCStringHashTableGeometry {
    /// StringHashTable::hash
    func hash(
        _ key: UnsafeRawBufferPointer,
        reader: some _ObjCHashTableReader
    ) -> Int? {
        let value = PerfectHash.lookup8(key, level: salt)
        guard let tab: UInt8 = reader.read(
            at: tabOffset + numericCast(value & numericCast(mask))
        ), let scramble: UInt32 = reader.read(
            at: scrambleOffset + numericCast(tab) * MemoryLayout<UInt32>.size
        ) else {
            return nil
        }
        // `>>` returns 0 when shift == 64
        let index = UInt32(truncatingIfNeeded: value >> shift) ^ scramble
        return numericCast(index)
    }

    /// StringHashTable::checkbyte
    ///
    /// The check bytes are used to reject strings that aren't in the table
    /// without reading the table's cstring data.
    static func checkByte(_ key: UnsafeRawBufferPointer) -> UInt8 {
        let first = key.first ?? 0
        return ((first & 0x7) << 5) | (UInt8(truncatingIfNeeded: key.count) & 0x1f)
    }

    /// Offset from start of the table to the string in the bucket
    /// - Parameters:
    ///   - index: index of bucket
    ///   - reader: reader for the table
    /// - Returns: offset of string. nil if the bucket is empty.
    func stringOffset(
        at index: Int,
        reader: some _ObjCHashTableReader
    ) -> Int? {
        guard 0 <= index, index < capacity else { return nil }
        guard let offset: Int32 = reader.read(
            at: stringOffsetsOffset + index * MemoryLayout<Int32>.size
        ), offset != 0 else {
            return nil
        }
        return numericCast(offset)
    }

    /// StringHashTable::tryGetIndex
    func index(
        of key: String,
        reader: some _ObjCHashTableReader
    ) -> Int? {
        var key = key
        return key.withUTF8 { buffer in
            let key = UnsafeRawBufferPointer(buffer)
            guard let index = hash(key, reader: reader),
                  index < capacity else {
                return nil
            }

            // Use check byte to reject without reading the table's cstrings
            guard let checkByte: UInt8 = reader.read(
                at: checkBytesOffset + index
            ), checkByte == Self.checkByte(key) else {
                return nil
            }

            guard let offset = stringOffset(at: index, reader: reader),
                  let string = reader.readString(at: offset),
                  string.utf8.elementsEqual(key) else {
                return nil
            }
            return index
        }
    }
}

// MARK: - Reader

/// Reads contents placed relative to start of a hash table.
internal protocol _ObjCHashTableReader {
    /// Read value placed at `offset` from start of the table
    func read<T: FixedWidthInteger>(at offset: Int) -> T?
    /// Read c-string placed at `offset` from start of the table
    ///
    /// The string may be placed outside of the table.
    func readString(at offset: Int) -> String?
}

internal struct _ObjCHashTableFileReader<Cache: _DyldCacheFileRepresentable>: _ObjCHashTableReader {
    let cache: Cache
    /// offset of the table from start address of main cache
    let tableOffset: Int
    /// file offset of the table
    let tableFileOffset: UInt64
    /// file offset of the end of mapping containing the table
    let mappingEndFileOffset: UInt64

    init?(cache: Cache, tableOffset: Int) {
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(tableOffset)
        guard let mapping = cache.mappingInfo(for: address) else {
            return nil
        }
        self.cache = cache
        self.tableOffset = tableOffset
        self.tableFileOffset = address - mapping.address + mapping.fileOffset
        self.mappingEndFileOffset = mapping.fileOffset + mapping.size
    }

    func read<T: FixedWidthInteger>(at offset: Int) -> T? {
        // The table is emitted as a single chunk,
        // so its contents are contiguous in the file.
        guard offset >= 0 else { return nil }
        let fileOffset = tableFileOffset + numericCast(offset)
        guard fileOffset + numericCast(MemoryLayout<T>.size) <= mappingEndFileOffset else {
            return nil
        }
        return cache.fileHandle.read(offset: fileOffset)
    }

    func readString(at offset: Int) -> String? {
        // Strings may be placed in other mapping or subcache.
        let cacheOffset = tableOffset + offset
        guard cacheOffset >= 0 else { return nil }
        let address = cache.mainCacheHeader.sharedRegionStart + numericCast(cacheOffset)
        guard let fileOffset = cache.fileOffset(of: address) else {
            return nil
        }
        return cache.fileHandle.readString(offset: fileOffset)
    }
}

internal struct _ObjCHashTableMemoryReader: _ObjCHashTableReader {
    /// start address of the table
    let basePointer: UnsafeRawPointer

    func read<T: FixedWidthInteger>(at offset: Int) -> T? {
        basePointer.loadUnaligned(fromByteOffset: offset, as: T.self)
    }

    func readString(at offset: Int) -> String? {
        String(
            cString: basePointer
                .advanced(by: offset)
                .assumingMemoryBound(to: CChar.self)
        )
    }
}

// MARK: - Layout

extension _DyldCacheFileRepresentable {
    /// Read string hash table layout
    /// - Parameter offset: offset from start address of main cache
    /// - Returns: layout of hash table header
    internal func _objcStringHashTableLayout(
        at offset: Int
    ) -> objc_string_hash_table? {
        guard offset > 0 else { return nil }
        let address = mainCacheHeader.sharedRegionStart + numericCast(offset)
        guard let fileOffset = fileOffset(of: address) else {
            return nil
        }
        let layout: objc_string_hash_table = fileHandle.read(offset: fileOffset)
        return layout
    }
}

extension DyldCacheLoaded {
    /// Read string hash table layout
    /// - Parameter offset: offset from start address of main cache
    /// - Returns: layout of hash table header
    internal func _objcStringHashTableLayout(
        at offset: Int
    ) -> objc_string_hash_table? {
        guard offset > 0 else { return nil }
        // Specify the type explicitly so that `Out` is not inferred as Optional.
        let layout: objc_string_hash_table = ptr
            .advanced(by: offset)
            .autoBoundPointee()
        return layout
    }
}
