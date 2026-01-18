//
//  MachOFile+Strings.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
internal import FileIOBinary
#else
@_implementationOnly import FileIO
@_implementationOnly import FileIOBinary
#endif

extension MachOFile {
    public typealias UnicodeStrings = MachOKit.UnicodeStrings

    public typealias Strings = UnicodeStrings<UTF8>
    public typealias UTF16Strings = UnicodeStrings<UTF16>
}

extension MachOFile.UnicodeStrings {
    @_spi(Support)
    public init(
        machO: MachOFile,
        offset: Int,
        size: Int,
        isSwapped: Bool
    ) {
        let fileSlice = try! machO.fileHandle.fileSlice(
            offset: offset,
            length: size
        )
        self.init(
            source: fileSlice,
            offset: offset,
            size: size,
            isSwapped: isSwapped
        )
    }
}
