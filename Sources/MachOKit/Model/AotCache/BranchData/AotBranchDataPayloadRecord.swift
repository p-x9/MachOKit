//
//  AotBranchDataPayloadRecord.swift
//  MachOKit
//
//  Created by p-x9 on 2026/05/25
//  
//

import MachOKitC

public struct AotBranchDataPayloadRecord: LayoutWrapper, Sendable {
    public typealias Layout = aot_branch_data_payload_record

    public var layout: Layout
}

extension AotBranchDataPayloadRecord {
    public var x86CodeBucketRelativeOffset: Int {
        numericCast(layout.x86_code_bucket_offset)
    }

    public var armCodeBucketRelativeInstructionIndex: Int {
        numericCast(layout.arm_code_bucket_instruction_index)
    }

    public var armCodeBucketRelativeOffset: Int {
        armCodeBucketRelativeInstructionIndex * 4
    }
}

public struct AotBranchDataPayloadRecordExtended: LayoutWrapper, Sendable {
    public typealias Layout = aot_branch_data_payload_record_extended

    public var layout: Layout
}

extension AotBranchDataPayloadRecordExtended {
    public var x86CodeBucketRelativeOffset: Int {
        numericCast(layout.x86_code_bucket_offset)
    }

    public var armCodeBucketRelativeInstructionIndex: Int {
        numericCast(layout.arm_code_bucket_instruction_index)
    }

    public var armCodeBucketRelativeOffset: Int {
        armCodeBucketRelativeInstructionIndex * 4
    }
}
