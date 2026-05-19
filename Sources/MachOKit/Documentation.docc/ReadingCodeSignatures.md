# Reading Code Signatures

Inspect Mach-O code-signing blobs and code directories.

## Overview

MachOKit exposes code-signature data through `codeSign` on ``MachOFile`` and
``MachOImage``. The returned model provides access to the superblob, code
directories, requirements, and individual blob data.

## Access Code-Signing Data

```swift
guard let codeSign = machO.codeSign else {
    return
}

if let superBlob = codeSign.superBlob {
    print(superBlob.count)
}

for directory in codeSign.codeDirectories {
    print(directory.identifier)
}
```

## Read Blob Data

Use `blobData(superBlob:index:includesGenericInfo:)` when you need the raw bytes
for a blob referenced by a superblob index.

```swift
if let superBlob = codeSign.superBlob {
    for index in codeSign.blobIndices(superBlob: superBlob) {
        let data = codeSign.blobData(
            superBlob: superBlob,
            index: index,
            includesGenericInfo: true
        )
        print(data.count)
    }
}
```

## Byte Order

Code-signing structures may require byte swapping when converting raw blob data
to typed models.

> Important: When using raw blob data, account for the `isSwapped` value on the
> code-signing model before interpreting nested structures.
