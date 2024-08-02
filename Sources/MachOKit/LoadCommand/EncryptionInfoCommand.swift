//
//  EncryptionInfoCommand.swift
//
//
//  Created by p-x9 on 2024/02/23.
//  
//

import Foundation

public protocol EncryptionInfoCommandProtocol: LoadCommandWrapper {
    var cryptId: Int { get }
}

extension EncryptionInfoCommandProtocol {
    public var isEncrypted: Bool {
        cryptId != 0
    }
}

public struct EncryptionInfoCommand: LoadCommandWrapper {
    public typealias Layout = encryption_info_command

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

public struct EncryptionInfoCommand64: LoadCommandWrapper {
    public typealias Layout = encryption_info_command_64

    public var layout: Layout
    public var offset: Int // offset from mach header trailing

    init(_ layout: Layout, offset: Int) {
        self.layout = layout
        self.offset = offset
    }
}

extension EncryptionInfoCommand: EncryptionInfoCommandProtocol {
    public var cryptId: Int {
        numericCast(layout.cryptid)
    }
}

extension EncryptionInfoCommand64: EncryptionInfoCommandProtocol {
    public var cryptId: Int {
        numericCast(layout.cryptid)
    }
}
