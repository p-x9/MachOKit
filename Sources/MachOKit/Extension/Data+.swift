//
//  Data+.swift
//  MachOKit
//
//  Created by p-x9 on 2025/02/02
//  
//
import Foundation

extension Data {
    func byteSwapped<T: FixedWidthInteger>(_ type: T.Type) -> Data {
        guard count >= MemoryLayout<T>.size else { return self }

        let valueArray = self.withUnsafeBytes {
            Array($0.bindMemory(to: T.self))
        }

        let swappedArray = valueArray.map { $0.byteSwapped }

        var swappedData = swappedArray.withUnsafeBufferPointer {
            Data(buffer: $0)
        }

        let remainingBytes = count % MemoryLayout<T>.size
        if remainingBytes > 0 {
            swappedData.append(self.suffix(remainingBytes))
        }

        return swappedData
    }
}
