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

## Symbol Values

``SymbolProtocol/rawValue`` preserves the complete `n_value` as a `UInt64`,
without applying a load adjustment. A 32-bit `nlist` value is zero-extended.
Use ``SymbolValue`` to distinguish absolute values, section definitions,
common symbol sizes, indirect name indexes, and other symbol kinds.

```swift
for symbol in machO.symbols {
    switch symbol.value {
    case let .abs(value):
        print(symbol.name, "absolute", value)
    case let .common(size):
        print(symbol.name, "common size", size)
    case let .indr(index):
        print(symbol.name, "indirect name index", index)
    default:
        print(symbol.name, symbol.rawValue)
    }
}
```

The interpretation does not resolve addresses or validate section and string-table
bounds. Debug entries, including unknown STAB codes, take precedence over ordinary
symbol types. The legacy `offset` property remains host-sized and may truncate
values or include a wrapping image base adjustment.

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
