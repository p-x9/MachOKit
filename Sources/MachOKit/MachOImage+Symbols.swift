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
        .init(cString: stdlib_demangleName(nameC))
    }
}

// https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx
extension MachOImage {
    public struct Symbols64: Sequence {
        public let ptr: UnsafeRawPointer
        public let text: SegmentCommand64
        public let linkedit: SegmentCommand64
        public let symtab: LoadCommandInfo<symtab_command>

        public let stringBase: UnsafePointer<CChar>
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist_64>
        public let numberOfSymbols: Int

        init(
            ptr: UnsafeRawPointer,
            text: SegmentCommand64,
            linkedit: SegmentCommand64,
            symtab: LoadCommandInfo<symtab_command>
        ) {
            self.ptr = ptr
            self.text = text
            self.linkedit = linkedit
            self.symtab = symtab

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
        public let ptr: UnsafeRawPointer
        public let text: SegmentCommand
        public let linkedit: SegmentCommand
        public let symtab: LoadCommandInfo<symtab_command>

        public let stringBase: UnsafePointer<CChar>
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist>
        public let numberOfSymbols: Int

        init(
            ptr: UnsafeRawPointer,
            text: SegmentCommand,
            linkedit: SegmentCommand,
            symtab: LoadCommandInfo<symtab_command>
        ) {
            self.ptr = ptr
            self.text = text
            self.linkedit = linkedit
            self.symtab = symtab

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
        get {
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
}

extension MachOImage.Symbols: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfSymbols }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> MachOImage.Symbol {
        get {
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
}

// MARK: - RandomAccessCollection
extension MachOImage.Symbols64: RandomAccessCollection {}
extension MachOImage.Symbols: RandomAccessCollection {}
