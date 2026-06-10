//
//  WeakBox.swift
//  MachOKit
//
//  Created by p-x9 on 2026/06/11
//
//

final class WeakBox<T: AnyObject> {
    weak var wrapped: T?

    init(wrapped: T?) {
        self.wrapped = wrapped
    }
}
