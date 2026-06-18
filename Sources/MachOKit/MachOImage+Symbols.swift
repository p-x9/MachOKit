//
//  MachOImage+Symbols..swift
//
//
//  Created by p-x9 on 2023/11/28.
//
//

import Foundation

extension MachOImage {
    public struct Symbol: SymbolProtocol {
        public let nameC: UnsafePointer<CChar>

        /// Offset from start of mach header (`MachO`)
        /// File offset from mach header (`MachOFile`)
        public let offset: Int

        /// Nlist or Nlist64
        public let nlist: any NlistProtocol
    }
}

extension MachOImage.Symbol {
    public var name: String {
        .init(cString: nameC)
    }

    public var demangledName: String {
        if let demangled = stdlib_demangleName(nameC) {
            return .init(cString: demangled)
        }
        if let demangled = cxa_demangle(nameC) {
            return .init(cString: demangled)
        }
        return .init(cString: nameC)
    }
}

// https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx
extension MachOImage {
    public struct Symbols64: Sequence {
        public let stringBase: UnsafePointer<CChar>
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist_64>
        public let numberOfSymbols: Int

        init(
            stringBase: UnsafePointer<CChar>,
            addressStart: Int,
            symbols: UnsafePointer<nlist_64>,
            numberOfSymbols: Int
        ) {
            self.stringBase = stringBase
            self.addressStart = addressStart
            self.symbols = symbols
            self.numberOfSymbols = numberOfSymbols
        }

        init(
            ptr: UnsafeRawPointer,
            text: SegmentCommand64,
            linkedit: SegmentCommand64,
            symtab: LoadCommandInfo<symtab_command>
        ) {
            let fileSlide: Int = numericCast(linkedit.vmaddr) - numericCast(text.vmaddr) - numericCast(linkedit.fileoff)

            stringBase = ptr
                .advanced(by: numericCast(symtab.stroff))
                .advanced(by: fileSlide)
                .assumingMemoryBound(to: CChar.self)
            addressStart = -numericCast(text.vmaddr)
            symbols = ptr
                .advanced(by: numericCast(symtab.symoff))
                .advanced(by: fileSlide)
                .assumingMemoryBound(to: nlist_64.self)
            numberOfSymbols = numericCast(symtab.nsyms)
        }

        public func makeIterator() -> Iterator {
            Iterator(
                stringBase: stringBase,
                addressStart: addressStart,
                symbols: symbols,
                numberOfSymbols: numberOfSymbols
            )
        }
    }
}

extension MachOImage {
    public struct Symbols: Sequence {
        public let stringBase: UnsafePointer<CChar>
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist>
        public let numberOfSymbols: Int

        init(
            stringBase: UnsafePointer<CChar>,
            addressStart: Int,
            symbols: UnsafePointer<nlist>,
            numberOfSymbols: Int
        ) {
            self.stringBase = stringBase
            self.addressStart = addressStart
            self.symbols = symbols
            self.numberOfSymbols = numberOfSymbols
        }

        init(
            ptr: UnsafeRawPointer,
            text: SegmentCommand,
            linkedit: SegmentCommand,
            symtab: LoadCommandInfo<symtab_command>
        ) {
            let fileSlide: Int = numericCast(linkedit.vmaddr) - numericCast(text.vmaddr) - numericCast(linkedit.fileoff)

            stringBase = ptr
                .advanced(by: numericCast(symtab.stroff))
                .advanced(by: fileSlide)
                .assumingMemoryBound(to: CChar.self)
            addressStart = -numericCast(text.vmaddr)
            symbols = ptr
                .advanced(by: numericCast(symtab.symoff))
                .advanced(by: fileSlide)
                .assumingMemoryBound(to: nlist.self)
            numberOfSymbols = numericCast(symtab.nsyms)
        }

        public func makeIterator() -> Iterator {
            Iterator(
                stringBase: stringBase,
                addressStart: addressStart,
                symbols: symbols,
                numberOfSymbols: numberOfSymbols
            )
        }
    }
}

// MARK: - Iterator
extension MachOImage.Symbols64 {
    public struct Iterator: IteratorProtocol {
        public typealias Element = MachOImage.Symbol

