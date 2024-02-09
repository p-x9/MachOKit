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
        infos(of: LoadCommand.segment)
            .first {
                 $0.segname == SEG_TEXT
            }
    }

    var text64: SegmentCommand64? {
        infos(of: LoadCommand.segment64)
            .first {
                $0.segname == SEG_TEXT
            }
    }

    var linkedit: SegmentCommand? {
        infos(of: LoadCommand.segment)
            .first {
                $0.segname == SEG_LINKEDIT
            }
    }

    var linkedit64: SegmentCommand64? {
        infos(of: LoadCommand.segment64)
            .first {
                $0.segname == SEG_LINKEDIT
            }
    }

    var symtab: LoadCommandInfo<symtab_command>? {
        infos(of: LoadCommand.symtab)
            .first { _ in true }
    }

    var dysymtab: LoadCommandInfo<dysymtab_command>? {
        infos(of: LoadCommand.dysymtab)
            .first { _ in true }
    }

    var functionStarts: LoadCommandInfo<linkedit_data_command>? {
        infos(of: LoadCommand.functionStarts)
            .first { _ in true }
    }

    var dataInCode: LoadCommandInfo<linkedit_data_command>? {
        infos(of: LoadCommand.dataInCode)
            .first { _ in true }
    }

    var dyldChainedFixups: LoadCommandInfo<linkedit_data_command>? {
        infos(of: LoadCommand.dyldChainedFixups)
            .first { _ in true }
    }

    var idDylib: DylibCommand? {
        infos(of: LoadCommand.idDylib)
            .first { _ in true }
    }
}
