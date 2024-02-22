//
//  String+.swift
//  
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

extension String {
    typealias CCharTuple16 = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

    init(tuple: CCharTuple16) {
        var buffer = tuple
        self = withUnsafePointer(to: &buffer.0) {
            let data = Data(bytes: $0, count: 16) + [0]
            return String(cString: data)!
        }
    }
}

extension String {
    typealias CCharTuple32 = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

    init(tuple: CCharTuple32) {
        var buffer = tuple
        self = withUnsafePointer(to: &buffer.0) {
            let data = Data(bytes: $0, count: 32) + [0]
            return String(cString: data)!
        }
    }
}

extension String {
    init?(cString data: Data) {
        guard !data.isEmpty else { return nil }
        self = data.withUnsafeBytes {
            let ptr = $0.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
    }
}

extension String {
    @inline(__always)
    func isEqual(to tuple: CCharTuple16) -> Bool {
        var buffer = tuple
        return withUnsafePointer(to: &buffer.0) { tuple in
            withCString { str in
                strcmp(str, tuple) == 0
            }
        }
    }

    @inline(__always)
    func isEqual(to tuple: CCharTuple32) -> Bool {
        var buffer = tuple
        return withUnsafePointer(to: &buffer.0) { tuple in
            withCString { str in
                strcmp(str, tuple) == 0
            }
        }
    }
}

func ==(string: String, tuple: String.CCharTuple16) -> Bool {
    string.isEqual(to: tuple)
}

func ==(tuple: String.CCharTuple16, string: String) -> Bool {
    string.isEqual(to: tuple)
}

func ==(string: String, tuple: String.CCharTuple32) -> Bool {
    string.isEqual(to: tuple)
}

func ==(tuple: String.CCharTuple32, string: String) -> Bool {
    string.isEqual(to: tuple)
}
