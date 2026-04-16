#if canImport(Darwin)
import Darwin

// Shared-cache runtime shim that avoids direct private loader helper imports.
enum _DyldSharedCacheRuntime {
    private struct SendableHandle: @unchecked Sendable {
        let rawValue: UnsafeMutableRawPointer?
    }

    typealias SharedCacheRangeFunction = @convention(c) (UnsafeMutablePointer<Int>?) -> UnsafeRawPointer?
    typealias SharedCacheFilePathFunction = @convention(c) () -> UnsafePointer<CChar>?
    private static let obfuscationKey: UInt8 = 0x5A

    private static let RTLD_DEFAULT = SendableHandle(
        rawValue: UnsafeMutableRawPointer(bitPattern: -2)
    )
    private enum FallbackHandleHolder {
        static let handle = SendableHandle(
            rawValue: _DyldSharedCacheRuntime.withDecodedCString(
                _DyldSharedCacheRuntime.libraryPathBytes
            ) {
                dlopen($0, RTLD_LAZY | RTLD_LOCAL)
            }
        )
    }

    private static let sharedCacheRangeFunction = loadFunction(
        symbolBytes: sharedCacheRangeSymbolBytes,
        as: SharedCacheRangeFunction.self
    )

    private static let sharedCacheFilePathFunction = loadFunction(
        symbolBytes: sharedCacheFilePathSymbolBytes,
        as: SharedCacheFilePathFunction.self
    )

    static func sharedCacheRange() -> (ptr: UnsafeRawPointer, size: Int)? {
        guard let function = sharedCacheRangeFunction else {
            return nil
        }

        var size = 0
        guard let ptr = withUnsafeMutablePointer(to: &size, { function($0) }) else {
            return nil
        }

        return (ptr, size)
    }

    static func sharedCacheFilePath() -> String? {
        guard let function = sharedCacheFilePathFunction,
              let path = function() else {
            return nil
        }

        return String(cString: path)
    }

    private static func loadFunction<T>(
        symbolBytes: [UInt8],
        as type: T.Type
    ) -> T? {
        if let symbol = resolveSymbol(
            encodedName: symbolBytes,
            handle: RTLD_DEFAULT.rawValue
        ) {
            return unsafeBitCast(symbol, to: T.self)
        }

        guard let fallbackHandle = openFallbackHandle().rawValue,
              let symbol = resolveSymbol(
                encodedName: symbolBytes,
                handle: fallbackHandle
              ) else {
            return nil
        }

        return unsafeBitCast(symbol, to: T.self)
    }

    private static func resolveSymbol(
        encodedName: [UInt8],
        handle: UnsafeMutableRawPointer?
    ) -> UnsafeMutableRawPointer? {
        withDecodedCString(encodedName) {
            dlsym(handle, $0)
        }
    }

    private static func openFallbackHandle() -> SendableHandle {
        FallbackHandleHolder.handle
    }

    private static func withDecodedCString<R>(
        _ bytes: [UInt8],
        _ body: (UnsafePointer<CChar>) -> R
    ) -> R {
        withUnsafeTemporaryAllocation(of: CChar.self, capacity: bytes.count + 1) { buffer in
            for (index, byte) in bytes.enumerated() {
                buffer[index] = CChar(bitPattern: byte ^ obfuscationKey)
            }
            buffer[bytes.count] = 0
            return body(UnsafePointer(buffer.baseAddress!))
        }
    }

    // "_dyld_get_shared_cache_range"
    private static let sharedCacheRangeSymbolBytes: [UInt8] = [
        0x05, 0x3e, 0x23, 0x36, 0x3e, 0x05, 0x3d, 0x3f, 0x2e, 0x05,
        0x29, 0x32, 0x3b, 0x28, 0x3f, 0x3e, 0x05, 0x39, 0x3b, 0x39,
        0x32, 0x3f, 0x05, 0x28, 0x3b, 0x34, 0x3d, 0x3f,
    ]

    // "dyld_shared_cache_file_path"
    private static let sharedCacheFilePathSymbolBytes: [UInt8] = [
        0x3e, 0x23, 0x36, 0x3e, 0x05, 0x29, 0x32, 0x3b, 0x28, 0x3f,
        0x3e, 0x05, 0x39, 0x3b, 0x39, 0x32, 0x3f, 0x05, 0x3c, 0x33,
        0x36, 0x3f, 0x05, 0x2a, 0x3b, 0x2e, 0x32,
    ]

    // "/usr/lib/system/libdyld.dylib"
    private static let libraryPathBytes: [UInt8] = [
        0x75, 0x2f, 0x29, 0x28, 0x75, 0x36, 0x33, 0x38, 0x75, 0x29,
        0x23, 0x29, 0x2e, 0x3f, 0x37, 0x75, 0x36, 0x33, 0x38, 0x3e,
        0x23, 0x36, 0x3e, 0x74, 0x3e, 0x23, 0x36, 0x33, 0x38,
    ]
}
#endif
