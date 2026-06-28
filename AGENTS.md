# AGENTS.md

Guidance for AI coding agents working in this repository. Keep this file focused
on MachOKit-specific rules that are easy to get wrong.

## Core Model Rules

MachOKit mirrors binary layouts from Mach-O, dyld, xnu, and related Apple OSS
sources. Preserve that relationship in new code.

- When a memory layout has an upstream C definition in Apple OSS such as
  `dyld` or `xnu`, redefine that layout in `MachOKitC` as directly as possible.
- In `MachOKit`, wrap C layouts with a Swift type conforming to `LayoutWrapper`
  and extend the wrapper with computed properties and typed conveniences.
- Keep stored binary layout fields in the C-backed layout. Do not replace a
  real C layout with a Swift-only struct just because it is easier to model.
- Be explicit about offsets. File offsets, Mach-O-header-relative offsets, and
  dyld-cache-relative offsets are different concepts and should not be merged
  without proof.
- When adding Mach-O parsing behavior, check both file-backed `MachOFile` and
  memory-backed `MachOImage` paths. Keep their semantics aligned, but preserve
  their different storage models: file reads use offsets and data slices; image
  reads use pointers and vmaddr slide.
- Before adding a new abstraction, check whether the behavior belongs on an
  existing protocol such as `MachORepresentable`, `DyldCacheRepresentable`,
  `LoadCommandWrapper`, `SectionProtocol`, or `SymbolProtocol`.

Example pattern:

- C layout or constants live under `Sources/MachOKitC`.
- Swift wrapper owns `public var layout: <c_layout>`.
- Higher-level parsing and interpretation live in extensions on the wrapper or
  in the relevant `MachOFile`, `MachOImage`, or dyld-cache type.

## Flags

Represent flag sets with the repository's `BitFlags` protocol, not plain
`OptionSet`, unless an existing local pattern requires otherwise.

- Use `Sources/MachOKit/LoadCommand/Model/DylibUseFlags.swift` as the reference
  pattern.
- Define the flag container as a `struct` conforming to `BitFlags`.
- Define individual flags in the nested `Bit` enum.
- Map each `Bit` case to the original C constant in `RawRepresentable`.
- Keep `CustomStringConvertible.description` close to the original C constant
  name.
- Add a doc comment to every public static flag and every `Bit` case with the
  original C definition name, for example `/// DYLIB_USE_WEAK_LINK`.

Do not use human-friendly labels for core flag descriptions. Put display labels
in `MachOKitReadable` when needed.

## Types And Constants

Represent binary "type" values, command kinds, CPU kinds, relocation kinds, and
similar closed sets as Swift enums.

- Add a doc comment to every case with the original C definition name, for
  example `/// LC_MAIN`.
- Keep raw-value mapping explicit and tied to the C constants imported from
  `MachOKitC`.
- Preserve existing `description` values as C-constant-like strings.
- If a value needs a user-facing name, add or update the matching
  `MachOKitReadable` extension instead of changing the core description.

Use `LoadCommandType.swift`, `FileType.swift`, relocation type files, and CPU
type/subtype files as reference patterns.

## Change Recipes

For a new C-backed layout:

- Add the C definition or constant to `MachOKitC`, matching the upstream source.
- Add a Swift `LayoutWrapper` type in the relevant `MachOKit` area.
- Add typed computed properties on the wrapper instead of exposing only raw
  integer interpretation at call sites.
- Update file-backed and memory-backed parsing paths separately when both
  `MachOFile` and `MachOImage` are affected.

For a new load command:

- Add or reuse the C layout and constants in `MachOKitC`.
- Add the case to `LoadCommandType` with the original `LC_*` doc comment.
- Add the payload case to `LoadCommand` and update conversion logic.
- Add a command wrapper/model type when raw `LoadCommandInfo` is not enough.
- Add byte-swap support in `LoadCommandWrapper` for the command layout.
- Update `MachOFile` and `MachOImage` accessors when the command exposes parsed
  data through both file-backed and memory-backed APIs.
- Add readable descriptions in `MachOKitReadable` only when user-facing labels
  are needed.

For a new flag set:

- Add or reuse C constants in `MachOKitC`.
- Add a `BitFlags` struct with nested `Bit`.
- Document every case/static flag with the original C name.
- Add readable descriptions only in `MachOKitReadable` if presentation labels
  are needed.

For a new type enum:

- Add cases with C-name doc comments.
- Implement raw-value conversion using the imported C constants.
- Keep unknown or unsupported raw values non-destructive when existing APIs
  already allow unknown values.
- Update readable descriptions and tests/examples when the type is exposed to
  users.

For dyld cache work:

- State whether the change affects `DyldCache`, `FullDyldCache`,
  `DyldCacheLoaded`, or all of them.
- Keep file-backed cache, full-cache/subcache, and loaded shared-cache memory
  behavior separate unless the existing protocols already unify the operation.
- Do not assume file offsets, cache offsets, unslid vmaddrs, and loaded memory
  addresses are interchangeable.

## Validation Policy

- `swift build` is the primary validation command for code changes.
- `swift test` is useful for focused validation, but existing tests include
  sample/print-style tests that may depend on local macOS system binaries and
  dyld cache paths.
- For parser or binary-layout changes, prefer stable fixtures or small
  synthetic data over new tests that depend on `/System/Applications`.
- For performance changes, verify the impact with
  `make benchmark-baseline-compare` whenever a benchmark baseline is available.
- For Markdown-only changes, a build is not normally required.

## Do Not Drift

- Do not rename C-derived cases, constants, or descriptions to be more
  "Swifty" when they intentionally mirror upstream names.
- Do not casually change public API names, existing `description` output, or
  platform availability.
- Do not edit generated or machine-local artifacts such as `.build/`, `docs/`,
  `XCFrameworks/`, `.DS_Store`, release zip files, or checksum outputs.
- Do not hide binary-layout details behind ad hoc string or byte parsing when a
  typed layout, enum, or flag wrapper belongs in the model.
