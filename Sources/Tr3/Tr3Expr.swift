//
//  Tr3Expr
//  
//
//  Created by warren on 1/1/21.

import Foundation

public class Tr3Expr {

    public var name: String = ""
    var exprOperator = Tr3ExprOperator.none
    var rvalue: Any? // name | scalar | quote
    public var string: String { rvalue as? String ?? "" }

    init() {
    }

    init(_ name: String) {
        self.name = name
    }
    init(name: String, exprOp: Tr3ExprOperator) {
        self.name = name
        self.exprOperator = exprOp
    }
    init (with from: Tr3Expr) {
        name = from.name
        exprOperator = from.exprOperator
        if let frRvalue = from.rvalue {
            switch frRvalue {
            case let n as String: rvalue = n
            case let s as Tr3ValScalar: rvalue = Tr3ValScalar(with: s)
            default: print("🚫 unknown Tr3Expr from next: \(frRvalue)")
            }
        }
    }

    func copy() -> Tr3Expr {
        let result = Tr3Expr(with: self)
        return result
    }

    func isEligible(num: Float) -> Bool {
        guard let rvalue = rvalue as? Tr3ValScalar  else { return true }
        switch exprOperator {
            case .EQ: return num == rvalue.num
            case .LE: return num <= rvalue.num
            case .GE: return num >= rvalue.num
            case .LT: return num <  rvalue.num
            case .GT: return num >  rvalue.num
            case .In: return num >= rvalue.min && num <= rvalue.max
            default: return true
        }
    }
    func script(session: Bool) -> String {

        var script = name
        script.spacePlus(exprOperator.rawValue)

        if let rvalue = rvalue {
            switch rvalue {
                case let v as String:
                    let vv = "\"\(v)\""
                    script.spacePlus(vv)

                case let v as Tr3ValScalar:
                    let vv =  v.scriptVal(parens: false, session: session, expand: true)
                    script.spacePlus(vv)

                default:
                    print("🚫 unknown script rvalue: \(rvalue)")
            }
        }
        let ret = script.reduceSpaces()
        return ret
    }

}

