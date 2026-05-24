//
//  AotBranchDataPayloadLocation.swift
//  MachOKit
//
//  Created by p-x9 on 2026/05/25
//  
//

public struct AotBranchDataPayloadLocation: Sendable {
    public let x86CodeBucketRelativeOffset: Int
    public let armCodeBucketRelativeInstructionIndex: Int
    public let x86CodeOffset: Int
    public let armCodeOffset: Int

    public var armCodeBucketRelativeOffset: Int {
        armCodeBucketRelativeInstructionIndex * 4
    }
}
