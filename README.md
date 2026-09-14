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

### UI-friendly labels

`MachOKit` keeps `description` values close to C header constants (for example `LC_MAIN`).
If you need user-facing labels, import `MachOKitReadable` and use `readableDescription`.

```swift
import MachOKit
import MachOKitReadable

let type = FileType.execute
print(type.description)           // MH_EXECUTE
print(type.readableDescription)   // Executable
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
- [dyld-shared-cache-extractor](https://github.com/swiftbin/dyld-shared-cache-extractor)
    A CLI tool to extract dylib from dyld_shared_cache
- [inject-o](https://github.com/swiftbin/inject-o)
    A CLI tool for injecting dependent dylibs into the Mach-O file.

### Runtime Metadata

Utilities for extracting higher-level language metadata from Mach-O binaries.

- [MachOObjCSection](https://github.com/p-x9/MachOObjCSection)
    Objective-C metadata parser for classes, methods, protocols, properties, categories, and related runtime structures.

- [MachOSwiftSection](https://github.com/MxIris-Reverse-Engineering/MachOSwiftSection)
    Swift metadata parser for types, protocols, protocol conformances, and other Swift runtime information.
    (Developed by [Mx-Iris](https://github.com/Mx-Iris).)

### Debug Information

- [swift-dwarf](https://github.com/p-x9/swift-dwarf)
    A Swift library for parsing DWARF debug information.

### Other binary type

- [ELFKit](https://github.com/p-x9/ELFKit)
    Elf format
- [PEKit](https://github.com/p-x9/PEKit)
    PE/COFF format

## License

MachOKit is released under the MIT License. See [LICENSE](./LICENSE)


## 🌐 Web Resources & Aesthetic Symbols Index
- [SYM 1F625](https://aestheticsymbols.io/symbol/sym-1f625/)
- [ROBLOX NAMES](https://aestheticsymbols.io/ja/roblox-names/)
- [HEARTS](https://aestheticsymbols.io/es/hearts/)
- [SYM 2655](https://aestheticsymbols.io/symbol/sym-2655/)
- [SYM 2688](https://aestheticsymbols.io/symbol/sym-2688/)
- [BORDERS DIVIDERS](https://aestheticsymbols.io/borders-dividers/)
- [SYM 26A2](https://aestheticsymbols.io/symbol/sym-26a2/)
- [NATURE FLOWERS](https://aestheticsymbols.io/vi/nature-flowers/)
- [SYM 26AC](https://aestheticsymbols.io/symbol/sym-26ac/)
- [BOLD TIPPED ARROW](https://aestheticsymbols.io/symbol/bold-tipped-arrow/)
- [HEARTS](https://aestheticsymbols.io/ru/hearts/)
- [SYM 1F49D](https://aestheticsymbols.io/symbol/sym-1f49d/)
- [SYM 1D438](https://aestheticsymbols.io/symbol/sym-1d438/)
- [CHEERING FIGHTING FIST KAOMOJI](https://aestheticsymbols.io/symbol/cheering-fighting-fist-kaomoji/)
- [NATURE FLOWERS](https://aestheticsymbols.io/pt/nature-flowers/)
- [SYM 1D410](https://aestheticsymbols.io/symbol/sym-1d410/)
- [SYM 1F606](https://aestheticsymbols.io/symbol/sym-1f606/)
- [SYM 1F62F](https://aestheticsymbols.io/symbol/sym-1f62f/)
- [SYM 1D419](https://aestheticsymbols.io/symbol/sym-1d419/)
- [SYM 26AD](https://aestheticsymbols.io/symbol/sym-26ad/)
- [SYM 2678](https://aestheticsymbols.io/symbol/sym-2678/)
- [ARROWS LINES](https://aestheticsymbols.io/es/arrows-lines/)
- [SYM 1D451](https://aestheticsymbols.io/symbol/sym-1d451/)
- [SYM 2721](https://aestheticsymbols.io/symbol/sym-2721/)
- [SYM 1F60A](https://aestheticsymbols.io/symbol/sym-1f60a/)
- [RU](https://aestheticsymbols.io/ru/)
- [SYM 1D473](https://aestheticsymbols.io/symbol/sym-1d473/)
- [SYM 1D448](https://aestheticsymbols.io/symbol/sym-1d448/)
- [SYM 1F47E](https://aestheticsymbols.io/symbol/sym-1f47e/)
- [SYM 265D](https://aestheticsymbols.io/symbol/sym-265d/)
- [SYM 1D464](https://aestheticsymbols.io/symbol/sym-1d464/)
- [STARS](https://aestheticsymbols.io/vi/stars/)
- [SYM 1F923](https://aestheticsymbols.io/symbol/sym-1f923/)
- [SYM 263A](https://aestheticsymbols.io/symbol/sym-263a/)
- [SYM 2671](https://aestheticsymbols.io/symbol/sym-2671/)
- [SYM 267E](https://aestheticsymbols.io/symbol/sym-267e/)
- [SYM 26B2](https://aestheticsymbols.io/symbol/sym-26b2/)
- [SYM 1F635 200D 1F4AB](https://aestheticsymbols.io/symbol/sym-1f635-200d-1f4ab/)
- [SYM 1D447](https://aestheticsymbols.io/symbol/sym-1d447/)
- [FREEFIRE NAMES](https://aestheticsymbols.io/es/freefire-names/)
- [SYM 1D446](https://aestheticsymbols.io/symbol/sym-1d446/)
- [SYM 1D458](https://aestheticsymbols.io/symbol/sym-1d458/)
- [HEAVY RIGHTWARD ARROW](https://aestheticsymbols.io/symbol/heavy-rightward-arrow/)
- [NATURE FLOWERS](https://aestheticsymbols.io/ja/nature-flowers/)
- [BORDERS DIVIDERS](https://aestheticsymbols.io/es/borders-dividers/)
- [SYM 2666](https://aestheticsymbols.io/symbol/sym-2666/)
- [SYM 2728](https://aestheticsymbols.io/symbol/sym-2728/)
- [SYM 2633](https://aestheticsymbols.io/symbol/sym-2633/)
- [SYM 26EE](https://aestheticsymbols.io/symbol/sym-26ee/)
- [BRACKETS](https://aestheticsymbols.io/ru/brackets/)
- [SYM 1F63D](https://aestheticsymbols.io/symbol/sym-1f63d/)
- [SYM 1F620](https://aestheticsymbols.io/symbol/sym-1f620/)
- [SYM 1F601](https://aestheticsymbols.io/symbol/sym-1f601/)
- [LEFT MATHEMATICAL WHITE SQUARE BRACKET](https://aestheticsymbols.io/symbol/left-mathematical-white-square-bracket/)
- [SYM 2615](https://aestheticsymbols.io/symbol/sym-2615/)
- [SYM 1F499](https://aestheticsymbols.io/symbol/sym-1f499/)
- [SYM 1D46D](https://aestheticsymbols.io/symbol/sym-1d46d/)
- [SYM 1D467](https://aestheticsymbols.io/symbol/sym-1d467/)
- [SYM 268F](https://aestheticsymbols.io/symbol/sym-268f/)
- [GAMING WEAPONS](https://aestheticsymbols.io/gaming-weapons/)
- [SYM 1D42A](https://aestheticsymbols.io/symbol/sym-1d42a/)
- [SYM 1D418](https://aestheticsymbols.io/symbol/sym-1d418/)
- [SYM 1D41A](https://aestheticsymbols.io/symbol/sym-1d41a/)
- [TRENDING](https://aestheticsymbols.io/pt/trending/)
- [SYM 1FAE0](https://aestheticsymbols.io/symbol/sym-1fae0/)
- [SYM 1D452](https://aestheticsymbols.io/symbol/sym-1d452/)
- [SYM 1F635](https://aestheticsymbols.io/symbol/sym-1f635/)
- [RIGHT BLACK LENTICULAR BRACKET](https://aestheticsymbols.io/symbol/right-black-lenticular-bracket/)
- [SYM 2684](https://aestheticsymbols.io/symbol/sym-2684/)
- [SYM 1D43A](https://aestheticsymbols.io/symbol/sym-1d43a/)
- [SYM 1F622](https://aestheticsymbols.io/symbol/sym-1f622/)
- [SYM 26ED](https://aestheticsymbols.io/symbol/sym-26ed/)
- [SYM 1D48C](https://aestheticsymbols.io/symbol/sym-1d48c/)
- [SYM 26F6](https://aestheticsymbols.io/symbol/sym-26f6/)
- [GEMINI ZODIAC TWINS](https://aestheticsymbols.io/symbol/gemini-zodiac-twins/)
- [FREEFIRE NAMES](https://aestheticsymbols.io/pt/freefire-names/)
- [ARROWS LINES](https://aestheticsymbols.io/ja/arrows-lines/)
- [SYM 2670](https://aestheticsymbols.io/symbol/sym-2670/)
- [SYM 1F649](https://aestheticsymbols.io/symbol/sym-1f649/)
- [SYM 2676](https://aestheticsymbols.io/symbol/sym-2676/)
- [SYM 1D449](https://aestheticsymbols.io/symbol/sym-1d449/)
- [SYM 2646](https://aestheticsymbols.io/symbol/sym-2646/)
- [AESTHETICSYMBOLS.IO](https://aestheticsymbols.io/)
- [SYM 267A](https://aestheticsymbols.io/symbol/sym-267a/)
- [AESTHETIC MINIMAL CLOUD](https://aestheticsymbols.io/symbol/aesthetic-minimal-cloud/)
- [SYM 2764 FE0F 200D 1F525](https://aestheticsymbols.io/symbol/sym-2764-fe0f-200d-1f525/)
- [LATIN CROSS FAITH](https://aestheticsymbols.io/symbol/latin-cross-faith/)
- [SYM 1D471](https://aestheticsymbols.io/symbol/sym-1d471/)
- [RADIOACTIVE SYMBOL](https://aestheticsymbols.io/symbol/radioactive-symbol/)
- [SYM 1F615](https://aestheticsymbols.io/symbol/sym-1f615/)
- [SYM 260B](https://aestheticsymbols.io/symbol/sym-260b/)
- [SYM 2636](https://aestheticsymbols.io/symbol/sym-2636/)
- [SYM 2680](https://aestheticsymbols.io/symbol/sym-2680/)
- [KAOMOJI](https://aestheticsymbols.io/pt/kaomoji/)
- [SYM 268B](https://aestheticsymbols.io/symbol/sym-268b/)
- [SYM 273D](https://aestheticsymbols.io/symbol/sym-273d/)
- [SYM 265C](https://aestheticsymbols.io/symbol/sym-265c/)
- [SYM 2662](https://aestheticsymbols.io/symbol/sym-2662/)
- [RINGED PLANET SATURN](https://aestheticsymbols.io/symbol/ringed-planet-saturn/)
- [SYM 1D48E](https://aestheticsymbols.io/symbol/sym-1d48e/)
- [SEA STARFISH OCEAN](https://aestheticsymbols.io/symbol/sea-starfish-ocean/)
- [SYM 1F608](https://aestheticsymbols.io/symbol/sym-1f608/)
- [SYM 1F602](https://aestheticsymbols.io/symbol/sym-1f602/)
- [LITTLE CAT PAWS KAOMOJI](https://aestheticsymbols.io/symbol/little-cat-paws-kaomoji/)
- [TABLE FLIP RAGE KAOMOJI](https://aestheticsymbols.io/symbol/table-flip-rage-kaomoji/)
- [LEFT POINTING DOUBLE ANGLE QUOTATION](https://aestheticsymbols.io/symbol/left-pointing-double-angle-quotation/)
- [FLOWER GIRL SMILE KAOMOJI](https://aestheticsymbols.io/symbol/flower-girl-smile-kaomoji/)
- [SCORPIO ZODIAC SCORPION](https://aestheticsymbols.io/symbol/scorpio-zodiac-scorpion/)
- [GREEK PSI TRIDENT](https://aestheticsymbols.io/symbol/greek-psi-trident/)
- [SYM 1F978](https://aestheticsymbols.io/symbol/sym-1f978/)
- [SYM 1D432](https://aestheticsymbols.io/symbol/sym-1d432/)
- [SYM 1D407](https://aestheticsymbols.io/symbol/sym-1d407/)
- [SYM 1D46E](https://aestheticsymbols.io/symbol/sym-1d46e/)
- [SYM 2682](https://aestheticsymbols.io/symbol/sym-2682/)
- [KAOMOJI](https://aestheticsymbols.io/kaomoji/)
- [DAGGER CROSS SYMBOL](https://aestheticsymbols.io/symbol/dagger-cross-symbol/)
- [SYM 2621](https://aestheticsymbols.io/symbol/sym-2621/)
- [SYM 1D43B](https://aestheticsymbols.io/symbol/sym-1d43b/)
- [LATIN CROSS HEAVY](https://aestheticsymbols.io/symbol/latin-cross-heavy/)
- [SYM 1F970](https://aestheticsymbols.io/symbol/sym-1f970/)
- [STARS](https://aestheticsymbols.io/ru/stars/)
- [ES](https://aestheticsymbols.io/es/)
- [SYM 1D465](https://aestheticsymbols.io/symbol/sym-1d465/)
- [CAPRICORN ZODIAC GOAT](https://aestheticsymbols.io/symbol/capricorn-zodiac-goat/)
- [SYM 1D453](https://aestheticsymbols.io/symbol/sym-1d453/)
- [SYM 2634](https://aestheticsymbols.io/symbol/sym-2634/)
- [SYM 1D463](https://aestheticsymbols.io/symbol/sym-1d463/)
- [SYM 1F605](https://aestheticsymbols.io/symbol/sym-1f605/)
- [SYM 26EC](https://aestheticsymbols.io/symbol/sym-26ec/)
- [SYM 1D472](https://aestheticsymbols.io/symbol/sym-1d472/)
