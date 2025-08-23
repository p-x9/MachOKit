//
//  ThreadState.swift
//  MachOKit
//
//  Created by p-x9 on 2025/01/13
//  
//

import Foundation
import MachOKitC

public enum ThreadState: Sendable {
    case arm(ARMThreadState)
    case arm64(ARM64ThreadState)
    case i386(i386ThreadState)
    case x86_64(x86_64ThreadState)
}

public struct x86_64ThreadState: LayoutWrapper, Sendable {
    public typealias Layout = x86_thread_state64

    public var layout: Layout
}

public struct i386ThreadState: LayoutWrapper, Sendable {
    public typealias Layout = i386_thread_state

    public var layout: Layout
}

public struct ARMThreadState: LayoutWrapper, Sendable {
    public typealias Layout = arm_thread_state

    public var layout: Layout
}

public struct ARM64ThreadState: LayoutWrapper, Sendable {
    public typealias Layout = arm_thread_state64

    public var layout: Layout
}
