# Getting Started

Load a Mach-O binary or inspect an image that is already loaded in memory.

## Overview

MachOKit has two primary entry points:

- ``MachOFile`` reads a Mach-O image from file data.
- ``MachOImage`` reads a Mach-O image from a loaded Mach-O header pointer.

Both types conform to ``MachORepresentable``, so common operations such as
reading load commands, segments, sections, symbols, binds, rebases, and exports
use the same high-level API shape.

## Load A File

Use ``loadFromFile(url:)`` when the input may be either a thin Mach-O file or a
fat universal binary.

```swift
let url = URL(fileURLWithPath: "/path/to/binary")
let file = try MachOKit.loadFromFile(url: url)

switch file {
case .machO(let machO):
    print(machO.header.fileType)
case .fat(let fat):
    let machOs = try fat.machOFiles()
    print(machOs.count)
}
```

Use ``MachOFile`` directly when the input is known to be a single Mach-O image.

```swift
let machO = try MachOFile(url: url)
print(machO.header.ncmds)
```

## Inspect A Loaded Image

Use ``MachOImage`` when you already have a Mach-O header pointer, such as one
returned by dyld runtime APIs.

```swift
guard let header = _dyld_get_image_header(0) else {
    return
}

let image = MachOImage(ptr: header)
print(image.header.fileType)
```

You can also look up a loaded image by name.

```swift
if let foundation = MachOImage(name: "Foundation") {
    print(foundation.path ?? "")
}
```

## Choose The Right Model

Use file-backed APIs for data on disk and memory-backed APIs for already loaded
images. The two models expose similar information, but they do not use the same
storage model.

> Important: A file offset, a Mach-O-header-relative offset, a dyld-cache offset,
> an unslid virtual address, and a loaded memory address are different values.
> Convert between them only with APIs that explicitly describe that conversion.
