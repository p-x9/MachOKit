# Binary Layouts And Offsets

Understand how MachOKit models binary layouts and coordinate systems.

## Overview

MachOKit mirrors Mach-O, dyld, xnu, and related Apple OSS definitions. Public
Swift models generally wrap C-backed layouts and add computed properties for
typed interpretation.

This design keeps binary layout details visible while still making common
parsing operations convenient.

## Layout Wrappers

Types that wrap binary layouts conform to `LayoutWrapper` and expose the raw
layout through `layout`.

```swift
let header = machO.header
print(header.layout.ncmds)
print(header.fileType)
```

Use typed computed properties when available. Use `layout` when you need the
exact field from the upstream structure.

## Common Coordinate Systems

Mach-O and dyld-cache data can refer to several kinds of positions:

- File offsets identify bytes in a file.
- Mach-O-header-relative offsets are relative to the start of one Mach-O image.
- Dyld-cache-relative offsets are relative to a dyld shared cache file or
  subcache.
- Virtual addresses are addresses encoded for the image before loading.
- Loaded memory addresses include runtime mapping and slide behavior.

These values can have the same numeric representation in simple cases, but they
do not mean the same thing.

## File-Backed And Memory-Backed Models

``MachOFile`` reads from offsets and data slices. ``MachOImage`` reads from
pointers and loaded memory. ``DyldCache`` and ``FullDyldCache`` read cache files,
while ``DyldCacheLoaded`` reads a cache already mapped into memory.

> Important: Avoid manual string or byte parsing when MachOKit already has a
> typed model for a layout, enum, or flag set.
