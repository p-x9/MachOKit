//
//  _FileIOProtocol+.swift
//  MachOKit
//
//  Created by p-x9 on 2025/05/06
//  
//

import Foundation
import FileIO

extension _FileIOProtocol {
    @_spi(Support)
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) /*throws*/ -> DataSequence<Element> where Element: LayoutWrapper {
        let size = Element.layoutSize * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }

    @_spi(Support)
    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) /*throws*/ -> DataSequence<Element> {
        let size = MemoryLayout<Element>.size * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }

    @_spi(Support)
    public func readDataSequence<Element>(
        offset: UInt64,
        entrySize: Int,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> where Element: LayoutWrapper {
        let size = entrySize * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            entrySize: entrySize
        )
    }

    @_spi(Support)
    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        entrySize: Int,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> {
        let size = entrySize * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            entrySize: entrySize
        )
    }
}

extension _FileIOProtocol {
    @_spi(Support)
    @inlinable @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Optional<Element> where Element: LayoutWrapper {
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        return try! read(offset: numericCast(offset), as: Element.self)
    }

    @_spi(Support)
    @inlinable @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Optional<Element> {
        try! read(offset: numericCast(offset), as: Element.self)
    }

    @_spi(Support)
    @_disfavoredOverload
    @inlinable @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Element where Element: LayoutWrapper {
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        return try! read(offset: numericCast(offset), as: Element.self)
    }

    @_spi(Support)
    @_disfavoredOverload
    @inlinable @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Element {
        try! read(offset: numericCast(offset), as: Element.self)
    }
}

extension _FileIOProtocol {
    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Optional<Element> where Element: LayoutWrapper {
        var data = try! readData(
            offset: numericCast(offset),
            length: Element.layoutSize
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= Element.layoutSize,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Optional<Element> {
        var data = try! readData(
            offset: numericCast(offset),
            length: MemoryLayout<Element>.size
        )
        precondition(
            data.count >= MemoryLayout<Element>.size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_spi(Support)
    @_disfavoredOverload
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Element where Element: LayoutWrapper {
        var data = try! readData(
            offset: numericCast(offset),
            length: Element.layoutSize
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= Element.layoutSize,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_spi(Support)
    @_disfavoredOverload
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Element {
        var data = try! readData(
            offset: numericCast(offset),
            length: MemoryLayout<Element>.size
        )
        precondition(
            data.count >= MemoryLayout<Element>.size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }
}

extension _FileIOProtocol {
    @_spi(Support)
    @_disfavoredOverload
    @inlinable @inline(__always)
    public func readString(
        offset: UInt64,
        size: Int
    ) -> String? {
        let data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        return String(cString: data)
    }

    @_spi(Support)
    @_disfavoredOverload
    @inlinable @inline(__always)
    public func readString(
        offset: UInt64,
        step: Int = 10
    ) -> String? {
        var data = Data()
        var offset = offset
        while true {
            guard let new = try? readData(
                offset: numericCast(offset),
                upToCount: step
            ) else { break }
            if new.isEmpty { break }
            data.append(new)
            if new.contains(0) { break }
            offset += UInt64(new.count)
        }

        return String(cString: data)
    }
}

extension MemoryMappedFile {
    @_spi(Support)
    @inlinable @inline(__always)
    public func readString(
        offset: UInt64
    ) -> String? {
        String(
            cString: ptr
                .advanced(by: numericCast(offset))
                .assumingMemoryBound(to: CChar.self)
        )
    }

    @_spi(Support)
    @inlinable @inline(__always)
    public func readString(
        offset: UInt64,
        size: Int // ignored
    ) -> String? {
        readString(offset: offset)
    }

    @_spi(Support)
    @inlinable @inline(__always)
    public func readString(
        offset: UInt64,
        step: Int = 10 // ignored
    ) -> String? {
        readString(offset: offset)
    }
}
