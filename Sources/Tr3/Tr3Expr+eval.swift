//  Created by warren on 8/21/22.
//

import Foundation

extension Tr3Expr {

    func eval(frScalar: Tr3ValScalar) -> Tr3ValScalar? {
        if rvalue is Tr3ValScalar {
            if exprOperator == .none {

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

        switch exprOperator {
            case .In:

                if from.inRange(of: rvalue.num) {
                    rvalue.num = from.num
                    return rvalue
                }
            default: break
        }
        return nil
    }
    func evalScalars(from lval: Tr3ValScalar) -> Tr3ValScalar? {
        guard let rval = rvalue as? Tr3ValScalar else { return nil }
        var notZeroNum: Float { return rval.num != 0 ? rval.num : 1 }

        switch exprOperator {
            case .In: return evalIsIn(from: lval)
            case .EQ: return lval.num == rval.num ? lval : nil
            case .LE: return lval.num <= rval.num ? lval : nil
            case .GE: return lval.num >= rval.num ? lval : nil
            case .LT: return lval.num <  rval.num ? lval : nil
            case .GT: return lval.num >  rval.num ? lval : nil
            case .Add: return Tr3ValScalar(rval.tr3, num: lval.num + rval.num)
            case .Sub: return Tr3ValScalar(rval.tr3, num: lval.num - rval.num)
            case .Muy: return Tr3ValScalar(rval.tr3, num: lval.num * rval.num)
            case .Div: return Tr3ValScalar(rval.tr3, num: lval.num / notZeroNum)
            case .Mod: return Tr3ValScalar(rval.tr3, num: fmodf(lval.num, notZeroNum))
            case .Now: return Tr3ValScalar(rval.tr3, num: rval.num)
            default: return lval
        }
    }
}
