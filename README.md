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

For reading from memory, use the `MachO` structure.

It can be initialized by using the Mach-O Header pointer obtained by `_dyld_get_image_header`.

```swift
guard let mh = _dyld_get_image_header(0) else { return }
let machO = MachO(ptr: mh)
```

Alternatively, it can be initialized using the name.

```swift
// /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
guard let machO = MachO(name: "Foundation") else { return }
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

Both `MachO` and `MachOFile` can use essentially the same properties and methods.
The available methods are defined in the following file as the `MachORepresentable` protocol.

[MachORepresentable](./Sources/MachOKit/Protocol/MachORepresentable.swift)

### Example Codes

There are a variety of uses, but most show a basic example that prints output to the Test directory.

#### Load from memory

The following file contains sample code.
[MachOPrintTests](./Tests/MachOKitTests/MachOPrintTests.swift)

#### Load from file

The following file contains sample code.
[MachOFilePrintTests](./Tests/MachOKitTests/MachOFilePrintTests.swift)

## License

MachOKit is released under the MIT License. See [LICENSE](./LICENSE)
