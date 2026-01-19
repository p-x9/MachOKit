//
//  CxaDemangle.swift
//  MachOKit
//
//  Created by p-x9 on 2026/01/19
//  
//

import Foundation

@_silgen_name("__cxa_demangle")
internal func __cxa_demangle(
    mangledName: UnsafePointer<CChar>?,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    status: UInt32
) -> UnsafeMutablePointer<CChar>?

internal func cxa_demangle(
    _ mangledName: String
) -> String? {
    guard !mangledName.isEmpty else { return mangledName }
    return mangledName.utf8CString.withUnsafeBufferPointer { mangledNameUTF8 in
        let demangledNamePtr = __cxa_demangle(
            mangledName: mangledNameUTF8.baseAddress,
            outputBuffer: nil,
            outputBufferSize: nil,
            status: 0
        )

        if let demangledNamePtr {
            return String(cString: demangledNamePtr)
        }
        return nil
    }
}

internal func cxa_demangle(
    _ mangledName: UnsafePointer<CChar>
) -> UnsafePointer<CChar>? {
    let demangledNamePtr = __cxa_demangle(
        mangledName: mangledName,
        outputBuffer: nil,
        outputBufferSize: nil,
        status: 0
    )
    if let demangledNamePtr {
        return .init(demangledNamePtr)
    }
    return nil
}
