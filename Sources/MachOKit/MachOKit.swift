import Foundation

public enum File {
    case machO(MachOFile)
    case fat(FatFile)
}

public func loadFromFile(url: URL) throws -> File {
    let fileHandle = try FileHandle(forReadingFrom: url)
    let magicRaw: UInt32 = fileHandle.read(offset: 0)

    guard let magic = Magic(rawValue: magicRaw) else {
        throw NSError() // FIXME: error
    }

    if magic.isFat {
        return .fat(try FatFile(url: url))
    } else {
        return .machO(try MachOFile(url: url))
    }
}
