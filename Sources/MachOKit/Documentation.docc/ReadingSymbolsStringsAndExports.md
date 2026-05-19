# Reading Symbols, Strings, And Exports

Inspect symbol tables, string tables, indirect symbols, and export tries.

## Overview

MachOKit exposes classic Mach-O symbol table data as sequences and higher-level
models. It also provides APIs for exported symbols discovered through the export
trie.

## Iterate Symbols

Use the shared `symbols` collection when you do not need to handle 32-bit and
64-bit symbol tables separately.

```swift
for symbol in machO.symbols {
    print(symbol.name ?? "")
    print(symbol.type)
}
```

For lower-level access, ``MachOFile`` and ``MachOImage`` also expose 32-bit and
64-bit symbol-table sequences.

## Symbol Metadata

Symbol-related models preserve the original Mach-O structure while exposing
typed helpers.

```swift
for symbol in machO.symbols {
    if symbol.type == .section {
        print(symbol.sectionNumber)
    }
}
```

Use ``SymbolType``, ``SymbolDescription``, ``SymbolFlags``, and
``SymbolLibraryOrdinalType`` to interpret symbol metadata without scattering raw
bit operations through call sites.

## Exported Symbols

Use `exportedSymbols` for symbols described by the export trie.

```swift
for exported in machO.exportedSymbols {
    print(exported.name)
    print(exported.flags)
}
```

Use `exportTrie` when you need sequence-style access to the trie nodes.

## File And Memory Differences

File-backed symbol readers pull string-table and symbol-table bytes from data
slices. Memory-backed readers use pointers derived from the loaded image.

> Important: Symbol values may be virtual addresses, file-relative values, or
> loaded addresses depending on the source and symbol kind. Interpret them in
> the context of the API that produced them.
