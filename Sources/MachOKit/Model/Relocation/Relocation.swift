//
//  Relocation.swift
//
//
//  Created by p-x9 on 2024/01/10.
//
//

import Foundation

public struct Relocation {
    public enum Info {
        case general(RelocationInfo)
        case scattered(ScatteredRelocationInfo)
    }

    public let _data: UInt64

    public var isScattered: Bool {
        _data & UInt64(R_SCATTERED) != 0
    }

    public var info: Info {
        var buffer = _data
        if isScattered {
            let info: ScatteredRelocationInfo = withUnsafePointer(
                to: &buffer,
                {
                    let ptr = UnsafeRawPointer($0)
                    return ptr.autoBoundPointee()
                }
            )
            return .scattered(info)
        } else {
            let info: RelocationInfo = withUnsafePointer(
                to: &buffer,
                {
                    let ptr = UnsafeRawPointer($0)
                    return ptr.autoBoundPointee()
                }
            )
            return .general(info)
        }
    }
}
