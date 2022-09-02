//
//  File.swift
//  
//
//  Created by warren on 8/23/22.
//

import Foundation

enum Tr3ExprOp: String {

    case none   = ""
    case path   = "path"
    case name   = "name"
    case quote  = "quote"
    case scalar = "scalar"
    case num    = "num"

    case EQ  = "=="
    case LE  = "<="
    case GE  = ">="
    case LT  = "<"
    case GT  = ">"
    case In  = "in"

    case Add = "+"
    case Sub = "-"
    case Muy = "*"
    case Div = "/"
    case Mod = "%"

    case assign = ":"  // assign value
    case comma = ","

    init(_ op: String) { self = Tr3ExprOp(rawValue: op) ?? .none }
    static let pathNames: Set<Tr3ExprOp> = [.path, .name]
    static let literals: Set<Tr3ExprOp> = [.path, .name, .quote, .scalar, .num]
    static let conditionals: Set<Tr3ExprOp> = [.EQ, .LE, .GE, .LT, .GT, .In]
    static let operations: Set<Tr3ExprOp> = [.Add,.Sub,.Muy,.Div,.Mod, .assign]

    func hasConditionals(_ test: Set<Tr3ExprOp> ) -> Bool {
        return !test.isDisjoint(with: Tr3ExprOp.conditionals)
    }
    func hasOperations(_ test: Set<Tr3ExprOp> ) -> Bool {
        return !test.isDisjoint(with: Tr3ExprOp.operations)
    }
    func isPathName() -> Bool {
        return Tr3ExprOp.pathNames.contains(self)
    }
    func isLiteral() -> Bool {
        return Tr3ExprOp.literals.contains(self)
    }
    func isConditional() -> Bool {
        return Tr3ExprOp.conditionals.contains(self)
    }
    func isOperation() -> Bool {
        return Tr3ExprOp.operations.contains(self)
    }
}
