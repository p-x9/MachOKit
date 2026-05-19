# Loading Mach-O Files

Read Mach-O data from disk with ``MachOFile`` and related file-backed types.

## Overview

``MachOFile`` represents a Mach-O image backed by file data. It is the right
model when the source is a binary on disk, a Mach-O extracted from a dyld shared
cache file, or an architecture slice from a fat binary.

## Load A Thin Mach-O File

```swift
let url = URL(fileURLWithPath: "/usr/bin/swift")
let machO = try MachOFile(url: url)

print(machO.header.magic)
print(machO.header.fileType)
print(machO.header.ncmds)
```

The file-backed model keeps the original file URL and reads binary structures by
offset. This is useful when you need stable byte ranges or when you are
inspecting a binary that is not loaded into the current process.

## Load A Fat Binary

Use ``loadFromFile(url:)`` when a path may contain a fat universal binary.

```swift
let loaded = try MachOKit.loadFromFile(url: url)

switch loaded {
case .machO(let machO):
    inspect(machO)
case .fat(let fat):
    for machO in try fat.machOFiles() {
        inspect(machO)
    }
}
```

The ``File`` result preserves the distinction between a single Mach-O file and a
fat container.

## Inspect Common Data

``MachOFile`` conforms to ``MachORepresentable``. Use the shared API surface for
common Mach-O data.

```swift
for command in machO.loadCommands {
    print(command.type)
}

for segment in machO.segments {
    print(segment.segname)
}

for symbol in machO.symbols {
    print(symbol.name ?? "")
}
```

## File-Backed Offsets

File-backed APIs read data by file offset or by offsets stored in Mach-O load
commands. When a Mach-O file is produced from a dyld shared cache, the value may
also be relative to the original cache file.

> Important: Do not treat file offsets as loaded memory addresses. Use
> ``MachOImage`` for loaded images and dyld-cache APIs for cache-relative data.
