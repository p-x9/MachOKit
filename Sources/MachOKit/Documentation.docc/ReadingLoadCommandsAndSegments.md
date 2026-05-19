# Reading Load Commands And Segments

Use load commands to find Mach-O segments, sections, dependencies, entry points,
and other image metadata.

## Overview

Mach-O load commands describe most of the structured metadata in an image.
MachOKit exposes raw load-command information through ``LoadCommandInfo`` and
typed wrappers for known command payloads.

## Iterate Load Commands

```swift
for command in machO.loadCommands {
    print(command.type)
}
```

Both ``MachOFile`` and ``MachOImage`` expose `loadCommands` through their shared
Mach-O model.

## Work With Typed Commands

``LoadCommand`` preserves the command kind and associated typed payload when
MachOKit has a wrapper for that command.

```swift
for command in machO.loadCommands {
    switch command {
    case .segment64(let segment):
        print(segment.segname)
    case .dylib(let dylib):
        print(dylib.name(in: machO))
    default:
        break
    }
}
```

Use ``LoadCommandType`` when you only need the `LC_*` command identifier.

## Segments And Sections

Segments and sections are available through convenience collections.

```swift
for segment in machO.segments {
    print(segment.segname)
}

for section in machO.sections {
    print(section.sectname)
}
```

The 32-bit and 64-bit variants remain distinct where the Mach-O binary layout is
different.

## Layout Wrappers

Typed command models conform to ``LoadCommandWrapper`` and expose their C-backed
layout through the `layout` property. Computed properties provide Swift-friendly
access while preserving the upstream binary layout.

> Note: `description` values for command and type models intentionally stay
> close to original Mach-O constants such as `LC_MAIN`.
