//
//  CodeSignProtocol.swift
//
//
//  Created by p-x9 on 2024/03/10.
//  
//

import Foundation

public protocol CodeSignProtocol {
    var superBlob: CodeSignSuperBlob? { get }
    var codeDirectories: [CodeSignCodeDirectory] { get }
    var embeddedEntitlements: [String: Any]? { get }
    var embeddedDEREntitlementsData: Data? { get }
    var signatureData: Data? { get }
    var requirementsBlob: CodeSignSuperBlob? { get }
    var requirementsData: [Data] { get }

    /// Get blob data as `Data`
    /// - Parameters:
    ///   - superBlob: SuperBlob to which index belongs
    ///   - index: Index of the blob to be gotten
    ///   - includesGenericInfo: A boolean value that indicates whether the data defined in the ``CodeSignGenericBlob``, such as magic and length, are included or not.
    /// - Returns: Data of blob
    func blobData(
        in superBlob: CodeSignSuperBlob,
        at index: CodeSignBlobIndex,
        includesGenericInfo: Bool
    ) -> Data?
}
