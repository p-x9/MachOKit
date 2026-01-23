import Foundation

/// Represents a Mach-O file that may be a single-architecture Mach-O or a fat (universal) binary.
public enum File {
    /// single binary
    case machO(MachOFile)
    /// fat (universal) binary
    case fat(FatFile)
}

/// Errors that can occur while parsing or loading Mach-O files.
public enum MachOKitError: LocalizedError {
    case invalidMagic
    case invalidCpuType
}

/// Loads a Mach-O or fat (universal) binary from the specified file URL.
///
/// - Parameter url: The file URL to read.
/// - Returns: A parsed `File` representing either a Mach-O or fat binary.
/// - Throws: `MachOKitError.invalidMagic` when the magic value is not recognized,
///           or any error thrown while reading or parsing the file.
public func loadFromFile(url: URL) throws -> File {
    let fileHandle = try FileHandle(forReadingFrom: url)
    let magicRaw: UInt32 = fileHandle.read(offset: 0)

    guard let magic = Magic(rawValue: magicRaw) else {
        throw MachOKitError.invalidMagic
    }

    if magic.isFat {
        return .fat(try FatFile(url: url))
    } else {
        return .machO(try MachOFile(url: url))
    }
}
