//
//  MachOFile+Symbols.swift
//
//
//  Created by p-x9 on 2023/12/08.
//
//

import Foundation

extension MachOFile {
    public struct Symbol: SymbolProtocol {
        public let name: String

        /// Offset from start of mach header (`MachO`)
        /// File offset from mach header (`MachOFile`)
        public let offset: Int

        /// Nlist or Nlist64
        public let nlist: any NlistProtocol
    }
}

extension MachOFile {
    public struct Symbols64: Sequence {
        public let symtab: LoadCommandInfo<symtab_command>?

        public let stringData: Data
        public let symbolsData: Data
        public let numberOfSymbols: Int

        public func makeIterator() -> Iterator {
            .init(
                stringData: stringData,
                symbolsData: symbolsData,
                numberOfSymbols: numberOfSymbols
            )
        }
    }
}

extension MachOFile.Symbols64 {
    init(
        machO: MachOFile,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let stringData = machO.fileHandle.readData(
            offset: UInt64(machO.headerStartOffset) + UInt64(symtab.stroff),
            size: Int(symtab.strsize)
        )

        let symbolsData = machO.fileHandle.readData(
            offset: UInt64(machO.headerStartOffset) + UInt64(symtab.symoff),
            size: Int(symtab.nsyms) * MemoryLayout<nlist_64>.size
        )

        if machO.isSwapped {
            symbolsData.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                    .assumingMemoryBound(to: nlist_64.self)
                swap_nlist_64(
                    ptr,
                    symtab.nsyms,
                    NXHostByteOrder()
                )
            }
        }
        self.init(
            symtab: symtab,
            stringData: stringData,
            symbolsData: symbolsData,
            numberOfSymbols: numericCast(symtab.nsyms)
        )
    }
}

extension MachOFile.Symbols64 {
    public struct Iterator: IteratorProtocol {
        public typealias Element = MachOFile.Symbol

        let stringData: Data
        let symbolsData: Data

        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        init(
            stringData: Data,
            symbolsData: Data,
            numberOfSymbols: Int
        ) {
            self.stringData = stringData
            self.symbolsData = symbolsData
            self.numberOfSymbols = numberOfSymbols
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfSymbols,
                  !symbolsData.isEmpty,
                  !stringData.isEmpty else {
                return nil
            }

            let symbol: nlist_64 = symbolsData.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else {
                    fatalError("data is empty")
                }
                let ptr = baseAddress
                    .assumingMemoryBound(to: nlist_64.self)

                let symbol = ptr.advanced(by: nextIndex).pointee

                nextIndex += 1

                return symbol
            }

            let string: String = stringData.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else {
                    fatalError("data is empty")
                }
                let ptr = baseAddress
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(symbol.n_un.n_strx))
                return String(
                    cString: ptr
                )
            }

            return .init(
                name: string,
                offset: Int(symbol.n_value),
                nlist: Nlist64(layout: symbol)
            )
        }
    }
}

extension MachOFile {
    public struct Symbols: Sequence {
        public let symtab: LoadCommandInfo<symtab_command>?

        public let stringData: Data
        public let symbolsData: Data
        public let numberOfSymbols: Int

        public func makeIterator() -> Iterator {
            .init(
                stringData: stringData,
                symbolsData: symbolsData,
                numberOfSymbols: numberOfSymbols
            )
        }
    }
}

extension MachOFile.Symbols {
    init(
        machO: MachOFile,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let stringData = machO.fileHandle.readData(
            offset: UInt64(machO.headerStartOffset) + UInt64(symtab.stroff),
            size: Int(symtab.strsize)
        )

        let symbolsData = machO.fileHandle.readData(
            offset: UInt64(machO.headerStartOffset) + UInt64(symtab.symoff),
            size: Int(symtab.nsyms) * MemoryLayout<nlist>.size
        )

        if machO.isSwapped {
            symbolsData.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { return }
                let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                    .assumingMemoryBound(to: nlist.self)
                swap_nlist(
                    ptr,
                    symtab.nsyms,
                    NXHostByteOrder()
                )
            }
        }

        self.init(
            symtab: symtab,
            stringData: stringData,
            symbolsData: symbolsData,
            numberOfSymbols: numericCast(symtab.nsyms)
        )
    }
}

extension MachOFile.Symbols {
    public struct Iterator: IteratorProtocol {
        public typealias Element = MachOFile.Symbol

        let stringData: Data
        let symbolsData: Data

        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        init(
            stringData: Data,
            symbolsData: Data,
            numberOfSymbols: Int
        ) {
            self.stringData = stringData
            self.symbolsData = symbolsData
            self.numberOfSymbols = numberOfSymbols
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfSymbols,
                  !symbolsData.isEmpty,
                  !stringData.isEmpty else {
                return nil
            }

            let symbol: nlist = symbolsData.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else {
                    fatalError("data is empty")
                }
                let ptr = baseAddress
                    .assumingMemoryBound(to: nlist.self)

                let symbol = ptr.advanced(by: nextIndex).pointee

                nextIndex += 1

                return symbol
            }

            let string: String = stringData.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else {
                    fatalError("data is empty")
                }
                let ptr = baseAddress
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(symbol.n_un.n_strx))
                return String(
                    cString: ptr
                )
            }

            return .init(
                name: string,
                offset: Int(symbol.n_value),
                nlist: Nlist(layout: symbol)
            )
        }
    }
}

// MARK: - Collection
extension MachOFile.Symbols64: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfSymbols }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> MachOFile.Symbol {
        let symbol: nlist_64 = symbolsData.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                fatalError("data is empty")
            }
            let ptr = baseAddress
                .assumingMemoryBound(to: nlist_64.self)
            return ptr.advanced(by: position).pointee
        }

        let string: String = stringData.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                fatalError("data is empty")
            }
            let ptr = baseAddress
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(symbol.n_un.n_strx))
            return String(cString: ptr)
        }

        return .init(
            name: string,
            offset: Int(symbol.n_value),
            nlist: Nlist64(layout: symbol)
        )
    }
}

extension MachOFile.Symbols: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfSymbols }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> MachOFile.Symbol {
        let symbol: nlist = symbolsData.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                fatalError("data is empty")
            }
            let ptr = baseAddress
                .assumingMemoryBound(to: nlist.self)
            return ptr.advanced(by: position).pointee
        }

        let string: String = stringData.withUnsafeBytes {
            guard let baseAddress = $0.baseAddress else {
                fatalError("data is empty")
            }
            let ptr = baseAddress
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(symbol.n_un.n_strx))
            return String(cString: ptr)
        }

        return .init(
            name: string,
            offset: Int(symbol.n_value),
            nlist: Nlist(layout: symbol)
        )
    }
}

// MARK: - RandomAccessCollection
extension MachOFile.Symbols64: RandomAccessCollection {}
extension MachOFile.Symbols: RandomAccessCollection {}
