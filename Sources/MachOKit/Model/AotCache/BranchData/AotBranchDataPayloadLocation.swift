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

extension AotBranchDataPayloadLocation {
    public init(
        record: AotBranchDataPayloadRecord,
        entry: AotBranchDataIndexEntryCompact
    ) {
        self.init(
            x86CodeBucketRelativeOffset: record.x86CodeBucketRelativeOffset,
            armCodeBucketRelativeInstructionIndex: record.armCodeBucketRelativeInstructionIndex,
            x86CodeOffset: entry.x86CodeBucketOffset + record.x86CodeBucketRelativeOffset,
            armCodeOffset: entry.armCodeBucketOffset + record.armCodeBucketRelativeOffset
        )
    }

    public init(
        record: AotBranchDataPayloadRecord,
        entry: AotBranchDataIndexEntry
    ) {
        self.init(
            x86CodeBucketRelativeOffset: record.x86CodeBucketRelativeOffset,
            armCodeBucketRelativeInstructionIndex: record.armCodeBucketRelativeInstructionIndex,
            x86CodeOffset: entry.x86CodeBucketOffset + record.x86CodeBucketRelativeOffset,
            armCodeOffset: entry.armCodeBucketOffset + record.armCodeBucketRelativeOffset
        )
    }

    public init(
        record: AotBranchDataPayloadRecordExtended,
        entry: AotBranchDataIndexEntryExtended
    ) {
        self.init(
            x86CodeBucketRelativeOffset: record.x86CodeBucketRelativeOffset,
            armCodeBucketRelativeInstructionIndex: record.armCodeBucketRelativeInstructionIndex,
            x86CodeOffset: entry.x86CodeBucketOffset + record.x86CodeBucketRelativeOffset,
            armCodeOffset: entry.armCodeBucketOffset + record.armCodeBucketRelativeOffset
        )
    }
}
