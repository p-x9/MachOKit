# ``MachOKit``

Parse Mach-O binaries, in-memory Mach-O images, and dyld shared caches from
Swift.

## Overview

MachOKit provides typed access to Mach-O headers, load commands, segments,
sections, symbols, binding information, rebase information, exports, chained
fixups, code signatures, and dyld shared-cache metadata.

The library separates file-backed and memory-backed parsing because Mach-O
offsets and loaded addresses are different concepts. Use ``MachOFile`` when
reading bytes from a file, and use ``MachOImage`` when inspecting an image that
is already loaded in memory.

Dyld shared caches have their own models. Use ``DyldCache`` for a single cache
file, ``FullDyldCache`` for a main cache with subcaches, and
``DyldCacheLoaded`` for a shared cache that is already mapped into memory.

For Unix archive (`.a`) support, use the separate `MachOArchiveKit` product.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:LoadingMachOFiles>
- <doc:InspectingMachOImages>
- ``File``
- ``loadFromFile(url:)``
- ``MachOFile``
- ``MachOImage``

### Shared Concepts

- <doc:BinaryLayoutsAndOffsets>
- ``MachORepresentable``
- ``Magic``
- ``CPU``
- ``CPUType``
- ``CPUSubType``
- ``MachHeader``
- ``FileType``

### Load Commands, Segments, And Sections

- <doc:ReadingLoadCommandsAndSegments>
- ``LoadCommand``
- ``LoadCommandType``
- ``LoadCommandInfo``
- ``LoadCommandWrapper``
- ``SegmentCommand``
- ``SegmentCommand64``
- ``Section``
- ``Section64``

### Symbols, Strings, And Exports

- <doc:ReadingSymbolsStringsAndExports>
- ``SymbolProtocol``
- ``Nlist``
- ``Nlist64``
- ``SymbolType``
- ``SymbolDescription``
- ``ExportedSymbol``

### Rebases, Binds, And Fixups

- <doc:RebasesBindsAndChainedFixups>
- ``Rebase``
- ``BindingSymbol``
- ``DyldChainedFixupsHeader``
- ``DyldChainedFixupPointer``
- ``DyldChainedFixupPointerInfo``
- ``DyldChainedImport``

### Code Signing

- <doc:ReadingCodeSignatures>
- ``CodeSignProtocol``
- ``CodeSignSuperBlob``
- ``CodeSignCodeDirectory``
- ``CodeSignSpecialSlotType``

### Dyld Shared Caches

- <doc:WorkingWithDyldCaches>
- ``DyldCache``
- ``FullDyldCache``
- ``DyldCacheLoaded``
- ``DyldCacheRepresentable``
- ``DyldCacheHeader``
- ``DyldCacheImageInfo``
- ``DyldCacheMappingInfo``
