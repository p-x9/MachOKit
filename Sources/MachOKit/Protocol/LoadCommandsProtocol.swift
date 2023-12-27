//
//  LoadCommandsProtocol.swift
//
//
//  Created by p-x9 on 2023/12/04.
//  
//

import Foundation

public protocol LoadCommandsProtocol: Sequence<LoadCommand> {}

extension LoadCommandsProtocol {
    public func of(_ type: LoadCommandType) -> AnySequence<LoadCommand> {
        AnySequence(
            lazy.filter {
                $0.type == type
            }
        )
    }

    public func infos<T>(
        of type: @escaping (T) -> LoadCommand
    ) -> AnySequence<T> {
        AnySequence(
            lazy.compactMap { cmd in
                guard let info = cmd.info as? T else { return nil }
                guard type(info).type == cmd.type else { return nil }
                return info
            }
        )
    }
}

extension LoadCommandsProtocol {
    var text: SegmentCommand? {
        compactMap {
            if case let .segment(info) = $0,
               info.segmentName == SEG_TEXT { info } else { nil }
        }.first
    }

    var text64: SegmentCommand64? {
        compactMap {
            if case let .segment64(info) = $0,
               info.segmentName == SEG_TEXT { info } else { nil }
        }.first
    }

    var linkedit: SegmentCommand? {
        compactMap {
            if case let .segment(info) = $0,
               info.segmentName == SEG_LINKEDIT { info } else { nil }
        }.first
    }

    var linkedit64: SegmentCommand64? {
        compactMap {
            if case let .segment64(info) = $0,
               info.segmentName == SEG_LINKEDIT { info } else { nil }
        }.first
    }

    var symtab: LoadCommandInfo<symtab_command>? {
        compactMap {
            if case let .symtab(info) = $0 { info } else { nil }
        }.first
    }

    var dysymtab: LoadCommandInfo<dysymtab_command>? {
        compactMap {
            if case let .dysymtab(info) = $0 { info } else { nil }
        }.first
    }

}
