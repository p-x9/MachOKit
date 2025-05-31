//
//  MachOFile+Symbols.swift
//
//
//  Created by p-x9 on 2023/12/08.
//
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
@_spi(Core) internal import FileIO
#else
@_spi(Core) @_implementationOnly import FileIO
#endif

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
        typealias FileSlice = File.FileSlice

        public let symtab: LoadCommandInfo<symtab_command>?

        private let stringsSlice: FileSlice
        private let symbolsSlice: FileSlice
        public let numberOfSymbols: Int

        let isSwapped: Bool

        init(
            symtab: LoadCommandInfo<symtab_command>?,
            stringsSlice: FileSlice,
            symbolsSlice: FileSlice,
            numberOfSymbols: Int,
            isSwapped: Bool
        ) {
            self.symtab = symtab
            self.stringsSlice = stringsSlice
            self.symbolsSlice = symbolsSlice
            self.numberOfSymbols = numberOfSymbols
            self.isSwapped = isSwapped
        }

        public func makeIterator() -> Iterator {
            .init(
                stringsSlice: stringsSlice,
                symbolsSlice: symbolsSlice,
                numberOfSymbols: numberOfSymbols,
                isSwapped: isSwapped
            )
        }
    }
}

extension MachOFile.Symbols64 {
    init(
        machO: MachOFile,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let stringsSlice = try! machO.fileHandle.fileSlice(
            offset: machO.headerStartOffset + numericCast(symtab.stroff),
            length: numericCast(symtab.strsize)
        )

        let symbolsSlice = try! machO.fileHandle.fileSlice(
            offset: machO.headerStartOffset + numericCast(symtab.symoff),
            length: numericCast(symtab.nsyms) * MemoryLayout<nlist_64>.size
        )

        self.init(
            symtab: symtab,
            stringsSlice: stringsSlice,
            symbolsSlice: symbolsSlice,
            numberOfSymbols: numericCast(symtab.nsyms),
            isSwapped: machO.isSwapped
        )
    }
}

extension MachOFile.Symbols64 {
    public var stringsData: Data? {
        try? stringsSlice.readAllData()
    }

    public var symbolssData: Data? {
        try? stringsSlice.readAllData()
    }
}

extension MachOFile.Symbols64 {
    public struct Iterator: IteratorProtocol {
        public typealias Element = MachOFile.Symbol

        let stringsSlice: FileSlice
        let symbolsSlice: FileSlice

        public let numberOfSymbols: Int

        let isSwapped: Bool

        private var nextIndex: Int = 0

        init(
            stringsSlice: FileSlice,
            symbolsSlice: FileSlice,
            numberOfSymbols: Int,
            isSwapped: Bool
        ) {
            self.stringsSlice = stringsSlice
            self.symbolsSlice = symbolsSlice
            self.numberOfSymbols = numberOfSymbols
            self.isSwapped = isSwapped
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfSymbols,
                  symbolsSlice.size != 0,
                  stringsSlice.size != 0 else {
                return nil
            }

            var symbol: nlist_64 = try! symbolsSlice.read(
                offset: Nlist64.layoutSize * nextIndex
            )
            if isSwapped {
                swap_nlist_64(&symbol, 1, NXHostByteOrder())
            }

            defer { nextIndex += 1 }

#if false
            let string = if let buffer = slice.buffer {
                buffer.withUnsafeBytes {
                    guard let baseAddress = $0.baseAddress else {
                        fatalError("data is empty")
                    }
                    return String(
                        cString: baseAddress
                            .advanced(by: numericCast(symbol.n_un.n_strx))
                            .assumingMemoryBound(to: CChar.self)
                    )
                }
            } else {
                slice?.readString(offset: numericCast(numericCast(symbol.n_un.n_strx))) ?? ""
            }
#endif

            let string = String(
                cString: stringsSlice.ptr
                    .advanced(by: numericCast(symbol.n_un.n_strx))
                    .assumingMemoryBound(to: CChar.self),
                encoding: .utf8
            ) ?? ""

            return .init(
                name: string,
                offset: numericCast(symbol.n_value),
                nlist: Nlist64(layout: symbol)
            )
        }
    }
}

