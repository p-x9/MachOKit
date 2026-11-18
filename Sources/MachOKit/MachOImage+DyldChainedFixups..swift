//
//  MachOImage+DyldChainedFixups..swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

extension MachOImage {
    public struct DyldChainedFixups {
        public let basePointer: UnsafePointer<UInt8>
        public let dyldChainedFixupsSize: Int
    }
}

extension MachOImage.DyldChainedFixups {
    init?(
        dyldChainedFixups: linkedit_data_command,
        linkedit: SegmentCommand64,
        vmaddrSlide: Int
    ) {
        guard let linkeditStartPtr = linkedit.startPtr(
            vmaddrSlide: vmaddrSlide
        ) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: -numericCast(linkedit.fileoff))
            .advanced(by: numericCast(dyldChainedFixups.dataoff))
            .assumingMemoryBound(to: UInt8.self)
        let size: Int = numericCast(dyldChainedFixups.datasize)

        self.init(
            basePointer: start,
            dyldChainedFixupsSize: size
        )
    }

    init?(
        dyldChainedFixups: linkedit_data_command,
        linkedit: SegmentCommand,
        vmaddrSlide: Int
    ) {
        guard let linkeditStartPtr = linkedit.startPtr(
            vmaddrSlide: vmaddrSlide
        ) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: -numericCast(linkedit.fileoff))
            .advanced(by: numericCast(dyldChainedFixups.dataoff))
            .assumingMemoryBound(to: UInt8.self)
        let size: Int = numericCast(dyldChainedFixups.datasize)

        self.init(
            basePointer: start,
            dyldChainedFixupsSize: size
        )
    }
}

extension MachOImage.DyldChainedFixups: DyldChainedFixupsProtocol {
    private var payload: DyldChainedFixupsPayload {
        .init(bytes: .init(start: basePointer, count: dyldChainedFixupsSize), isSwapped: false)
    }

    public var header: DyldChainedFixupsHeader? { payload.header }
    public var startsInImage: DyldChainedStartsInImage? { payload.startsInImage }
    public var imports: [DyldChainedImport] { payload.imports }

    public func startsInSegments(
        of startsInImage: DyldChainedStartsInImage?
    ) -> [DyldChainedStartsInSegment] {
        payload.startsInSegments(of: startsInImage)
    }

    public func pages(of startsInSegment: DyldChainedStartsInSegment?) -> [DyldChainedPage] {
        payload.pages(of: startsInSegment)
    }

    public func symbolName(for nameOffset: Int) -> String? {
        payload.symbolName(for: nameOffset)
    }
}
