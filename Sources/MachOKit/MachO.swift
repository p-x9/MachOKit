//
//  MachO.swift
//
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

public struct MachO {
    public let ptr: UnsafeRawPointer

    public let is64Bit: Bool
    public let loadCommands: LoadCommands

    public var headerSize: Int {
        is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
    }

    public var cmdsStartPtr: UnsafeRawPointer {
        ptr.advanced(by: headerSize)
    }

    public init(ptr: UnsafePointer<mach_header>) {
        self.ptr = .init(ptr)

        let header = ptr.pointee

        self.is64Bit = header.magic == MH_MAGIC_64 || header.magic == MH_CIGAM_64
        let start = UnsafeRawPointer(ptr)
            .advanced(
                by: is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
            )
        loadCommands = .init(start: start, numberOfCommands: Int(header.ncmds))
    }
}

extension MachO {
    public init?(name: String) {
        let indices = 0..<_dyld_image_count()
        let index = indices.first { index in
            guard let pathC = _dyld_get_image_name(index) else {
                return false
            }
            let path = String(cString: pathC)
            let imageName = path
                .components(separatedBy: "/")
                .last?
                .components(separatedBy: ".")
                .first
            if imageName == name {
                print(path)
            }
            return imageName == name
        }

        if let index, let mh = _dyld_get_image_header(index) {
            self.init(ptr: mh)
        } else {
            return nil
        }
    }
}

extension MachO {
    public var header: MachHeader {
        .init(
            layout: ptr
                .assumingMemoryBound(to: mach_header.self)
                .pointee
        )
    }
}

extension MachO {
    public var path: String? {
        var info = Dl_info()
        dladdr(ptr, &info)
        return String(cString: info.dli_fname)
    }
}

extension MachO {
    public var symbols: AnySequence<Symbol> {
        if is64Bit, let symbols64 {
            AnySequence(symbols64)
        } else if let symbols32 {
            AnySequence(symbols32)
        } else {
            AnySequence([])
        }
    }

    public var symbols64: Symbols64? {
        guard is64Bit else {
            return nil
        }
        if let text = loadCommands.text64,
           let linkedit = loadCommands.linkedit64,
           let symtab = loadCommands.symtab {
            return Symbols64(ptr: ptr, text: text, linkedit: linkedit, symtab: symtab)
        }
        return nil
    }

    public var symbols32: Symbols? {
        guard !is64Bit else {
            return nil
        }
        if let text = loadCommands.text,
           let linkedit = loadCommands.linkedit,
           let symtab = loadCommands.symtab {
            return Symbols(ptr: ptr, text: text, linkedit: linkedit, symtab: symtab)
        }
        return nil
    }
}

extension MachO {
    public var rpaths: [String] {
        loadCommands
            .compactMap { cmd in
                if case let .rpath(info) = cmd { info.path(cmdsStart: cmdsStartPtr) } else { nil }
            }
    }
}
