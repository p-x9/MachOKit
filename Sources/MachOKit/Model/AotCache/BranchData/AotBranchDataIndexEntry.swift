//
//  AotBranchDataIndexEntry.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/18
//  
//

import MachOKitC

public struct AotBranchDataIndexEntry: LayoutWrapper, Sendable {
    public typealias Layout = aot_branch_data_index_entry

    public var layout: Layout
}

extension AotBranchDataIndexEntry: AotBranchDataPayloadEntry {
    public static let x86CodeBucketSize = 0x100
    public static let armCodeBucketSize = 0x400

    public var x86CodeBucket: Int {
        numericCast(layout.x86_code_bucket)
    }

    public var armCodeBucket: Int {
        numericCast(layout.arm_code_bucket)
    }

    public var payloadRecordCount: Int {
        numericCast(layout.payload_record_count)
    }

    public var payloadRecordOffset: Int {
        numericCast(layout.payload_record_offset)
    }
}

public struct AotBranchDataIndexEntryCompact: LayoutWrapper, Sendable {
    public typealias Layout = aot_branch_data_index_entry_compact

    public var layout: Layout
}

extension AotBranchDataIndexEntryCompact: AotBranchDataPayloadEntry {
    public static let x86CodeBucketSize = 0x100
    public static let armCodeBucketSize = 0x400

    public var x86CodeBucket: Int {
        numericCast(layout.x86_code_bucket)
    }

    public var armCodeBucket: Int {
        numericCast(layout.arm_code_bucket)
    }

    public var payloadRecordCount: Int {
        numericCast(layout.payload_record_count)
    }

    public var payloadRecordOffset: Int {
        numericCast(layout.payload_record_offset)
    }
}

public struct AotBranchDataIndexEntryExtended: LayoutWrapper, Sendable {
    public typealias Layout = aot_branch_data_index_entry_extended

    public var layout: Layout
}

extension AotBranchDataIndexEntryExtended: AotBranchDataPayloadEntry {
    public static let x86CodeBucketSize = 0x10000
    public static let armCodeBucketSize = 0x40000

    public var x86CodeBucket: Int {
        numericCast(layout.x86_code_bucket)
    }

    public var armCodeBucket: Int {
        numericCast(layout.arm_code_bucket)
    }

    public var payloadRecordCount: Int {
        numericCast(layout.payload_record_count)
    }

    public var payloadRecordOffset: Int {
        numericCast(layout.payload_record_offset)
    }
}

protocol AotBranchDataPayloadEntry {
    static var x86CodeBucketSize: Int { get }
    static var armCodeBucketSize: Int { get }

    var x86CodeBucket: Int { get }
    var armCodeBucket: Int { get }

    var payloadRecordCount: Int { get }
    var payloadRecordOffset: Int { get }
}

extension AotBranchDataPayloadEntry {
    public var x86CodeBucketOffset: Int {
        x86CodeBucket * Self.x86CodeBucketSize
    }

    public var armCodeBucketOffset: Int {
        armCodeBucket * Self.armCodeBucketSize
    }
}
