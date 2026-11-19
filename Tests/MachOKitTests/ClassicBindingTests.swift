import XCTest
@testable import MachOKit

final class ClassicBindingTests: XCTestCase {
    func testIndirectSymbolCountsUseSectionPointerWidth() {
        var layout32 = section()
        layout32.flags = UInt32(S_NON_LAZY_SYMBOL_POINTERS)
        layout32.size = 8
        XCTAssertEqual(Section(layout: layout32).numberOfIndirectSymbols, 2)

        var layout64 = section_64()
        layout64.flags = UInt32(S_NON_LAZY_SYMBOL_POINTERS)
        layout64.size = 16
        XCTAssertEqual(Section64(layout: layout64).numberOfIndirectSymbols, 2)
    }

    func testLocalEntriesPreserveNonLazyPointerSlots() throws {
        let machO = try MachOFile(data: fixture(flags: UInt32(S_NON_LAZY_SYMBOL_POINTERS)))
        XCTAssertEqual(machO.symbols.map(\.name), ["_foo"])
        XCTAssertEqual(machO.classicBindingSymbols?.map(\.address), [0x1_0000_1008])
    }

    func testAbsoluteEntriesPreserveStubSlots() throws {
        let machO = try MachOFile(data: fixture(flags: UInt32(S_SYMBOL_STUBS | S_ATTR_SELF_MODIFYING_CODE)))
        XCTAssertEqual(machO.classicLazyBindingSymbols?.map(\.address), [0x1_0000_1005])
    }

    private func fixture(flags: UInt32) -> Data {
        var data = Data(count: 0x3000)
        func store<T>(_ value: T, at offset: Int) {
            withUnsafeBytes(of: value) {
                data.replaceSubrange(offset ..< offset + $0.count, with: $0)
            }
        }

        let segmentSize = MemoryLayout<segment_command_64>.size
        let sectionSize = MemoryLayout<section_64>.size
        let symbolCommandSize = MemoryLayout<symtab_command>.size
        let dynamicSymbolCommandSize = MemoryLayout<dysymtab_command>.size

        var header = mach_header_64()
        header.magic = UInt32(MH_MAGIC_64)
        header.cputype = CPU_TYPE_X86_64
        header.cpusubtype = CPU_SUBTYPE_X86_64_ALL
        header.filetype = UInt32(MH_BUNDLE)
        header.ncmds = 5
        header.sizeofcmds = UInt32(3 * segmentSize + sectionSize + symbolCommandSize + dynamicSymbolCommandSize)
        store(header, at: 0)

        var commandOffset = MemoryLayout<mach_header_64>.size
        for (index, name) in ["__TEXT", "__DATA", "__LINKEDIT"].enumerated() {
            var segment = segment_command_64()
            segment.cmd = UInt32(LC_SEGMENT_64)
            segment.cmdsize = UInt32(segmentSize + (index == 1 ? sectionSize : 0))
            withUnsafeMutableBytes(of: &segment.segname) { $0.copyBytes(from: name.utf8) }
            segment.vmaddr = 0x1_0000_0000 + UInt64(index * 0x1000)
            segment.vmsize = 0x1000
            segment.fileoff = UInt64(index * 0x1000)
            segment.filesize = 0x1000
            segment.initprot = index == 1 ? VM_PROT_READ | VM_PROT_WRITE : VM_PROT_READ
            segment.maxprot = segment.initprot
            segment.nsects = index == 1 ? 1 : 0
            store(segment, at: commandOffset)
            if index == 1 {
                let isStub = flags & UInt32(SECTION_TYPE) == UInt32(S_SYMBOL_STUBS)
                var layout = section_64()
                withUnsafeMutableBytes(of: &layout.segname) { $0.copyBytes(from: name.utf8) }
                let sectionName = isStub ? "__stubs" : "__nl_symbol_ptr"
                withUnsafeMutableBytes(of: &layout.sectname) { $0.copyBytes(from: sectionName.utf8) }
                layout.addr = segment.vmaddr
                layout.size = isStub ? 10 : 16
                layout.offset = UInt32(segment.fileoff)
                layout.flags = flags
                layout.reserved2 = isStub ? 5 : 0
                store(layout, at: commandOffset + segmentSize)
                store(isStub ? UInt32(INDIRECT_SYMBOL_ABS) : UInt32(INDIRECT_SYMBOL_LOCAL), at: 0x2040)
            }
            commandOffset += Int(segment.cmdsize)
        }

        var symtab = symtab_command()
        symtab.cmd = UInt32(LC_SYMTAB)
        symtab.cmdsize = UInt32(symbolCommandSize)
        symtab.symoff = 0x2000
        symtab.nsyms = 1
        symtab.stroff = 0x2020
        symtab.strsize = 6
        store(symtab, at: commandOffset)

        var dysymtab = dysymtab_command()
        dysymtab.cmd = UInt32(LC_DYSYMTAB)
        dysymtab.cmdsize = UInt32(dynamicSymbolCommandSize)
        dysymtab.nundefsym = 1
        dysymtab.indirectsymoff = 0x2040
        dysymtab.nindirectsyms = 2
        store(dysymtab, at: commandOffset + symbolCommandSize)

        var symbol = nlist_64()
        symbol.n_un.n_strx = 1
        symbol.n_type = UInt8(N_UNDF | N_EXT)
        store(symbol, at: 0x2000)
        data.replaceSubrange(0x2020 ..< 0x2026, with: "\0_foo\0".utf8)
        return data
    }
}
