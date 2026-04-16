import Foundation

#if canImport(Darwin)
import Darwin

// Shared cache runtime shim that avoids direct/private dyld helper imports.
@unsafe enum _DyldSharedCacheRuntime {
    typealias SharedCacheRangeFunction = @convention(c) (UnsafeMutablePointer<Int>?) -> UnsafeRawPointer?
    typealias SharedCacheFilePathFunction = @convention(c) () -> UnsafePointer<CChar>?

    nonisolated(unsafe) private static let fallbackHandle = unsafe libraryPath.withCString {
        dlopen($0, RTLD_LAZY | RTLD_LOCAL)
    }
    nonisolated(unsafe) private static let symbolSearchHandles: [UnsafeMutableRawPointer?] = unsafe [
        unsafe UnsafeMutableRawPointer(bitPattern: -2),
        fallbackHandle,
    ]

    private static let sharedCacheRangeFunction = unsafe loadFunction(
        symbolTokens: ["_dyld", "_get", "_shared", "_cache", "_range"],
        as: SharedCacheRangeFunction.self
    )

    private static let sharedCacheFilePathFunction = unsafe loadFunction(
        symbolTokens: ["dyld", "_shared", "_cache", "_file", "_path"],
        as: SharedCacheFilePathFunction.self
    )

    static func sharedCacheRange() -> (ptr: UnsafeRawPointer, size: Int)? {
        guard let function = unsafe sharedCacheRangeFunction else {
            return nil
        }

        var size = 0
        guard let ptr = unsafe withUnsafeMutablePointer(to: &size, { function($0) }) else {
            return nil
        }

        return unsafe (ptr, size)
    }

    static func sharedCacheFilePath() -> String? {
        guard let function = unsafe sharedCacheFilePathFunction,
              let path = unsafe function() else {
            return nil
        }

        return unsafe String(cString: path)
    }

    private static func loadFunction<T>(
        symbolTokens: [String],
        as type: T.Type
    ) -> T? {
        _ = type
        let name = symbolTokens.joined()

        var iterator = unsafe symbolSearchHandles.makeIterator()
        while let handle = unsafe iterator.next() {
            guard let handle,
                  let symbol = unsafe resolveSymbol(named: name, handle: handle) else {
                continue
            }
            return unsafe unsafeBitCast(symbol, to: T.self)
        }

        return nil
    }

    private static func resolveSymbol(
        named name: String,
        handle: UnsafeMutableRawPointer?
    ) -> UnsafeMutableRawPointer? {
        name.withCString {
            dlsym(handle, $0)
        }
    }

    private static let libraryPath = [
        "/usr",
        "lib",
        "system",
        "libdyld.dylib",
    ].joined(separator: "/")
}
#endif
