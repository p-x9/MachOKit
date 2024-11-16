//
//  MachOImage+static.swift
//
//
//  Created by p-x9 on 2024/02/06.
//
//

import Foundation

#if canImport(Darwin)
extension MachOImage {
    /// Sequence of loaded machO images.
    public static var images: AnySequence<MachOImage> {
        AnySequence(
            (0..<_dyld_image_count())
                .lazy
                .map { _dyld_get_image_header($0) }
                .map {
                    MachOImage(ptr: $0)
                }
        )
    }
}

extension MachOImage {
    /// Obtains the symbol closest to the specified address.
    ///
    /// Finds the symbol closest to the specified address among all loaded machO images.
    /// - Parameters:
    ///   - address: Addresses to search
    ///   - isGlobalOnly: A Boolean value that indicates whether to look for global symbols only (or to look for local symbols as well)
    /// - Returns: The closest symbol and the machO image to which it belongs.
    public static func closestSymbol(
        at address: UnsafeRawPointer,
        isGlobalOnly: Bool = false
    ) -> (MachOImage, Symbol)? {
        for image in images where image.contains(address) {
            if let symbol = image.closestSymbol(
                at: address,
                isGlobalOnly: isGlobalOnly
            ) {
                return (image, symbol)
            }
        }

        var closestImage: MachOImage?
        var leastDistance: Int?
        for image in images {
            let address = Int(bitPattern: address)
            guard let distance = leastDistance else {
                if let range = image.addressRange {
                    closestImage = image
                    leastDistance = min(
                        abs(range.lowerBound - address),
                        abs(range.upperBound - address)
                    )
                }
                continue
            }

            guard let range = image.addressRange else {
                continue
            }

            let newDistance = min(
                abs(range.lowerBound - address),
                abs(range.upperBound - address)
            )
            if newDistance < distance {
                leastDistance = newDistance
                closestImage = image
            }
        }

        guard let closestImage,
              let symbol = closestImage.closestSymbol(
                at: address,
                isGlobalOnly: isGlobalOnly
              ) else {
            return nil
        }
        return (closestImage, symbol)
    }

    /// Obtains the symbol that exist at the specified address.
    ///
    /// Finds the symbol that exist at the specified address among all loaded machO images.
    /// - Parameters:
    ///   - address: Addresses to search
    ///   - isGlobalOnly: A Boolean value that indicates whether to look for global symbols only (or to look for local symbols as well)
    /// - Returns: The matched symbol and the machO image to which it belongs.
    public static func symbol(
        for address: UnsafeRawPointer,
        isGlobalOnly: Bool = false
    ) -> (MachOImage, Symbol)? {
        for image in images where image.contains(address) {
            if let symbol = image.symbol(
                for: address,
                isGlobalOnly: isGlobalOnly
            ) {
                return (image, symbol)
            }
        }
        return nil
    }

    /// Obtains symbols matching the specified name.
    /// - Parameters:
    ///   - name: symbol name to search
    ///   - mangled: A boolean value that indicates whether the specified symbol name is mangled or not.
    /// - Returns: Sequence of matched symbols and machO images.
    public static func symbols(
        named name: String,
        mangled: Bool = true
    ) -> AnySequence<(MachOImage, [Symbol])> {
        AnySequence(
            images
                .lazy
                .compactMap {
                    let symbols = $0.symbols(named: name, mangled: mangled)
                    guard !symbols.isEmpty else {
                        return nil
                    }
                    return ($0, symbols)
                }
        )
    }

    /// Obtains symbols matching the specified name.
    /// - Parameters:
    ///   - name: symbol name to search
    ///   - mangled: A boolean value that indicates whether the specified symbol name is mangled or not.
    /// - Returns: Sequence of matched symbols and machO images.
    @available(*, deprecated, renamed: "symbols(named:mangled:)", message: "Please use a new function that returns as an symbol array")
    @_disfavoredOverload
    public static func symbols(
        named name: String,
        mangled: Bool = true
    ) -> AnySequence<(MachOImage, Symbol)> {
        AnySequence(
            symbols(named: name, mangled: mangled)
                .flatMap { machO, symbols in
                    symbols.map {
                        (machO, $0)
                    }
                }
        )
    }
}

fileprivate extension MachOImage {
    var addressRange: ClosedRange<Int>? {
        let segments = self.segments
        guard let slide = vmaddrSlide,
              let start = segments.first?.startPtr(vmaddrSlide: slide),
              let end = segments.last?.endPtr(vmaddrSlide: slide) else {
            return nil
        }
        return Int(bitPattern: start) ... Int(bitPattern: end)
    }

    func contains(_ address: UnsafeRawPointer) -> Bool {
        guard let addressRange else { return false }
        let address = Int(bitPattern: address)
        return addressRange.contains(address)
    }
}
#endif
