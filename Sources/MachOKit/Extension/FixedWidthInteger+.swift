//
//  FixedWidthInteger+.swift
//  MachOKit
//
//  Created by p-x9 on 2024/11/20
//  
//

import Foundation

extension FixedWidthInteger {
    var uleb128Size: Int {
        var value = self
        var result = 0

        repeat {
            value = value >> 7
            result += 1
        } while value != 0

        return result
    }
}