        public let stringBase: UnsafePointer<CChar>
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist_64>
        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        init(
            stringBase: UnsafePointer<CChar>,
            addressStart: Int,
            symbols: UnsafePointer<nlist_64>,
            numberOfSymbols: Int
        ) {
            self.stringBase = stringBase
            self.addressStart = addressStart
            self.symbols = symbols
            self.numberOfSymbols = numberOfSymbols
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfSymbols else {
                return nil
            }

            defer {
                nextIndex += 1
            }

            let symbol = symbols.advanced(by: nextIndex).pointee
            let str = stringBase
                .advanced(by: numericCast(symbol.n_un.n_strx))
            let address = addressStart + numericCast(symbol.n_value)

            return MachOImage.Symbol(
                nameC: str,
                offset: address,
                nlist: Nlist64(layout: symbol)
            )
        }
    }
}

extension MachOImage.Symbols {
    public struct Iterator: IteratorProtocol {
        public typealias Element = MachOImage.Symbol

        public let stringBase: UnsafePointer<CChar>
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist>
        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        init(
            stringBase: UnsafePointer<CChar>,
            addressStart: Int,
            symbols: UnsafePointer<nlist>,
            numberOfSymbols: Int
        ) {
            self.stringBase = stringBase
            self.addressStart = addressStart
            self.symbols = symbols
            self.numberOfSymbols = numberOfSymbols
        }

        public mutating func next() -> Element? {
            guard nextIndex < numberOfSymbols else {
                return nil
            }

            defer {
                nextIndex += 1
            }

            let symbol = symbols.advanced(by: nextIndex).pointee
            let str = stringBase
                .advanced(by: Int(symbol.n_un.n_strx))
            let address = addressStart + numericCast(symbol.n_value)

            return MachOImage.Symbol(
                nameC: str,
                offset: address,
                nlist: Nlist(layout: symbol)
            )
        }
    }
}

// MARK: - Collection
extension MachOImage.Symbols64: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfSymbols }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> MachOImage.Symbol {
        let symbol = symbols.advanced(by: position).pointee
        let str = stringBase
            .advanced(by: numericCast(symbol.n_un.n_strx))
        let address = addressStart + numericCast(symbol.n_value)

        return MachOImage.Symbol(
            nameC: str,
            offset: address,
            nlist: Nlist64(layout: symbol)
        )
    }
}

extension MachOImage.Symbols: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfSymbols }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> MachOImage.Symbol {
        let symbol = symbols.advanced(by: position).pointee
        let str = stringBase
            .advanced(by: numericCast(symbol.n_un.n_strx))
        let address = addressStart + numericCast(symbol.n_value)

        return MachOImage.Symbol(
            nameC: str,
            offset: address,
            nlist: Nlist(layout: symbol)
        )
    }
}

// MARK: - RandomAccessCollection
extension MachOImage.Symbols64: RandomAccessCollection {}
extension MachOImage.Symbols: RandomAccessCollection {}

// MARK: - _SymbolTableProtocol

extension MachOImage.Symbols64: _SymbolTableProtocol {
    func wrappedNlist(at position: Int) -> Nlist64 {
        Nlist64(layout: symbols.advanced(by: position).pointee)
    }

    func offset(of nlist: Nlist64) -> Int {
        addressStart + numericCast(nlist.layout.n_value)
    }

    func symbol(at position: Int, nlist: Nlist64) -> MachOImage.Symbol {
        let str = stringBase
            .advanced(by: numericCast(nlist.layout.n_un.n_strx))
        let address = addressStart + numericCast(nlist.layout.n_value)

        return MachOImage.Symbol(
            nameC: str,
            offset: address,
            nlist: nlist
        )
    }
}

extension MachOImage.Symbols: _SymbolTableProtocol {
    func wrappedNlist(at position: Int) -> Nlist {
        Nlist(layout: symbols.advanced(by: position).pointee)
    }

    func offset(of nlist: Nlist) -> Int {
        addressStart + numericCast(nlist.layout.n_value)
    }

    func symbol(at position: Int, nlist: Nlist) -> MachOImage.Symbol {
        let str = stringBase
            .advanced(by: numericCast(nlist.layout.n_un.n_strx))
        let address = addressStart + numericCast(nlist.layout.n_value)

        return MachOImage.Symbol(
            nameC: str,
            offset: address,
            nlist: nlist
        )
    }
}
