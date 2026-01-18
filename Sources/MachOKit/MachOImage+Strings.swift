//
//  Strings.swift
//
//
//  Created by p-x9 on 2023/12/02.
//  
//

import Foundation

extension MachOImage {
    public typealias UnicodeStrings = MachOKit.UnicodeStrings
    public typealias Strings = UnicodeStrings<UTF8>
    public typealias UTF16Strings = UnicodeStrings<UTF16>
}

extension MachOImage.UnicodeStrings {
    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand64,
        linkedit: SegmentCommand64,
        symtab: LoadCommandInfo<symtab_command>,
        isSwapped: Bool = false
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        let offset: Int = numericCast(symtab.stroff) + numericCast(fileSlide)
        self.init(
            source: MemoryUnicodeStringsSource(
                ptr: ptr,
                size: .max // Dummy
            ),
            offset: offset,
            size: Int(symtab.strsize),
            isSwapped: isSwapped
        )
    }

    init(
        ptr: UnsafeRawPointer,
        text: SegmentCommand,
        linkedit: SegmentCommand,
        symtab: LoadCommandInfo<symtab_command>,
        isSwapped: Bool = false
    ) {
        let fileSlide = Int(linkedit.vmaddr) - Int(text.vmaddr) - Int(linkedit.fileoff)
        let offset: Int = numericCast(symtab.stroff) + numericCast(fileSlide)
        self.init(
            source: MemoryUnicodeStringsSource(
                ptr: ptr,
                size: .max // Dummy
            ),
            offset: offset,
            size: Int(symtab.strsize),
            isSwapped: isSwapped
        )
    }
}

extension MachOImage.UnicodeStrings {
    init(
        basePointer: UnsafePointer<Encoding.CodeUnit>,
        tableSize: Int
    ) {
        self.init(
            source: MemoryUnicodeStringsSource(
                ptr: .init(basePointer),
                size: tableSize
            ),
            offset: 0,
            size: tableSize,
            isSwapped: false
        )
    }
}
