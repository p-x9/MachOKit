//
//  DyldChainedFixupsProtocol.swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

public protocol DyldChainedFixupsProtocol {
    var header: DyldChainedFixupsHeader? { get }
    var startsInImage: DyldChainedStartsInImage? { get }
    var imports: [DyldChainedImport] { get }

    func startsInSegments(
        of startsInImage: DyldChainedStartsInImage?
    ) -> [DyldChainedStartsInSegment]

    func pages(
        of startsInSegment: DyldChainedStartsInSegment?
    ) -> [DyldChainedPage]

    func symbolName(for nameOffset: Int) -> String?
}
