//
//  Sequence+.swift
//
//
//  Created by p-x9 on 2023/12/11.
//  
//

import Foundation

// https://opensource.apple.com/source/ld64/ld64-253.9/src/other/dyldinfo.cpp.auto.html
extension Sequence<BindOperation> {
    func bindings(
        is64Bit: Bool
    ) -> [BindingSymbol] {
        var symbolName = "??"
        var libraryOrdinal: Int = 0
        var bindType: BindType = .pointer
        var addend: Int = 0

        var segmentIndex: UInt = 0
        var segmentOffset: UInt = 0

        var bindings: [BindingSymbol] = []

        let ptrSize = is64Bit ? MemoryLayout<UInt64>.size : MemoryLayout<UInt32>.size

        var done = false
        for operation in self {
            if done { /*break*/ }

            switch operation {
            case .done:
                done = true

            case let .set_dylib_ordinal_imm(ordinal: ordinal):
                libraryOrdinal = ordinal

            case let .set_dylib_ordinal_uleb(ordinal: ordinal):
                libraryOrdinal = ordinal

            case let .set_dylib_special_imm(special: special):
                libraryOrdinal = Int(special.rawValue)

            case let .set_symbol_trailing_flags_imm(flags: _, symbol: symbol):
                symbolName = symbol

            case let .set_type_imm(type: type):
                bindType = type

            case let .set_addend_sleb(addend: value):
                addend = value

            case let .set_segment_and_offset_uleb(segment: segment, offset: offset):
                segmentIndex = segment
                segmentOffset = offset

            case let .add_addr_uleb(offset: offset):
                segmentOffset &+= offset

            case .do_bind:
                bindings.append(
                    .init(
                        type: bindType,
                        libraryOrdinal: libraryOrdinal,
                        segmentIndex: segmentIndex,
                        segmentOffset: segmentOffset,
                        addend: addend,
                        symbolName: symbolName
                    )
                )
                segmentOffset &+= UInt(ptrSize)

            case let .do_bind_add_addr_uleb(offset: offset):
                bindings.append(
                    .init(
                        type: bindType,
                        libraryOrdinal: libraryOrdinal,
                        segmentIndex: segmentIndex,
                        segmentOffset: segmentOffset,
                        addend: addend,
                        symbolName: symbolName
                    )
                )
                segmentOffset &+= UInt(ptrSize)
                segmentOffset &+= offset

            case let .do_bind_add_addr_imm_scaled(scale: scale):
                bindings.append(
                    .init(
                        type: bindType,
                        libraryOrdinal: libraryOrdinal,
                        segmentIndex: segmentIndex,
                        segmentOffset: segmentOffset,
                        addend: addend,
                        symbolName: symbolName
                    )
                )
                segmentOffset &+= (scale + 1) * UInt(ptrSize)

            case let .do_bind_uleb_times_skipping_uleb(count: count, skip: skip):
                for _ in 0..<count {
                    bindings.append(
                        .init(
                            type: bindType,
                            libraryOrdinal: libraryOrdinal,
                            segmentIndex: segmentIndex,
                            segmentOffset: segmentOffset,
                            addend: addend,
                            symbolName: symbolName
                        )
                    )
                    segmentOffset &+= skip + UInt(ptrSize)
                }

            default: break
            }
        }
        return bindings
    }
}

extension Sequence<RebaseOperation> {
    func rebases(
        is64Bit: Bool
    ) -> [Rebase] {
        var rebaseType: RebaseType = .pointer
        var segmentIndex: Int = 0
        var segmentOffset: UInt = 0

        var rebases: [Rebase] = []

        let ptrSize = is64Bit ? MemoryLayout<UInt64>.size : MemoryLayout<UInt32>.size

        var done = false
        for operation in self {
            if done { break }

            switch operation {
            case .done:
                done = true

            case let .set_type_imm(type):
                rebaseType = type

            case let .set_segment_and_offset_uleb(segment: segment, offset: offset):
                segmentIndex = segment
                segmentOffset = offset

            case let .add_addr_uleb(offset: offset):
                segmentOffset &+= offset

            case let .add_addr_imm_scaled(scale: scale):
                segmentOffset &+= scale * UInt(ptrSize)

            case let .do_rebase_imm_times(count: count):
                for _ in 0..<count {
                    rebases.append(
                        .init(
                            type: rebaseType,
                            segmentIndex: segmentIndex,
                            segmentOffset: segmentOffset
                        )
                    )
                    segmentOffset &+= UInt(ptrSize)
                }

            case let .do_rebase_uleb_times(count: count):
                for _ in 0..<count {
                    rebases.append(
                        .init(
                            type: rebaseType,
                            segmentIndex: segmentIndex,
                            segmentOffset: segmentOffset
                        )
                    )
                    segmentOffset &+= UInt(ptrSize)
                }

            case let .do_rebase_add_addr_uleb(offset: offset):
                rebases.append(
                    .init(
                        type: rebaseType,
                        segmentIndex: segmentIndex,
                        segmentOffset: segmentOffset
                    )
                )
                segmentOffset &+= offset
                segmentOffset &+= UInt(ptrSize)

            case let .do_rebase_uleb_times_skipping_uleb(count: count, skip: skip):
                for _ in 0..<count {
                    rebases.append(
                        .init(
                            type: rebaseType,
                            segmentIndex: segmentIndex,
                            segmentOffset: segmentOffset
                        )
                    )
                    segmentOffset &+= skip
                    segmentOffset &+= UInt(ptrSize)
                }
            }
        }

        return rebases
    }
}

extension Sequence where Element == MachOFile.Symbol {
    func named(
        _ name: String,
        mangled: Bool = true
    ) -> [Element] {
        guard let nameC = name.cString(using: .utf8) else {
            return []
        }
        var results: [Element] = []
        for symbol in self {
            if strcmp(nameC, symbol.name) == 0 ||
                symbol.name.withCString({ strcmp(nameC, $0 + 1) == 0 }) {
                results.append(symbol)
            } else if !mangled,
                      let demangled = stdlib_demangleName(symbol.name),
                      strcmp(nameC, demangled) == 0 {
                results.append(symbol)
            }
        }
        return results
    }

    @available(*, deprecated, renamed: "named(_:mangled:)", message: "Please use a new function that returns as an array")
    @_disfavoredOverload
    func named(
        _ name: String,
        mangled: Bool = true
    ) -> Element? {
        named(name, mangled: mangled).first
    }
}

extension Sequence where Element == MachOImage.Symbol {
    // more faster
    func named(
        _ name: String,
        mangled: Bool = true
    ) -> [Element] {
        guard let nameC = name.cString(using: .utf8) else {
            return []
        }
        var results: [Element] = []
        for symbol in self {
            if strcmp(nameC, symbol.nameC) == 0 || strcmp(nameC, symbol.nameC + 1) == 0 {
                results.append(symbol)
            } else if !mangled,
                      let demangled = stdlib_demangleName(symbol.nameC),
                      strcmp(nameC, demangled) == 0 {
                results.append(symbol)
            }
        }
        return results
    }

    @available(*, deprecated, renamed: "named(_:mangled:)", message: "Please use a new function that returns as an array")
    @_disfavoredOverload
    func named(
        _ name: String,
        mangled: Bool = true
    ) -> Element? {
        named(name, mangled: mangled).first
    }
}

extension Sequence where Element == CodeSignCodeDirectory {
    public var bestHashTyped: CodeSignCodeDirectory? {
        self.max { lhs, rhs in
            lhs.hashType.priority < rhs.hashType.priority
        }
    }
}
