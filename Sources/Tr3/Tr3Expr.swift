//
//  Tr3ExprOptions.swift
//  
//
//  Created by warren on 1/1/21.

import Foundation

public struct Tr3ExprOptions: OptionSet {
    public let rawValue: Int
    public static let expr    = Tr3ExprOptions(rawValue: 1 << 0)
    public static let op      = Tr3ExprOptions(rawValue: 1 << 1)
    public static let name    = Tr3ExprOptions(rawValue: 1 << 2)
    public static let scalar  = Tr3ExprOptions(rawValue: 1 << 3)
    public static let rvalue  = Tr3ExprOptions(rawValue: 1 << 4)
    public static let quote   = Tr3ExprOptions(rawValue: 1 << 5)

    public init(rawValue: Int = 0) { self.rawValue = rawValue }

    static public var debugDescriptions: [(Self, String)] = [
        (.expr   , "expr"    ),
        (.op     , "op"      ),
        (.name   , "name"    ),
        (.scalar , "scalar"  ),
        (.quote  , "quote"   ),
        (.rvalue , "rvalue"  ),
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let printable = result.joined(separator: ", ")

        return "\(printable)"
    }
}

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

    public var name: ExprName = ""
    var exprOp = Tr3ExprOp.none
    var rvalue: Any? // name | scalar | quote
    var options = Tr3ExprOptions(rawValue: 0)

    init() {
    }

    init(_ name: String) {
        self.name = name
        options.insert(.name)
    }
    init(name: String, exprOp: Tr3ExprOp) {
        self.name = name
        self.exprOp = exprOp
        options.insert(.rvalue)
    }

    init (with from: Tr3Expr) {
        name = from.name
        exprOp = from.exprOp
        options = from.options
        if let frRvalue = from.rvalue {
            switch frRvalue {
            case let n as ExprName: rvalue = n
            case let s as Tr3ValScalar: rvalue = Tr3ValScalar(with: s)
            default: print("🚫 unknown Tr3Expr from next: \(frRvalue)")
            }
        }
    }

    func copy() -> Tr3Expr {
        let result = Tr3Expr(with: self)
        return result
    }
    func addQuote(_ quote: String) {
        rvalue = quote
        options.insert(.quote)
    }
    func addOpStr (_ opStr: String) {
        if let op = Tr3ExprOp(rawValue: opStr) {
            exprOp = op
            options.insert(.op)
        } else {
            print("🚫 unknown exprOp: \(opStr)")
        }
    }
    func addExprName(_ name: String) {
        if options.rawValue == 0 {
            self.name = name
            options.insert(.name)
        } else {
            self.rvalue = name
            options.insert(.rvalue)
        }
    }
    func addExprOp (_ exprOp: Tr3ExprOp) {
        self.exprOp = exprOp
        options.insert(.op)
    }
    func addExprScalar(_ scalar: Any) {
        self.rvalue = scalar
        options.insert(.rvalue)
    }
    
    func eval(frScalar: Tr3ValScalar) -> Tr3ValScalar? {
        if rvalue is Tr3ValScalar {
            if exprOp == .none {
                
                return frScalar
                
            } else if let result = evalScalars(from: frScalar)  {

                return result

            } else {
                
                print("unknown Tr3Expr rvalue: \(rvalue ?? "nil")")
                return nil
            }
        } else {
            addExprScalar(frScalar)
            return frScalar
        }
    }

    func evalIsIn(from: Tr3ValScalar) -> Tr3ValScalar? {
        guard let rvalue = rvalue as? Tr3ValScalar else { return nil }
        var notZeroNum: Float { return rvalue.num != 0 ? rvalue.num : 1 }

        switch exprOp {
            case .expIn:

                if from.inRange(of: rvalue.num) {
                    rvalue.num = from.num
                    return rvalue
                }
            default: break
        }
        return nil
    }
    func evalScalars(from: Tr3ValScalar) -> Tr3ValScalar? {
        guard let rvalue = rvalue as? Tr3ValScalar else { return nil }
        var notZeroNum: Float { return rvalue.num != 0 ? rvalue.num : 1 }

        switch exprOp {
            case .expIn: return evalIsIn(from: from)
            case .expEQ: return from.num == rvalue.num ? from : nil
            case .expLE: return from.num <= rvalue.num ? from : nil
            case .expGE: return from.num >= rvalue.num ? from : nil
            case .expLT: return from.num <  rvalue.num ? from : nil
            case .expGT: return from.num >  rvalue.num ? from : nil
            case .expAdd: return Tr3ValScalar(num: from.num + rvalue.num)
            case .expSub: return Tr3ValScalar(num: from.num - rvalue.num)
            case .expMuy: return Tr3ValScalar(num: from.num * rvalue.num)
            case .expDiv: return Tr3ValScalar(num: from.num / notZeroNum)
            case .expMod: return Tr3ValScalar(num: fmodf(from.num, notZeroNum))
            default: return from
        }
    }

    func isEligible(num: Float) -> Bool {
        guard let rvalue = rvalue as? Tr3ValScalar  else { return true }
        switch exprOp {
            case .expEQ: return num == rvalue.num
            case .expLE: return num <= rvalue.num
            case .expGE: return num >= rvalue.num
            case .expLT: return num <  rvalue.num
            case .expGT: return num >  rvalue.num
            case .expIn: return num >= rvalue.min && num <= rvalue.max
            default: return true
        }
    }
    
    public var string: String { rvalue as? String ?? "" }

    func script(session: Bool) -> String {
        
        var script = name
        if exprOp != .none {
            if script.isEmpty {
                script = exprOp.rawValue
            } else {
                script += " " + exprOp.rawValue
            }
        }
        let delim = name.isEmpty ? "" : " "
        
        if let rvalue = rvalue {

            switch rvalue {

                case let s as String:

                    if options.contains(.quote) {
                        script += delim + "\"\(s)\""
                    } else {
                        script += delim + s
                    }

                case let v as Tr3ValScalar:

                    let scalar = v.dumpVal(parens: false, session: session)
                    script += delim + scalar


                default:

                    print("🚫 unknown script rvalue: \(rvalue)")
            }
        }
        return script
    }

}
