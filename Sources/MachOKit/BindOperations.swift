//
//  BindOperations.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public struct BindOperations: Sequence {
    public enum Kind {
        case normal
        case weak
        case lazy
    }

    public let basePointer: UnsafePointer<UInt8>
    public let bindSize: Int

    public func makeIterator() -> Iterator {
        .init(basePointer: basePointer, bindSize: bindSize)
    }
}

extension BindOperations {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command,
        kind: Kind = .normal
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(kind.bindOffset(of: info)))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, bindSize: Int(kind.bindSize(of: info)))
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command,
        kind: Kind = .normal
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(kind.bindOffset(of: info)))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, bindSize: Int(kind.bindSize(of: info)))
    }
}

extension BindOperations {
    public struct Iterator: IteratorProtocol {
        public typealias Element = BindOperation

        private let basePointer: UnsafePointer<UInt8>
        private let bindSize: Int

        private var nextOffset: Int = 0

        init(basePointer: UnsafePointer<UInt8>, bindSize: Int) {
            self.basePointer = basePointer
            self.bindSize = bindSize
        }

        public mutating func next() -> Element? {
            guard nextOffset < bindSize else { return nil }

            let val = basePointer.advanced(by: nextOffset).pointee
            nextOffset += MemoryLayout<UInt8>.size

            let imm = Int32(val) & BIND_IMMEDIATE_MASK
            let opcodeRaw = Int32(val) & BIND_OPCODE_MASK
            guard let opcode = BindOpcode(rawValue: opcodeRaw) else {
                return nil
            }

            switch opcode {
            case .done:
                return .done

            case .set_dylib_ordinal_imm:
                return .set_dylib_ordinal_imm(ordinal: UInt(imm))

            case .set_dylib_ordinal_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .set_dylib_ordinal_uleb(ordinal: value)

            case .set_dylib_special_imm:
                let special = BindSpecial(rawValue: imm)!
                return .set_dylib_special_imm(special: special)

            case .set_symbol_trailing_flags_imm:
                let (string, stringSize) = basePointer
                    .advanced(by: nextOffset)
                    .readString()
                nextOffset += stringSize
                return .set_symbol_trailing_flags_imm(flags: UInt(imm), symbol: string)

            case .set_type_imm:
                let type = BindType(rawValue: imm) ?? .pointer
                return .set_type_imm(type: type)

            case .set_addend_sleb:
                let (value, slebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readSLEB128()
                nextOffset += slebSize
                return .set_addend_sleb(addend: value)

            case .set_segment_and_offset_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .set_segment_and_offset_uleb(segment: UInt(imm), offset: value)

            case .add_addr_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .add_addr_uleb(offset: value)

            case .do_bind:
                return .do_bind

            case .do_bind_add_addr_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .do_bind_add_addr_uleb(offset: value)

            case .do_bind_add_addr_imm_scaled:
                return .do_bind_add_addr_imm_scaled(scale: UInt(imm))

            case .do_bind_uleb_times_skipping_uleb:
                let (count, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize

                let (skip, ulebSize2) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize2

                return .do_bind_uleb_times_skipping_uleb(count: count, skip: skip)

            case .threaded:
                let subopcode = BindSubOpcode(rawValue: imm)!
                switch subopcode {
                case .threaded_apply:
                    return .threaded(.threaded_apply)
                case .threaded_set_bind_ordinal_table_size_uleb:
                    let (size, ulebOff) = basePointer
                        .advanced(by: nextOffset)
                        .readULEB128()
                    nextOffset += ulebOff
                    return .threaded(.threaded_set_bind_ordinal_table_size_uleb(size: Int(size)))
                }
            }

        }
    }
}

extension BindOperations.Kind {
    func bindOffset(of info: dyld_info_command) -> UInt32 {
        switch self {
        case .normal: info.bind_off
        case .weak: info.weak_bind_off
        case .lazy: info.lazy_bind_off
        }
    }

    func bindSize(of info: dyld_info_command) -> UInt32 {
        switch self {
        case .normal: info.bind_size
        case .weak: info.weak_bind_size
        case .lazy: info.lazy_bind_size
        }
    }
}
