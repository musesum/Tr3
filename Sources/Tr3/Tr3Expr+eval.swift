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

        if let toNow = ((toVal as? Tr3ValScalar)?.now ?? (toVal as? Float)),
           let frNow = ((frVal as? Tr3ValScalar)?.now ?? (frVal as? Float)) {

            if opNow.isConditional() {
                switch opNow {
                    case .EQ: return frNow == toNow ? frVal : nil
                    case .LE: return frNow <= toNow ? frVal : nil
                    case .GE: return frNow >= toNow ? frVal : nil
                    case .LT: return frNow <  toNow ? frVal : nil
                    case .GT: return frNow >  toNow ? frVal : nil

                    case .In:
                        var isIn = false
                        if let val = toVal as? Tr3ValScalar {
                            isIn = val.inRange(from: frNow)
                        }
                        return isIn ? frVal : nil
                    default : break
                }
            } else if opNow.isOperation() {

                switch opNow {
                    case .add   : return frNow + toNow
                    case .sub   : return frNow - toNow
                    case .muy   : return frNow * toNow
                    case .divi  : return floor(frNow / (toNow == 0 ? 1 : toNow))
                    case .div   : return frNow / (toNow == 0 ? 1 : toNow)
                    case .mod   : return fmodf(frNow, toNow == 0 ? 1 : toNow)
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
