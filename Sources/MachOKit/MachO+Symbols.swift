//
//  MachO+Symbols..swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

// https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx
extension MachO {
    public struct Symbols64: Sequence {
        public let ptr: UnsafeRawPointer
        public let text: SegmentCommand64
        public let linkedit: SegmentCommand64
        public let symtab: LoadCommandInfo<symtab_command>

        public func makeIterator() -> Iterator {
            let fileSlide = linkedit.vmaddr - text.vmaddr - linkedit.fileoff

            return Iterator(
                stringBase: ptr
                    .advanced(by: numericCast(symtab.stroff))
                    .advanced(by: numericCast(fileSlide)),
                addressStart: numericCast(text.vmaddr),
                symbols: ptr
                    .advanced(by: numericCast(symtab.symoff))
                    .advanced(by: numericCast(fileSlide))
                    .assumingMemoryBound(to: nlist_64.self),
                numberOfSymbols: numericCast(symtab.nsyms)
            )
        }
    }
}

extension MachO {
    public struct Symbols: Sequence {
        public let ptr: UnsafeRawPointer
        public let text: SegmentCommand
        public let linkedit: SegmentCommand
        public let symtab: LoadCommandInfo<symtab_command>

        public func makeIterator() -> Iterator {
            let fileSlide = linkedit.vmaddr - text.vmaddr - linkedit.fileoff

            return Iterator(
                stringBase: ptr
                    .advanced(by: numericCast(symtab.stroff))
                    .advanced(by: numericCast(fileSlide)),
                addressStart: numericCast(text.vmaddr),
                symbols: ptr
                    .advanced(by: numericCast(symtab.symoff))
                    .advanced(by: numericCast(fileSlide))
                    .assumingMemoryBound(to: nlist.self),
                numberOfSymbols: numericCast(symtab.nsyms)
            )
        }
    }
}

extension MachO.Symbols64 {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Symbol

        public let stringBase: UnsafeRawPointer
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist_64>
        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        init(
            stringBase: UnsafeRawPointer,
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
            let symbol = symbols.advanced(by: nextIndex).pointee

            let str = stringBase
                .advanced(by: Int(symbol.n_un.n_strx))
                .assumingMemoryBound(to: CChar.self)
            let address = addressStart + Int(symbol.n_value)
            let name = String(cString: str)

            let result = Symbol(
                name: name,
                offset: address,
                nlist: Nlist64(layout: symbol)
            )

            nextIndex += 1

            return result
        }
    }
}

extension MachO.Symbols {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Symbol

        public let stringBase: UnsafeRawPointer
        public let addressStart: Int
        public let symbols: UnsafePointer<nlist>
        public let numberOfSymbols: Int

        private var nextIndex: Int = 0

        init(
            stringBase: UnsafeRawPointer,
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
            let symbol = symbols.advanced(by: nextIndex).pointee

            let str = stringBase
                .advanced(by: Int(symbol.n_un.n_strx))
                .assumingMemoryBound(to: CChar.self)
            let address = addressStart + Int(symbol.n_value)
            let name = String(cString: str)

            let result = Symbol(
                name: name,
                offset: address,
                nlist: Nlist(layout: symbol)
            )

            nextIndex += 1

            return result
        }
    }
}
