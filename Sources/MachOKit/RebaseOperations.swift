//
//  RebaseOperations.swift
//
//
//  Created by p-x9 on 2023/12/03.
//  
//

import Foundation

public struct RebaseOperations: Sequence {
    public let basePointer: UnsafePointer<UInt8>
    public let rebaseSize: Int

    public func makeIterator() -> Iterator {
        .init(basePointer: basePointer, rebaseSize: rebaseSize)
    }
}

extension RebaseOperations {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.rebase_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, rebaseSize: Int(info.rebase_size))
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        info: dyld_info_command
    ) {
        let fileSlide = linkedit.vmaddr - text.vmaddr - (linkedit.fileoff - text.fileoff)
        let ptr = ptr
            .advanced(by: Int(info.rebase_off))
            .advanced(by: Int(fileSlide))
            .assumingMemoryBound(to: UInt8.self)

        self.init(basePointer: ptr, rebaseSize: Int(info.rebase_size))
    }
}


extension RebaseOperations {
    public struct Iterator: IteratorProtocol {
        public typealias Element = RebaseOperation

        private let basePointer: UnsafePointer<UInt8>
        private let rebaseSize: Int

        private var nextOffset: Int = 0
        private var done: Bool = false

        init(basePointer: UnsafePointer<UInt8>, rebaseSize: Int) {
            self.basePointer = basePointer
            self.rebaseSize = rebaseSize
        }

        public mutating func next() -> Element? {
            guard !done, nextOffset < rebaseSize else { return nil }

            let val = basePointer.advanced(by: nextOffset).pointee
            nextOffset += MemoryLayout<UInt8>.size

            let imm = Int32(val) & REBASE_IMMEDIATE_MASK
            let opcodeRaw = Int32(val) & REBASE_OPCODE_MASK
            guard let opcode = RebaseOpcode(rawValue: opcodeRaw) else {
                return nil
            }

            switch opcode {
            case .done:
                done = true
                return .done

            case .set_type_imm:
                let type = RebaseType(rawValue: imm)
                return .set_type_imm(type ?? .pointer)

            case .set_segment_and_offset_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .set_segment_and_offset_uleb(segment: Int(imm), offset: value)

            case .add_addr_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .add_addr_uleb(offset: value)

            case .add_addr_imm_scaled:
                return .add_addr_imm_scaled(scale: UInt(imm))

            case .do_rebase_imm_times:
                return .do_rebase_imm_times(count: UInt(imm))

            case .do_rebase_uleb_times:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .do_rebase_uleb_times(count: value)

            case .do_rebase_add_addr_uleb:
                let (value, ulebSize) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize
                return .do_rebase_add_addr_uleb(offset: value)

            case .do_rebase_uleb_times_skipping_uleb:
                let (value1, ulebSize1) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize1

                let (value2, ulebSize2) = basePointer
                    .advanced(by: nextOffset)
                    .readULEB128()
                nextOffset += ulebSize2
                return .do_rebase_uleb_times_skipping_uleb(count: value1, skip: value2)
            }
        }
    }
}
