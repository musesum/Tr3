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

    var name: ExprName
    var exprOp = Tr3ExprOp.none
    var next: Any? // name | scalar

    init(_ name: String) {
        self.name = name
    }
    init(name: String, exprOp: Tr3ExprOp) {
        self.name = name
        self.exprOp = exprOp
    }
    init(name: String, comma: Bool) {
        self.name = name
        self.exprOp = .none
    }
    init (with from: Tr3Expr) {
        name = from.name
        exprOp = from.exprOp
        if let frNext = from.next {
            switch frNext {
            case let n as ExprName: next = n
            case let s as Tr3ValScalar: next = Tr3ValScalar(with: s)
            default: print("*** unknown Tr3Expr from next: \(frNext)")
            }
        }
    }
    func copy() -> Tr3Expr {
        let result = Tr3Expr(with: self)
        return result
    }
    func addOpStr (_ tupStr: String) {
        if let op  = Tr3ExprOp(rawValue: tupStr) {
            exprOp = op
        } else {
            print("*** unknown exprOp: \(tupStr)")
        }
    }
    func addExprOp (_ exprOp: Tr3ExprOp) {
        self.exprOp = exprOp
    }
    func addNext(_ next: Any) {
        self.next = next
    }
    func eval(from: Tr3ValScalar, expr: Tr3ValScalar) -> Tr3ValScalar? {

        if exprOp == .none {

            expr.setVal(from)
            return expr

        } else if let result = evalScalars(from, expr)  {

            expr.setVal(result)
            return expr
            
        } else {

            print("unknown Tr3Expr next: \(next ?? "nil")")
            return nil
        }
    }
    func getLeftRightVals(_ named: [String: Tr3ValScalar],
                          _ frScalar: Tr3ValScalar) -> (Tr3ValScalar,Tr3ValScalar)? {

        if let next = next {
            switch next {
            case let name as String:
                guard let namedVal = named[name] else { return nil }
                return (frScalar, namedVal)
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
    
    func script() -> String {

        var script = name
        if exprOp != .none {
            script += " " + exprOp.rawValue
        }
        if let next = next {

            switch next {
            case let n as ExprName:     script += " " + n
            case let s as Tr3ValScalar: script += " " + String(format: "%g", s.num)
            default: print("*** unknown script next: \(next)")
            }
        }
        return script
    }


}
