//
//  global.swift
//
//
//  Created by p-x9 on 2024/02/17.
//  
//

import Foundation

public func autoBitCast<T, U>(_ x: T) -> U {
    unsafeBitCast(x, to: U.self)
}
