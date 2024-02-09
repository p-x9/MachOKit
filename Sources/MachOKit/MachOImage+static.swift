//
//  MachOImage+static.swift
//
//
//  Created by p-x9 on 2024/02/06.
//  
//

import Foundation
import MachO

extension MachOImage {
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
    public static func closestSymbol(
        at address: UnsafeRawPointer
    ) -> (MachOImage, Symbol)? {
        for image in images where image.contains(address) {
            if let symbol = image.closestSymbol(at: address) {
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
              let symbol = closestImage.closestSymbol(at: address) else {
            return nil
        }
        return (closestImage, symbol)
    }

    public static func symbol(
        for address: UnsafeRawPointer
    ) -> (MachOImage, Symbol)? {
        for image in images where image.contains(address) {
            if let symbol = image.symbol(for: address) {
                return (image, symbol)
            }
        }
        return nil
    }

    public static func symbols(
        named name: String,
        mangled: Bool = true
    ) -> [(MachOImage, Symbol)] {
        images.compactMap {
            guard let symbol = $0.symbol(named: name, mangled: mangled) else {
                return nil
            }
            return ($0, symbol)
        }
    }
}

fileprivate extension MachOImage {
    var addressRange: ClosedRange<Int>? {
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
