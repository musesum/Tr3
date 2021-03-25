//
//  File.swift
//  
//
//  Created by warren on 1/1/21.

import Foundation

enum Tr3ValTupOp: String {

    case none = ""
    case tupEQ = "=="
    case tupLE = "<="
    case tupGE = ">="
    case tupLT = "<"
    case tupGT = ">"
    case tupAdd = "+"
    case tupSub = "-"
    case tupMuy = "*"
    case tupDiv = "/"
    case tupMod = "%"
    case tupIn = "in"
}

public class Tr3ValTupExpr {

    var name: TupName
    var tupOp = Tr3ValTupOp.none
    var next: Any? // name | scalar

    init(_ name: String) {
        self.name = name
    }
    init(name: String, tupOp: Tr3ValTupOp) {
        self.name = name
        self.tupOp = tupOp
    }
    init (with from: Tr3ValTupExpr) {
        name = from.name
        tupOp = from.tupOp
        if let frNext = from.next {
            switch frNext {
            case let n as TupName: next = n
            case let s as Tr3ValScalar: next = Tr3ValScalar(with: s)
            default: print("*** unknown Tr3ValTupExpr from next: \(frNext)")
            }
        }
    }
    func copy() -> Tr3ValTupExpr {
        let result = Tr3ValTupExpr(with: self)
        return result
    }
    func addOpStr (_ tupStr: String) {
        if let op  = Tr3ValTupOp(rawValue: tupStr) {
            tupOp = op
        } else {
            print("*** unknown tupOp: \(tupStr)")
        }
    }
    func addTupOp (_ tupOp: Tr3ValTupOp) {
        self.tupOp = tupOp
    }
    func addNext(_ next: Any) {
        self.next = next
    }
    func eval(_ named: [String: Tr3ValScalar], _ toVal: Tr3ValScalar, _ frVal: Tr3ValScalar) {

        if tupOp == .none {

            toVal.setVal(frVal)
        }
        else if let next = next {

            switch next {

            case let frName as String:

                if  let toVal = named[frName],
                    let scalar = evalScalars(named, toVal, frVal) {
                    
                    toVal.setVal(scalar)
                }

            case let frVal as Tr3ValScalar:

                if let scalar = evalScalars(named, toVal, frVal)  {

                    toVal.setVal(scalar)
                }

            default: print("unknown Tr3ValTupExpr next: \(next)")
            }
        }
    }
    func getLeftRightVals(_ named: [String: Tr3ValScalar], _ toVal: Tr3ValScalar,_ frVal: Tr3ValScalar) -> (Tr3ValScalar,Tr3ValScalar)? {

        if let next = next {
            switch next {
            case let name as String:
                guard let namedVal = named[name] else { return nil }
                return (frVal,namedVal)
            case let scalar as Tr3ValScalar:
                return (frVal,scalar)
            default: return nil
            }
        }
        return nil
    }
    func evalScalars(_ named: [String: Tr3ValScalar], _ toVal: Tr3ValScalar,_ frVal: Tr3ValScalar) -> Tr3ValScalar? {

        guard let (lval,rval) = getLeftRightVals(named, toVal, frVal) else { return nil }

        var notZeroNum: Float { get { return rval.num != 0 ? rval.num : 1 } }

        switch tupOp {
        case .tupEQ: return lval.inRange(of: rval.num) ? lval : nil
        case .tupLE: return lval.num <= rval.num ? lval : nil
        case .tupGE: return lval.num >= rval.num ? lval : nil
        case .tupLT: return lval.num <  rval.num ? lval : nil
        case .tupGT: return lval.num >  rval.num ? lval : nil

        case .tupAdd: return Tr3ValScalar(num: rval.num + lval.num)
        case .tupSub: return Tr3ValScalar(num: rval.num - lval.num)
        case .tupMuy: return Tr3ValScalar(num: rval.num * lval.num)
        case .tupDiv: return Tr3ValScalar(num: rval.num / notZeroNum)
        case .tupMod: return Tr3ValScalar(num: fmodf(rval.num, notZeroNum))
        default: return rval
        }
    }
    func isEligible(_ named: [String: Tr3ValScalar], _ toVal: Tr3ValScalar,_ frVal: Tr3ValScalar) -> Bool {

        guard let (lval,rval) = getLeftRightVals(named, toVal, frVal) else {
            return true
        }
        switch tupOp {
        case .tupEQ: return lval.num == rval.num
        case .tupLE: return lval.num <= rval.num
        case .tupGE: return lval.num >= rval.num
        case .tupLT: return lval.num <  rval.num
        case .tupGT: return lval.num >  rval.num
        default: return true
        }
    }

    func script() -> String {

        var script = name
        if tupOp != .none {
            script += " " + tupOp.rawValue
        }
        if let next = next {

            switch next {
            case let n as TupName:      script += " " + n
            case let s as Tr3ValScalar: script += " " + String(format: "%g", s.num)
            default: print("*** unknown script next: \(next)")
            }
        }
        return script
    }


}
