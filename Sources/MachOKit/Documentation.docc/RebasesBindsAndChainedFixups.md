# Rebases, Binds, And Chained Fixups

Inspect dynamic linker rebasing, binding, and chained-fixup metadata.

## Overview

Mach-O images can describe dynamic linking work through classic rebase and bind
opcodes or through dyld chained fixups. MachOKit exposes both forms while
preserving the underlying binary layout concepts.

## Rebase Information

Use `rebaseOperations` for opcode-level data and `rebases` for interpreted
rebase records.

```swift
if let operations = machO.rebaseOperations {
    for operation in operations {
        print(operation)
    }
}

for rebase in machO.rebases {
    print(rebase)
}
```

## Binding Information

Binding APIs expose imported symbol information and bind operations.

```swift
if let operations = machO.bindOperations {
    for operation in operations {
        print(operation)
    }
}

for symbol in machO.bindingSymbols {
    print(symbol.name)
}
```

## Chained Fixups

Use `dyldChainedFixups` when the image uses `LC_DYLD_CHAINED_FIXUPS`.

```swift
if let fixups = machO.dyldChainedFixups {
    print(fixups.header)
    print(fixups.imports.count)
}
```

Chained-fixup data includes pointer formats, starts-in-image metadata, import
tables, and per-page pointer chains.

## Offset Discipline

Rebase and bind data often references segment offsets, pointer locations, import
ordinals, or encoded target values. Keep those values in their original
coordinate system until a MachOKit API explicitly resolves them.

> Note: File-backed and memory-backed fixup readers expose similar operations,
> but they read from different storage models.
