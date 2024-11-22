//
//  MachOImage+ExportTrie.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

extension MachOImage {
    public struct ExportTrie: Sequence {
        public typealias Wrapped = MemoryTrieTree<ExportTrieNodeContent>

        private let wrapped: MemoryTrieTree<ExportTrieNodeContent>
        let ldVersion: Version?

        var isPreDyld_1008: Bool {
            if let ldVersion {
                // Initial version of ld-prime
                // Xcode 15.0 beta 1 (15A5160n)
                return ldVersion < .init(major: 1008, minor: 7, patch: 0)
            }
            return false // fallback
        }

        public var basePointer: UnsafeRawPointer {
            wrapped.basePointer
        }
        public var exportSize: Int {
            wrapped.size
        }

        init(
            wrapped: MemoryTrieTree<ExportTrieNodeContent>,
            ldVersion: Version?
        ) {
            self.wrapped = wrapped
            self.ldVersion = ldVersion
        }

        public func makeIterator() -> Iterator {
            .init(
                wrapped: wrapped.makeIterator(),
                isPreDyld_1008: isPreDyld_1008
            )
        }
    }
}

extension MachOImage.ExportTrie {
    /// All exported symbols from the trie tree
    public var exportedSymbols: [ExportedSymbol] {
        wrapped.exportedSymbols
    }

    /// Elements of each of the nodes that make up the trie tree
    ///
    /// It is obtained by traversing the nodes of the trie tree.It is obtained by traversing a trie tree.
    /// Slower than using `ExportTrie` iterator, but compatible with all Linker(ld) versions
    public var entries: [ExportTrieEntry] {
        wrapped.entries
    }
    
    /// Search the trie tree by symbol name to get the expoted symbol
    /// - Parameter key: symbol name
    /// - Returns: If found, retruns exported symbol
    public func search(for key: String) -> ExportedSymbol? {
        wrapped.search(for: key)
    }
}

extension MachOImage.ExportTrie {
    public struct Iterator: IteratorProtocol {
        public typealias Element = Wrapped.Element

        private var wrapped: Wrapped.Iterator
        let isPreDyld_1008: Bool

        @_spi(Support)
        public init(wrapped: Wrapped.Iterator, isPreDyld_1008: Bool) {
            self.wrapped = wrapped
            self.isPreDyld_1008 = isPreDyld_1008
        }

        public mutating func next() -> Element? {
            let isRoot = wrapped.nextOffset == 0

            guard let next = wrapped.next() else {
                return nil
            }

            // HACK: for after dyld-1008.7
            if isRoot && !isPreDyld_1008 {
                // ref: https://github.com/apple-oss-distributions/dyld/blob/main/mach_o/ExportsTrie.cpp#L669-L674
                // root is allocated the size that `UINT_MAX` can represent
                // 32 / 7
                wrapped.nextOffset -= next.children
                    .map(\.offset.uleb128Size)
                    .reduce(0, +)
                wrapped.nextOffset += 5 * next.children.count
            }

            return next
        }
    }
}

extension MachOImage.ExportTrie {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command,
        ldVersion: Version?
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(info.export_size)),
            ldVersion: ldVersion
        )
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command,
        ldVersion: Version?
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.export_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(info.export_size)),
            ldVersion: ldVersion
        )
    }

    init(
        linkedit: SegmentCommand64,
        export: linkedit_data_command,
        vmaddrSlide: Int,
        ldVersion: Version?
    ) {

        let linkeditStart = vmaddrSlide + Int(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        let ptr = UnsafeRawPointer(bitPattern: linkeditStart)! // swiftlint:disable:this force_unwrapping
            .advanced(by: Int(export.dataoff))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(export.datasize)),
            ldVersion: ldVersion
        )
    }

    init(
        linkedit: SegmentCommand,
        export: linkedit_data_command,
        vmaddrSlide: Int,
        ldVersion: Version?
    ) {
        let linkeditStart = vmaddrSlide + Int(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        let ptr = UnsafeRawPointer(bitPattern: linkeditStart)! // swiftlint:disable:this force_unwrapping
            .advanced(by: Int(export.dataoff))
            .assumingMemoryBound(to: UInt8.self)

        self.init(
            wrapped: .init(basePointer: ptr, size: Int(export.datasize)),
            ldVersion: ldVersion
        )
    }
}
