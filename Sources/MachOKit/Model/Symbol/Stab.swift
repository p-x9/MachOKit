//
//  Stab.swift
//
//
//  Created by p-x9 on 2023/12/08.
//  
//

import Foundation

public enum Stab {
    case gsym
    case fname
    case fun
    case stsym
    case lcsym
    case bnsym
    case ast
    case opt
    case rsym
    case sline
    case ensym
    case ssym
    case so
    case oso
    case lsym
    case bincl
    case sol
    case params
    case version
    case olevel
    case psym
    case eincl
    case entry
    case lbrac
    case excl
    case rbrac
    case bcomm
    case ecomm
    case ecoml
    case leng
    case pc
}

extension Stab: RawRepresentable {
    public typealias RawValue = Int32

    public init?(rawValue: RawValue) {
        switch rawValue {
        case RawValue(N_GSYM): self = .gsym
        case RawValue(N_FNAME): self = .fname
        case RawValue(N_FUN): self = .fun
        case RawValue(N_STSYM): self = .stsym
        case RawValue(N_LCSYM): self = .lcsym
        case RawValue(N_BNSYM): self = .bnsym
        case RawValue(N_AST): self = .ast
        case RawValue(N_OPT): self = .opt
        case RawValue(N_RSYM): self = .rsym
        case RawValue(N_SLINE): self = .sline
        case RawValue(N_ENSYM): self = .ensym
        case RawValue(N_SSYM): self = .ssym
        case RawValue(N_SO): self = .so
        case RawValue(N_OSO): self = .oso
        case RawValue(N_LSYM): self = .lsym
        case RawValue(N_BINCL): self = .bincl
        case RawValue(N_SOL): self = .sol
        case RawValue(N_PARAMS): self = .params
        case RawValue(N_VERSION): self = .version
        case RawValue(N_OLEVEL): self = .olevel
        case RawValue(N_PSYM): self = .psym
        case RawValue(N_EINCL): self = .eincl
        case RawValue(N_ENTRY): self = .entry
        case RawValue(N_LBRAC): self = .lbrac
        case RawValue(N_EXCL): self = .excl
        case RawValue(N_RBRAC): self = .rbrac
        case RawValue(N_BCOMM): self = .bcomm
        case RawValue(N_ECOMM): self = .ecomm
        case RawValue(N_ECOML): self = .ecoml
        case RawValue(N_LENG): self = .leng
        case RawValue(N_PC): self = .pc
        default: return nil
        }
    }
    public var rawValue: RawValue {
        switch self {
        case .gsym: RawValue(N_GSYM)
        case .fname: RawValue(N_FNAME)
        case .fun: RawValue(N_FUN)
        case .stsym: RawValue(N_STSYM)
        case .lcsym: RawValue(N_LCSYM)
        case .bnsym: RawValue(N_BNSYM)
        case .ast: RawValue(N_AST)
        case .opt: RawValue(N_OPT)
        case .rsym: RawValue(N_RSYM)
        case .sline: RawValue(N_SLINE)
        case .ensym: RawValue(N_ENSYM)
        case .ssym: RawValue(N_SSYM)
        case .so: RawValue(N_SO)
        case .oso: RawValue(N_OSO)
        case .lsym: RawValue(N_LSYM)
        case .bincl: RawValue(N_BINCL)
        case .sol: RawValue(N_SOL)
        case .params: RawValue(N_PARAMS)
        case .version: RawValue(N_VERSION)
        case .olevel: RawValue(N_OLEVEL)
        case .psym: RawValue(N_PSYM)
        case .eincl: RawValue(N_EINCL)
        case .entry: RawValue(N_ENTRY)
        case .lbrac: RawValue(N_LBRAC)
        case .excl: RawValue(N_EXCL)
        case .rbrac: RawValue(N_RBRAC)
        case .bcomm: RawValue(N_BCOMM)
        case .ecomm: RawValue(N_ECOMM)
        case .ecoml: RawValue(N_ECOML)
        case .leng: RawValue(N_LENG)
        case .pc: RawValue(N_PC)
        }
    }
}

extension Stab: CustomStringConvertible {
    public var description: String {
        switch self {
        case .gsym: "N_GSYM"
        case .fname: "N_FNAME"
        case .fun: "N_FUN"
        case .stsym: "N_STSYM"
        case .lcsym: "N_LCSYM"
        case .bnsym: "N_BNSYM"
        case .ast: "N_AST"
        case .opt: "N_OPT"
        case .rsym: "N_RSYM"
        case .sline: "N_SLINE"
        case .ensym: "N_ENSYM"
        case .ssym: "N_SSYM"
        case .so: "N_SO"
        case .oso: "N_OSO"
        case .lsym: "N_LSYM"
        case .bincl: "N_BINCL"
        case .sol: "N_SOL"
        case .params: "N_PARAMS"
        case .version: "N_VERSION"
        case .olevel: "N_OLEVEL"
        case .psym: "N_PSYM"
        case .eincl: "N_EINCL"
        case .entry: "N_ENTRY"
        case .lbrac: "N_LBRAC"
        case .excl: "N_EXCL"
        case .rbrac: "N_RBRAC"
        case .bcomm: "N_BCOMM"
        case .ecomm: "N_ECOMM"
        case .ecoml: "N_ECOML"
        case .leng: "N_LENG"
        case .pc: "N_PC"
        }
    }
}
