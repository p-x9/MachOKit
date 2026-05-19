# Working With Dyld Caches

Inspect dyld shared-cache files and loaded dyld shared-cache memory.

## Overview

MachOKit provides separate models for the major dyld-cache storage forms:

- ``DyldCache`` represents one dyld shared-cache file.
- ``FullDyldCache`` represents a main cache and its subcaches as one logical
  cache.
- ``DyldCacheLoaded`` represents a dyld shared cache already mapped into memory.

These types conform to ``DyldCacheRepresentable`` where behavior can be shared,
but they preserve their different storage models.

## Load A Single Cache File

```swift
let path = "/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e"
let url = URL(fileURLWithPath: path)

let cache = try DyldCache(url: url)

for machO in cache.machOFiles() {
    print(machO.imagePath ?? "")
}
```

Use ``DyldCache`` when you need to inspect one cache file directly.

On Darwin platforms, use ``DyldCache/host`` as a shortcut for the host dyld
shared-cache file when MachOKit can discover its path.

```swift
if let cache = DyldCache.host {
    print(cache.header.magic)
}
```

## Load A Full Cache

Modern Apple platforms may split a logical shared cache across a main cache and
multiple subcaches. Use ``FullDyldCache`` when you want MachOKit to represent
those files together.

```swift
let fullCache = try FullDyldCache(url: url)

for machO in fullCache.machOFiles() {
    print(machO.imagePath ?? "")
}
```

``FullDyldCache`` exposes component caches through properties such as
``FullDyldCache/mainCache``, ``FullDyldCache/subCaches``, and
``FullDyldCache/allCaches``.

Use ``FullDyldCache/host`` when you want the host cache and its subcaches opened
as one logical file-backed cache.

```swift
if let fullCache = FullDyldCache.host {
    print(fullCache.allCaches.count)
}
```

## Inspect A Loaded Cache

On Apple platforms, dyld can expose the currently loaded shared cache range.

```swift
var size = 0
guard let pointer = _dyld_get_shared_cache_range(&size) else {
    return
}

let loaded = try DyldCacheLoaded(ptr: pointer)

for image in loaded.machOImages() {
    print(image.path ?? "")
}
```

Loaded-cache APIs return ``MachOImage`` values because the Mach-O images are
read from memory.

Use ``DyldCacheLoaded/current`` for the same loaded-cache lookup without calling
the dyld runtime helper yourself.

```swift
if let loaded = DyldCacheLoaded.current {
    for image in loaded.machOImages() {
        print(image.path ?? "")
    }
}
```

## Cache Offsets And Addresses

Dyld caches mix several coordinate systems: cache file offsets, per-image Mach-O
offsets, unslid virtual addresses, slid loaded addresses, and subcache-relative
locations.

> Important: Keep cache-file, full-cache, and loaded-cache behavior separate
> unless an API explicitly unifies them.
