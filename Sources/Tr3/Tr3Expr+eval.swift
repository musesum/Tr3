//  Created by warren on 8/21/22.
//

import Foundation

extension Tr3Expr {

    func evaluate(_ toVal: Any?,
                  _ frVal: Any?,
                  _ opNow: Tr3ExprOp) -> Any? {

        if opNow == .none {
            return frVal
        }

        if let rval = ((toVal as? Tr3ValScalar)?.num ?? (toVal as? Float)),
           let lval = ((frVal as? Tr3ValScalar)?.num ?? (frVal as? Float)) {

            if opNow.isConditional() {
                switch opNow {
                    case .EQ: return lval == rval ? frVal : nil
                    case .LE: return lval <= rval ? frVal : nil
                    case .GE: return lval >= rval ? frVal : nil
                    case .LT: return lval <  rval ? frVal : nil
                    case .GT: return lval >  rval ? frVal : nil

                    case .In:
                        var isIn = false
                        if let val = toVal as? Tr3ValScalar {
                            isIn = val.inRange(from: lval)
                        }
                        return isIn ? frVal : nil
                    default : break
                }
            } else if opNow.isOperation() {

                switch opNow {
                    case .add   : return lval + rval
                    case .sub   : return lval - rval
                    case .muy   : return lval * rval
                    case .divi  : return floor(lval / (rval == 0 ? 1 : rval))
                    case .div   : return lval / (rval == 0 ? 1 : rval)
                    case .mod   : return fmodf(lval, rval == 0 ? 1 : rval)
                    case .assign: return frVal
                    default     : break
                }
            } else {
                return frVal
            }
        } else if toVal is String , frVal is String {
            //TODO: make String,Tr3ValScalar, Num as generic for isConditional, above
            return frVal
        }
        return nil
    }

}
