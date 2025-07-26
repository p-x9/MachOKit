# MachOKit

Library for parsing MachO files to obtain various information.

In addition to file reading, parsing of images in memory by `_dyld_get_image_header` is also supported.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/MachOKit)](https://github.com/p-x9/MachOKit/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/MachOKit)](https://github.com/p-x9/MachOKit/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/MachOKit)](https://github.com/p-x9/MachOKit/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/MachOKit)](https://github.com/p-x9/MachOKit/)

## Features

- parse load commands
- symbol list
- get all cstrings
- rebase operations
- binding operations
- export tries
- ...

## Usage

### Load from memory

For reading from memory, use the `MachOImage` structure.

It can be initialized by using the Mach-O Header pointer obtained by `_dyld_get_image_header`.

```swift
guard let mh = _dyld_get_image_header(0) else { return }
let machO = MachOImage(ptr: mh)
```

Alternatively, it can be initialized using the name.

```swift
// /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
guard let machO = MachOImage(name: "Foundation") else { return }
```

### Load from file

For reading from file, use the `MachOFile` structure.

Reading from a file can be as follows.
There is a case of a Fat file and a single MachO file, so a conditional branching process is required.

```swift
let path = "Path to MachO file"
let url = URL(string: path)

let file = try MachOKit.loadFromFile(url: url)

switch file {
case .machO(let machOFile): // single MachO file
    print(machOFile)
case .fat(let fatFile): // Fat file
    let machOFiles = try fatFile.machOFiles()
    print(machOFiles)
}
```

### Main properties and methods

Both `MachOImage` and `MachOFile` can use essentially the same properties and methods.
The available methods are defined in the following file as the `MachORepresentable` protocol.

[MachORepresentable](./Sources/MachOKit/Protocol/MachORepresentable.swift)

### Dyld Cache

Loading of `dyld_shared_cache` is also supported.

The available methods are defined in the following file as the `DyldCacheRepresentable` protocol.

[DyldCacheRepresentable](./Sources/MachOKit/Protocol/DyldCacheRepresentable.swift)

#### Dyld Cache (File)

```swift
let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e"
let url = URL(fileURLWithPath: path)

let cache = try! DyldCache(url: url)
```

It is also possible to extract machO information contained in `dyld_shared_cache`.
The machO extracted is of type `MachOFile`.
As with reading from a single MachO file, various analyses are possible.

```swift
let machOs = cache.machOFiles()
for machO in machOs {
    print(
        String(machO.headerStartOffsetInCache, radix: 16),
        machO.imagePath,
        machO.header.ncmds
    )
}

// 5c000 /usr/lib/libobjc.A.dylib 22
// 98000 /usr/lib/dyld 15
// 131000 /usr/lib/system/libsystem_blocks.dylib 24
// ...
```

#### Full Dyld Cache (File)

In addition to `DyldCache`, `FullDyldCache` can be used to handle multiple dyld cache files (main cache and subcaches) as a single unified cache.

```swift
let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e"
let url = URL(fileURLWithPath: path)

let fullCache = try! FullDyldCache(url: url)

// Access all Mach-O files across main and subcaches
let machOs = fullCache.machOFiles()
for machO in machOs {
    print(
        String(machO.headerStartOffsetInCache, radix: 16),
        machO.imagePath,
        machO.header.ncmds
    )
}
```
The `FullDyldCache` type provides properties like `mainCache`, `subCaches`, `allCaches`, and `urls` to access each component cache file.

#### Dyld Cache (on memory)

On the Apple platform, the dyld cache is deployed in memory.

```swift
var size = 0
guard let ptr = _dyld_get_shared_cache_range(&size) else {
    return
}
let cache = try! DyldCacheLoaded(ptr: ptr)
```

It is also possible to extract machO information contained in `dyld_shared_cache`.
The machO extracted is of type `MachOImage`.
As with reading from a single MachO image, various analyses are possible.

```swift
let machOs = cache.machOImages()
for machO in machOs {
    print(
        String(Int(bitPattern: machO.ptr), radix: 16),
        machO.path!,
        machO.header.ncmds
    )
}

// 193438000 /usr/lib/libobjc.A.dylib 24
// 193489000 /usr/lib/dyld 15
// 193513000 /usr/lib/system/libsystem_blocks.dylib 24
// ...
```

### Example Codes

There are a variety of uses, but most show a basic example that prints output to the Test directory.

#### Load from memory

The following file contains sample code.
[MachOPrintTests](./Tests/MachOKitTests/MachOPrintTests.swift)

#### Load from file

The following file contains sample code.
[MachOFilePrintTests](./Tests/MachOKitTests/MachOFilePrintTests.swift)

#### Dyld Cache (file)

The following file contains sample code.
[DyldCachePrintTests](./Tests/MachOKitTests/DyldCachePrintTests.swift)

#### Dyld Cache (on memory)

The following file contains sample code.
[DyldCacheLoadedPrintTests](./Tests/MachOKitTests/DyldCacheLoadedPrintTests.swift)

## Related Projects

- [MachOKitSPM](https://github.com/p-x9/MachOKit-SPM)
    Pre-built version of MachOKit
- [SwiftHook](https://github.com/p-x9/swift-hook)
    ⚓️ A Swift Library for hooking swift methods and functions.
- [FishHook](https://github.com/p-x9/swift-fishhook)
    Re-implementation of [facebook/fishhook](https://github.com/facebook/fishhook) with Swift using MachOKit
- [AntiFishHook](https://github.com/p-x9/swift-anti-fishhook)
    A Swift library to deactivate fishhook. (Anti-FishHook)

### Other binary type
- [ELFKit](https://github.com/p-x9/ELFKit)
    Elf format

## License

MachOKit is released under the MIT License. See [LICENSE](./LICENSE)