extension MachOFile {
    public struct Symbols: Sequence {
        typealias FileSlice = File.FileSlice

        public let symtab: LoadCommandInfo<symtab_command>?

        private let stringsSlice: FileSlice
        private let symbolsSlice: FileSlice
        public let numberOfSymbols: Int

        let isSwapped: Bool

        init(
            symtab: LoadCommandInfo<symtab_command>?,
            stringsSlice: FileSlice,
            symbolsSlice: FileSlice,
            numberOfSymbols: Int,
            isSwapped: Bool
        ) {
            self.symtab = symtab
            self.stringsSlice = stringsSlice
            self.symbolsSlice = symbolsSlice
            self.numberOfSymbols = numberOfSymbols
            self.isSwapped = isSwapped
        }

        public func makeIterator() -> Iterator {
            .init(
                stringsSlice: stringsSlice,
                symbolsSlice: symbolsSlice,
                numberOfSymbols: numberOfSymbols,
                isSwapped: isSwapped
            )
        }
    }
}

extension MachOFile.Symbols {
    init(
        machO: MachOFile,
        symtab: LoadCommandInfo<symtab_command>
    ) {
        let stringsSlice = try! machO.fileHandle.fileSlice(
            offset: machO.headerStartOffset + numericCast(symtab.stroff),
            length: Int(symtab.strsize)
        )

        let symbolsSlice = try! machO.fileHandle.fileSlice(
            offset: machO.headerStartOffset + numericCast(symtab.symoff),
            length: Int(symtab.nsyms) * MemoryLayout<nlist>.size
        )

        self.init(
            symtab: symtab,
            stringsSlice: stringsSlice,
            symbolsSlice: symbolsSlice,
            numberOfSymbols: numericCast(symtab.nsyms),
            isSwapped: machO.isSwapped
        )
    }
}

extension MachOFile.Symbols {
    public var stringsData: Data? {
        try? stringsSlice.readAllData()
    }

    public var symbolssData: Data? {
        try? stringsSlice.readAllData()
    }
}

extension MachOFile.Symbols {
    public struct Iterator: IteratorProtocol {
        public typealias Element = MachOFile.Symbol

        let stringsSlice: FileSlice
        let symbolsSlice: FileSlice

        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        let isSwapped: Bool

        init(
            stringsSlice: FileSlice,
            symbolsSlice: FileSlice,
            numberOfSymbols: Int,
            isSwapped: Bool
        ) {
            self.stringsSlice = stringsSlice
            self.symbolsSlice = symbolsSlice
            self.numberOfSymbols = numberOfSymbols
            self.isSwapped = isSwapped
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfSymbols,
                  symbolsSlice.size != 0,
                  stringsSlice.size != 0 else {
                return nil
            }

            var symbol: nlist = try! symbolsSlice.read(
                offset: Nlist.layoutSize * nextIndex
            )
            if isSwapped {
                swap_nlist(&symbol, 1, NXHostByteOrder())
            }

            defer { nextIndex += 1 }

            let string = stringsSlice.readString(
                offset: numericCast(symbol.n_un.n_strx)
            ) ?? ""

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
        var symbol: nlist_64 = try! symbolsSlice.read(
            offset: Nlist64.layoutSize * position
        )
        if isSwapped {
            swap_nlist_64(&symbol, 1, NXHostByteOrder())
        }

        let string = stringsSlice.readString(
            offset: numericCast(symbol.n_un.n_strx)
        ) ?? ""

        return .init(
            name: string,
            offset: numericCast(symbol.n_value),
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
        var symbol: nlist = try! symbolsSlice.read(
            offset: Nlist.layoutSize * position
        )
        if isSwapped {
            swap_nlist(&symbol, 1, NXHostByteOrder())
        }

        let string = stringsSlice.readString(
            offset: numericCast(symbol.n_un.n_strx)
        ) ?? ""

        return .init(
            name: string,
            offset: numericCast(symbol.n_value),
            nlist: Nlist(layout: symbol)
        )
    }
}

// MARK: - RandomAccessCollection
extension MachOFile.Symbols64: RandomAccessCollection {}
extension MachOFile.Symbols: RandomAccessCollection {}
