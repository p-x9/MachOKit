//
//  BindOperationsKind.swift
//
//
//  Created by p-x9 on 2023/12/09.
//  
//

import Foundation

public enum BindOperationsKind: Sendable {
    case normal
    case weak
    case lazy
}

extension BindOperationsKind {
    func bindOffset(of info: dyld_info_command) -> UInt32 {
        switch self {
        case .normal: info.bind_off
        case .weak: info.weak_bind_off
        case .lazy: info.lazy_bind_off
        }
    }

    func bindSize(of info: dyld_info_command) -> UInt32 {
        switch self {
        case .normal: info.bind_size
        case .weak: info.weak_bind_size
        case .lazy: info.lazy_bind_size
        }
    }
}
