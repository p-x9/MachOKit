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
        var symbols = [(Int, (MachOImage, Symbol))]()
        for image in images {

            if let symbol = image.closestSymbol(at: address) {
                let actual = image.ptr.advanced(by: symbol.offset)
                if actual == address || image.contains(address) {
                    print(image.contains(address))
                    return (image, symbol)
                }
                let diff = Int(bitPattern: actual) - Int(bitPattern: address)
                symbols.append((diff, (image, symbol)))
            }
        }
        return symbols.min(
            by: { lhs, rhs in
                lhs.0 < rhs.0
            }
        )?.1
    }

    public static func symbol(
        for address: UnsafeRawPointer
    ) -> (MachOImage, Symbol)? {
        for image in images {
            if let symbol = image.symbol(for: address) {
                return (image, symbol)
            }
        }
        return nil
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
