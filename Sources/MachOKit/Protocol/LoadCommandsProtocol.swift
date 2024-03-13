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

    public func info<T>(
        of type: @escaping (T) -> LoadCommand
    ) -> T? {
        infos(of: type)
            .first(where: { _ in true })
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
        info(of: LoadCommand.symtab)
    }

    var dysymtab: LoadCommandInfo<dysymtab_command>? {
        info(of: LoadCommand.dysymtab)
    }

    var functionStarts: LoadCommandInfo<linkedit_data_command>? {
        info(of: LoadCommand.functionStarts)
    }

    var dataInCode: LoadCommandInfo<linkedit_data_command>? {
        info(of: LoadCommand.dataInCode)
    }

    var dyldChainedFixups: LoadCommandInfo<linkedit_data_command>? {
        info(of: LoadCommand.dyldChainedFixups)
    }

    var idDylib: DylibCommand? {
        info(of: LoadCommand.idDylib)
    }

    var encryptionInfo: EncryptionInfoCommand? {
        info(of: LoadCommand.encryptionInfo)
    }

    var encryptionInfo64: EncryptionInfoCommand64? {
        info(of: LoadCommand.encryptionInfo64)
    }

    var codeSignature: LoadCommandInfo<linkedit_data_command>? {
        info(of: LoadCommand.codeSignature)
    }
}
