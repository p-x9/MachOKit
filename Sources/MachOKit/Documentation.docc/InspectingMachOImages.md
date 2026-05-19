# Inspecting Mach-O Images

Read Mach-O data from images already loaded in memory with ``MachOImage``.

## Overview

``MachOImage`` represents a Mach-O image whose header is already mapped into the
current process. This is useful when inspecting images returned by dyld runtime
APIs or when analyzing the process state at runtime.

## Create An Image From A Header Pointer

```swift
guard let header = _dyld_get_image_header(0) else {
    return
}

let image = MachOImage(ptr: header)
print(image.header.fileType)
```

The pointer must point to the start of a valid Mach-O header. MachOKit reads
layout data from memory starting at that header.

## Create An Image By Name

```swift
guard let foundation = MachOImage(name: "Foundation") else {
    return
}

print(foundation.path ?? "")
```

Name lookup searches the images known to dyld in the current process.

## Use Runtime Convenience APIs

On Darwin platforms, ``MachOImage`` also provides helpers for common runtime
inspection tasks.

```swift
for image in MachOImage.images {
    print(image.path ?? "")
}

let executable = MachOImage.currentExecutable
print(executable.header.fileType)

let current = MachOImage.current()
print(current.path ?? "")
```

Use ``MachOImage/image(for:)`` when you have a memory address and need to find
the loaded image that contains it.

```swift
let address = UnsafeRawPointer(bitPattern: 0x1000)!

if let image = MachOImage.image(for: address) {
    print(image.path ?? "")
}
```

## Inspect Loaded Data

``MachOImage`` conforms to ``MachORepresentable`` and mirrors many of the same
high-level operations as ``MachOFile``.

```swift
for command in image.loadCommands {
    print(command.type)
}

for section in image.sections {
    print(section.sectname)
}

for symbol in image.symbols {
    print(symbol.name ?? "")
}
```

For process-wide symbol lookup, use the static helpers on ``MachOImage``.

```swift
for (image, symbols) in MachOImage.symbols(named: "_main") {
    print(image.path ?? "", symbols.count)
}

if let (image, symbol) = MachOImage.closestSymbol(at: address) {
    print(image.path ?? "", symbol.name)
}
```

## Memory-Backed Addresses

Memory-backed parsing uses pointers and loaded virtual addresses. When the image
is slid, the loaded address may differ from the unslid address encoded in the
Mach-O file.

> Note: Prefer APIs on ``MachOImage`` when the source of truth is process
> memory. Prefer ``MachOFile`` when the source of truth is bytes on disk.
