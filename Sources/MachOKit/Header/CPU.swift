//
//  CPU.swift
//
//
//  Created by p-x9 on 2023/11/29.
//  
//

import Foundation

public struct CPU: Sendable, Equatable {
    public let typeRawValue: cpu_type_t
    public let subtypeRawValue: cpu_subtype_t

    public var type: CPUType? {
        .init(rawValue: typeRawValue)
    }

    public var subtype: CPUSubType? {
        if let type {
            let subtypeRaw = if subtypeRawValue == CPU_SUBTYPE_MULTIPLE {
                subtypeRawValue
            } else {
                subtypeRawValue & cpu_subtype_t(~CPU_SUBTYPE_MASK)
            }
            return .init(rawValue: subtypeRaw, of: type)
        }
        return nil
    }
}

extension CPU: CustomStringConvertible {
    public var description: String {
        let type = type?.description ?? "unknown\(typeRawValue)"
        let subtype = subtype?.description ?? "unknown"

        return "\(type)(\(subtype))"
    }
}

extension CPU {
    public var is64Bit: Bool {
        guard typeRawValue != CPU_TYPE_ANY else { return false }
        return typeRawValue & CPU_ARCH_ABI64 != 0
    }

    public var is64BitHardwareWith32BitType: Bool {
        guard typeRawValue != CPU_TYPE_ANY else { return false }
        return typeRawValue & CPU_ARCH_ABI64_32 != 0
    }
}

#if canImport(Darwin)
extension CPU {
    internal static var _currentTypeRawValue: cpu_type_t? {
        _sysctlValue("hw.cputype")
    }

    /// CPU type and subtype of host pc
    public static var current: CPU? {
        guard let typeRawValue = _currentTypeRawValue else {
            return nil
        }
        let subtypeRawValue: cpu_subtype_t? = _sysctlValue("hw.cpusubtype")
        guard let subtypeRawValue else {
            return nil
        }
        return .init(
            typeRawValue: typeRawValue,
            subtypeRawValue: subtypeRawValue
        )
    }
}

private func _sysctlValue<Value: FixedWidthInteger>(
    _ name: String
) -> Value? {
    var value: Value = 0
    var size = MemoryLayout<Value>.size
    let result = sysctlbyname(name, &value, &size, nil, 0)
    guard result == 0,
          size == MemoryLayout<Value>.size else {
        return nil
    }
    return value
}
#endif
