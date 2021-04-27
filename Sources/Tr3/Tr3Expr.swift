//
//  File.swift
//  
//
//  Created by warren on 1/1/21.

import Foundation

enum Tr3ExprOp: String {

    case none = ""
    case expEQ = "=="
    case expLE = "<="
    case expGE = ">="
    case expLT = "<"
    case expGT = ">"
    case expAdd = "+"
    case expSub = "-"
    case expMuy = "*"
    case expDiv = "/"
    case expMod = "%"
    case expIn = "in"
}

public class Tr3Expr {

    var name: ExprName = ""
    var exprOp = Tr3ExprOp.none
    var operand: Any? // name | scalar

    enum LastParse { case none, name, exprOp, operand }
    var lastParse = LastParse.none

    init() {
    }

    init(_ name: String) {
        switch lastParse {
            case .none:
                self.name = name
                lastParse = .name
            default:
                operand = name
                lastParse = .operand
        }
    }
    init(name: String, exprOp: Tr3ExprOp) {
        self.name = name
        self.exprOp = exprOp
        lastParse = .operand
    }

    init (with from: Tr3Expr) {
        name = from.name
        exprOp = from.exprOp
        lastParse = from.lastParse
        if let frOperand = from.operand {
            switch frOperand {
            case let n as ExprName: operand = n
            case let s as Tr3ValScalar: operand = Tr3ValScalar(with: s)
            default: print("*** unknown Tr3Expr from next: \(frOperand)")
            }
        }
    }

    func copy() -> Tr3Expr {
        let result = Tr3Expr(with: self)
        return result
    }

    func addOpStr (_ opStr: String) {
        if let op  = Tr3ExprOp(rawValue: opStr) {
            exprOp = op
            lastParse = .exprOp
        } else {
            print("*** unknown exprOp: \(opStr)")
        }
    }
    func addExprName(_ name: String) {
        switch lastParse {
            case .none:
                self.name = name
                lastParse = .name
            default:
                self.operand = name
                lastParse = .operand
        }
    }
    func addExprOp (_ exprOp: Tr3ExprOp) {
        self.exprOp = exprOp
        lastParse = .exprOp
    }
    func addExprOperand(_ operand: Any) {
        self.operand = operand
        lastParse = .operand
    }
    
    func eval(from: Tr3ValScalar, expr: Tr3ValScalar) {

        if exprOp == .none {

            expr.setVal(from)

        } else if let result = evalScalars(from, expr)  {

            expr.setVal(result)
            
        } else {

            print("unknown Tr3Expr operand: \(operand ?? "nil")")
        }
    }

    func getLeftRightVals(_ nameScalar: [String: Tr3ValScalar],
                          _ frScalar: Tr3ValScalar) -> (Tr3ValScalar,Tr3ValScalar)? {

        if let operand = operand {
            switch operand {
            case let name as String:
                guard let nameScalarVal = nameScalar[name] else { return nil }
                return (frScalar, nameScalarVal)
            case let scalar as Tr3ValScalar:
                return (frScalar, scalar)
            default: return nil
            }
        }
        return nil
    }
    func evalScalars(_ from: Tr3ValScalar, // frScalar
                     _ expr: Tr3ValScalar) -> Tr3ValScalar? {

        var notZeroNum: Float { get { return expr.num != 0 ? expr.num : 1 } }

        switch exprOp {
            case .expIn: return from.inRange(of: expr.num) ? from : nil
            case .expEQ: return from.num == expr.num ? from : nil
            case .expLE: return from.num <= expr.num ? from : nil
            case .expGE: return from.num >= expr.num ? from : nil
            case .expLT: return from.num <  expr.num ? from : nil
            case .expGT: return from.num >  expr.num ? from : nil
            case .expAdd: return Tr3ValScalar(num: expr.num + from.num)
            case .expSub: return Tr3ValScalar(num: expr.num - from.num)
            case .expMuy: return Tr3ValScalar(num: expr.num * from.num)
            case .expDiv: return Tr3ValScalar(num: expr.num / notZeroNum)
            case .expMod: return Tr3ValScalar(num: fmodf(expr.num, notZeroNum))
            default: return expr
        }
    }

    func isEligible(_ num: Float,_ to: Tr3ValScalar) -> Bool {
        switch exprOp {
            case .expEQ: return num == to.num
            case .expLE: return num <= to.num
            case .expGE: return num >= to.num
            case .expLT: return num <  to.num
            case .expGT: return num >  to.num
            case .expIn: return num >= to.min && num <= to.max
            default: return true
        }
    }
    
    func script(session: Bool) -> String {

        var script = name
        if exprOp != .none {
            script += " " + exprOp.rawValue
        }
        if let operand = operand {

            switch operand {
            case let n as ExprName:     script += " " + n
                case let s as Tr3ValScalar: script += " " + s.dumpVal(parens: false, session: session)
            default: print("*** unknown script operand: \(operand)")
            }
        }
        return script
    }

}
