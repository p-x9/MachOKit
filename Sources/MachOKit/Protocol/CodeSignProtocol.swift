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
    /// Sequence of code directories
    var codeDirectories: [CodeSignCodeDirectory] { get }
    /// Best hash type code directory
    var codeDirectory: CodeSignCodeDirectory? { get }
    /// Entitlements embedded in the MachO binary
    var embeddedEntitlements: [String: Any]? { get }
    /// DER-encoded entitlements data embedded in MachO binary
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

    /// Get indices of specified SuperBlob
    /// - Parameter superBlob: SuperBlob to get indices
    /// - Returns: indices of superBlob
    func blobIndices(
        of superBlob: CodeSignSuperBlob
    ) -> AnyRandomAccessCollection<CodeSignBlobIndex>
}

extension CodeSignProtocol {
    public var codeDirectory: CodeSignCodeDirectory? {
        codeDirectories.bestHashTyped
    }

    /// Entitlements data embedded in the MachO binary
    public var embeddedEntitlementsData: Data? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = blobIndices(of: superBlob)
        guard let index = blobIndices.first(
            where: { $0.type == .entitlements }
        ) else {
            return nil
        }
        return blobData(
            in: superBlob,
            at: index,
            includesGenericInfo: false
        )
    }

    /// Entitlements embedded in the MachO binary
    public var embeddedEntitlements: [String: Any]? {
        guard let embeddedEntitlementsData else {
            return nil
        }
        guard let entitlements = try? PropertyListSerialization.propertyList(
            from: embeddedEntitlementsData,
            format: nil
        ) else {
            return nil
        }
        return entitlements as? [String: Any]
    }

    /// DER-encoded entitlements data embedded in MachO binary
    public var embeddedDEREntitlementsData: Data? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = blobIndices(of: superBlob)
        guard let index = blobIndices.first(
            where: { $0.type == .der_entitlements }
        ) else {
            return nil
        }
        return blobData(
            in: superBlob,
            at: index,
            includesGenericInfo: false
        )
    }

    public var signatureData: Data? {
        guard let superBlob else {
            return nil
        }
        let blobIndices = blobIndices(of: superBlob)
        guard let index = blobIndices.first(
            where: { $0.type == .signatureslot }
        ) else {
            return nil
        }
        return blobData(
            in: superBlob,
            at: index,
            includesGenericInfo: false
        )
    }

    public var requirementsData: [Data] {
        guard let requirementsBlob else {
            return []
        }
        let indices = blobIndices(of: requirementsBlob)
        return indices.compactMap {
            blobData(
                in: requirementsBlob,
                at: $0,
                includesGenericInfo: true
            )
        }
    }
}
