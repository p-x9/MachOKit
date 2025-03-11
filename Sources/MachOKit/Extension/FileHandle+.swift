//
//  FileHandle+.swift
//
//
//  Created by p-x9 on 2024/01/20.
//  
//

import Foundation

extension FileHandle {
    @_spi(Support)
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        let size = Element.layoutSize * numberOfElements
        var data = readData(
            ofLength: size
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
    ) -> DataSequence<Element> {
        seek(toFileOffset: offset)
        let size = MemoryLayout<Element>.size * numberOfElements
        var data = readData(
            ofLength: size
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
        seek(toFileOffset: offset)
        let size = entrySize * numberOfElements
        var data = readData(
            ofLength: size
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
        seek(toFileOffset: offset)
        let size = entrySize * numberOfElements
        var data = readData(
            ofLength: size
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

extension FileHandle {
    @_spi(Support)
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Optional<Element> where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: Element.layoutSize
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
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Optional<Element> {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: MemoryLayout<Element>.size
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
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Element where Element: LayoutWrapper {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: Element.layoutSize
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
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Element {
        seek(toFileOffset: offset)
        var data = readData(
            ofLength: MemoryLayout<Element>.size
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

extension FileHandle {
    @_spi(Support)
    public func readString(
        offset: UInt64,
        size: Int
    ) -> String? {
        let data = readData(
            offset: offset,
            size: size
        )
        return String(cString: data)
    }

    @_spi(Support)
    public func readString(
        offset: UInt64,
        step: UInt64 = 10
    ) -> String? {
        var data = Data()
        var offset = offset
        while true {
            let new = readData(offset: offset, size: Int(step))
            if new.isEmpty { break }
            data.append(new)
            if new.contains(0) { break }
            offset += UInt64(new.count)
        }

        return String(cString: data)
    }

    @_spi(Support)
    public func readData(
        offset: UInt64,
        size: Int
    ) -> Data {
        seek(toFileOffset: offset)
        return readData(
            ofLength: size
        )
    }
}

import FileIO

extension _FileIOProtocol {
    @_spi(Support)
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

extension _FileIOProtocol {
    func readData(offset: UInt64, size: Int) -> Data {
        try! readData(offset: numericCast(offset), length: size)
    }

    func read<T>(offset: UInt64) -> T {
        try! read(offset: numericCast(offset))
    }
}

extension _FileIOProtocol {
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
        var data = readData(
            offset: offset,
            size: size
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
        var data = readData(
            offset: offset,
            size: size
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
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Optional<Element> where Element: LayoutWrapper {
        var data = readData(
            offset: offset,
            size: Element.layoutSize
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
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Optional<Element> {
        var data = readData(
            offset: offset,
            size: MemoryLayout<Element>.size
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
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Element where Element: LayoutWrapper {
        var data = readData(
            offset: offset,
            size: Element.layoutSize
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
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> Element {
        var data = readData(
            offset: offset,
            size: MemoryLayout<Element>.size
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
