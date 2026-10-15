//
//  AotInstructionMapSubmapEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2026/05/26
//  
//

public struct AotInstructionMapSubmapEntry: Sendable {
    public let x86CodeDelta: Int
    public let armInstructionDelta: Int
    public let metadata: Int
    public let kind: Int?
    public let usesRawDelta: Bool
}
