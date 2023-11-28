//
//  UnsafeRawPointer+.swift
//  
//
//  Created by p-x9 on 2023/11/28.
//  
//

import Foundation

extension UnsafeRawPointer {
    func autoBoundPointee<Out>() -> Out {
        bindMemory(to: Out.self, capacity: 1).pointee
    }
}
