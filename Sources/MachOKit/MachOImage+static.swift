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
    /// The `MachOImage` instance of the image for which this function was called
    public static func current(
        _ dso: UnsafeRawPointer = #dsohandle
    ) -> MachOImage {
        .init(
            ptr: dso.assumingMemoryBound(to: mach_header.self)
        )
    }

    /// The `MachOImage` instance representing the current executable image.
    public static var currentExecutable: MachOImage {
        images.first(where: {
            $0.header.fileType == .execute
        })!
    }

    /// The `MachOImage` instance containing the specified memory address.
    ///
    /// This method searches through all loaded Mach-O images and returns the one that contains  the specified address within its range.
    /// If no matching image is found, the method returns `nil`.
    ///
    /// - Parameter address: The memory address to search.
    /// - Returns: A `MachOImage` instance if an image containing the address is found; otherwise, `nil`.
    public static func image(
        for address: UnsafeRawPointer
    ) -> MachOImage? {
        guard let header = dyld_image_header_containing_address(address) else {
            return nil
        }
        return .init(ptr: header)
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
        if let image = image(containing: address),
           let symbol = image.closestSymbol(
            at: address,
            isGlobalOnly: isGlobalOnly
           ) {
            return (image, symbol)
        }
        guard let closestImage = closestImage(at: address),
              let symbol = closestImage.closestSymbol(
                at: address,
                isGlobalOnly: isGlobalOnly
              ) else {
            return nil
        }
        return (closestImage, symbol)
    }

    /// Obtains the symbols closest to the specified address.
    ///
    /// Finds the symbol closest to the specified address among all loaded machO images.
    /// - Parameters:
    ///   - address: Addresses to search
    ///   - isGlobalOnly: A Boolean value that indicates whether to look for global symbols only (or to look for local symbols as well)
    /// - Returns: The closest symbols and the machO image to which it belongs.
    public static func closestSymbols(
        at address: UnsafeRawPointer,
        isGlobalOnly: Bool = false
    ) -> (MachOImage, [Symbol])? {
        if let image = image(containing: address) {
            let symbols = image.closestSymbols(
                at: address,
                isGlobalOnly: isGlobalOnly
            )
            if !symbols.isEmpty {
                return (image, symbols)
            }
        }

        guard let closestImage = closestImage(at: address) else {
            return nil
        }
        let symbols = closestImage.closestSymbols(
            at: address,
            isGlobalOnly: isGlobalOnly
        )
        guard !symbols.isEmpty else {
            return nil
        }
        return (closestImage, symbols)
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
        guard let image = image(containing: address) else {
            return nil
        }
        if let symbol = image.symbol(
            for: address,
            isGlobalOnly: isGlobalOnly
        ) {
            return (image, symbol)
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
    ///   - isGlobalOnly: If true, search only global symbols.
    /// - Returns: Sequence of matched symbols and machO images.
    public static func symbols(
        named name: String,
        mangled: Bool = true,
        isGlobalOnly: Bool = false
    ) -> AnySequence<(MachOImage, Symbol)> {
        AnySequence(
            images
                .lazy
                .compactMap {
                    guard let symbol = $0.symbol(
                        named: name,
                        mangled: mangled,
                        isGlobalOnly: isGlobalOnly
                    ) else {
                        return nil
                    }
                    return ($0, symbol)
                }
        )
    }
}

fileprivate extension MachOImage {
    static func image(containing ptr: UnsafeRawPointer) -> MachOImage? {
        for image in images {
            if image.contains(ptr: ptr) {
                return image
            }
        }
        return nil
    }

    static func closestImage(
        at ptr: UnsafeRawPointer
    ) -> MachOImage? {
        var bestDistance: Int?
        var result: MachOImage?

        for image in images {
            guard let distance = image.distanceToClosestSegment(from: ptr) else {
                continue
            }
            if distance < bestDistance ?? .max {
                bestDistance = distance
                result = image
            }
        }
        return result
    }
}

fileprivate extension MachOImage {
    func distanceToClosestSegment(
        from ptr: UnsafeRawPointer
    ) -> Int? {
        let slide = vmaddrSlide ?? 0
        let address = Int(bitPattern: ptr)
        if slide > address { return nil }

        let unslidAddress = address - slide

        var bestDistance: Int?
        for segment in segments {
            if segment.contains(unslidAddress: numericCast(unslidAddress)) {
                return 0
            }
            let distance = min(
                abs(segment.virtualMemoryAddress - unslidAddress),
                abs(segment.virtualMemoryAddress + segment.virtualMemorySize - unslidAddress)
            )
            if distance < bestDistance ?? .max {
                bestDistance = distance
            }
        }
        return bestDistance
    }

}
#endif
