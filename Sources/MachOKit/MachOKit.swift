import Foundation

public enum MachOKit {
    public enum File {
        case machO(MachOFile)
        case fat(FatFile)
    }

    static func loadFromFile(url: URL) throws -> File {
        let fileHandle = try FileHandle(forReadingFrom: url)
        let magicData = fileHandle.readData(ofLength: 4)
        let magicRaw = magicData.withUnsafeBytes { $0.load(as: UInt32.self) }

        guard let magic = Magic(rawValue: magicRaw) else {
            throw NSError() // FIXME: error
        }

        if magic.isFat {
            return .fat(try FatFile(url: url))
        } else {
            return .machO(try MachOFile(url: url))
        }
    }
}
