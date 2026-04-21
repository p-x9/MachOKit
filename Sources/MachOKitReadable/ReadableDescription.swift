import Foundation

/// Human-friendly labels intended for UI rendering.
///
/// `MachOKit` keeps `CustomStringConvertible.description` aligned with C header constants
/// (e.g. `LC_MAIN`, `MH_EXECUTE`) which is ideal for low-level debugging.
/// This module provides additional readable labels without changing that behavior.
public protocol ReadableDescriptionConvertible {
    var readableDescription: String { get }
}
