//
//  ObjCStub.swift
//  MachOKit
//

import Foundation

/// A decoded Objective-C message-send stub.
public struct ObjCStub: Sendable, Equatable {
    /// The decoded branch portion of the Objective-C stub.
    public let stub: Stub

    /// The unslid virtual memory address of the selector reference loaded into `x1`.
    ///
    /// This is `nil` when the selector-loading instructions are not recognized.
    public let selectorReference: UInt64?

    public init(stub: Stub, selectorReference: UInt64?) {
        self.stub = stub
        self.selectorReference = selectorReference
    }
}

extension ObjCStub {
    /// Resolves the selector reference and returns its selector name.
    public func selector(in machO: MachOFile) -> String? {
        guard let selectorReference else { return nil }
        if machO.isLoadedFromDyldCache {
            if let cache = machO.cache,
               let selector = selector(in: cache) {
                return selector
            }
            guard let fullCache = machO.fullCache else { return nil }
            return selector(in: fullCache)
        }

        let referenceEnd = selectorReference + UInt64(MemoryLayout<UInt64>.size - 1)
        guard let relativeReferenceOffset = machO.fileOffset(of: selectorReference),
              machO.fileOffset(of: referenceEnd) != nil else {
            return nil
        }
        let referenceOffset = UInt64(machO.headerStartOffset) + relativeReferenceOffset
        let rawTarget: UInt64 = machO.fileHandle.read(offset: referenceOffset)

        let target: UInt64
        if let rebased = machO.resolveRebase(at: relativeReferenceOffset) {
            guard let preferredLoadAddress = machO.preferredLoadAddress,
                  !preferredLoadAddress.addingReportingOverflow(rebased).overflow else {
                return nil
            }
            target = preferredLoadAddress + rebased
        } else {
            target = rawTarget
        }

        guard let relativeStringOffset = machO.fileOffset(
            of: machO.stripPointerTags(of: target)
        ) else {
            return nil
        }
        let stringOffset = UInt64(machO.headerStartOffset) + relativeStringOffset
        return machO.fileHandle.readString(offset: stringOffset)
    }

    /// Resolves the loaded selector reference and returns its selector name.
    public func selector(in machO: MachOImage) -> String? {
        guard let selectorReference else { return nil }
        let referenceEnd = selectorReference + UInt64(MemoryLayout<UInt64>.size - 1)
        guard machO.contains(unslidAddress: selectorReference),
              machO.contains(unslidAddress: referenceEnd),
              let slide = machO.vmaddrSlide,
              let runtimeAddress = adding(slide, to: selectorReference),
              let reference = UnsafeRawPointer(bitPattern: UInt(runtimeAddress)) else {
            return nil
        }

        let target = reference.loadUnaligned(as: UInt64.self)
        let targetAddress = machO.stripPointerTags(of: target)
        // dyld may replace a selector reference with a canonical selector
        // string in the shared cache, outside this Mach-O image.
        guard let pointer = UnsafePointer<CChar>(bitPattern: UInt(targetAddress)) else {
            return nil
        }
        return String(validatingCString: pointer)
    }
}

extension ObjCStub {
    private func selector<Cache: _DyldCacheFileRepresentable>(
        in cache: Cache
    ) -> String? {
        guard let selectorReference else { return nil }
        guard let referenceOffset = cache.fileOffset(of: selectorReference),
              let target = cache._resolveRebase(
                  at: referenceOffset,
                  skipsZeroValue: true
              ),
              let stringOffset = cache.fileOffset(of: target) else {
            return nil
        }
        return cache.fileHandle.readString(offset: stringOffset)
    }

    private func adding(_ delta: Int, to address: UInt64) -> UInt64? {
        if delta >= 0 {
            let (result, overflow) = address.addingReportingOverflow(UInt64(delta))
            return overflow ? nil : result
        }
        let (result, overflow) = address.subtractingReportingOverflow(UInt64(delta.magnitude))
        return overflow ? nil : result
    }
}
