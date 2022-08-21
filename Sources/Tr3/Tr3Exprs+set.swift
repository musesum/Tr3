//  Created by warren on 8/21/22.
//

import Foundation

extension Tr3Exprs {

    func setFloat(_ v: Float) {
        valFlags.insert(.names)
        if let n = nameAny["val"] as? Tr3ValScalar {
            n.setVal(v)
            n.addFlag(.num)
        }
        else {
            nameAny["val"] = Tr3ValScalar(num: v) //TODO: remove this kludge for DeepMenu
        }
    }

    func setPoint(_ p: CGPoint) {

        func addPoint() {
            valFlags.insert(.names)
            if let n = nameAny["x"] as? Tr3ValScalar {
                n.setVal(p.x)
                n.addFlag(.num)
            }
            else {
                nameAny["x"] = Tr3ValScalar(num: Float(p.x))
            }
            if let n = nameAny["y"] as? Tr3ValScalar {
                n.setVal(p.y)
                n.addFlag(.num)
            }
            else {
                nameAny["y"] = Tr3ValScalar(num: Float(p.y))
            }
        }
        // begin -------------------------------
        if exprs.isEmpty { return addPoint() }
        let exprs = Tr3Exprs(point: p)
        setExprs(to: self, fr: exprs)
    }

    func isEligible(_ from: Tr3Exprs) -> Bool {
        if exprs.isEmpty {
            return true
        }
        for expr in exprs {
            let name = expr.name
            if let frScalar = from.nameAny[name] as? Tr3ValScalar ,
               expr.isEligible(num: frScalar.num) == false {
                return false
            }
        }
        return true
    }

    func setExprs(to: Tr3Exprs, fr: Tr3Exprs) {
        if isEligible(fr) {
            // a(x + _, y + _) << b(x _, y _)
            for toExpr in to.exprs {
                let name = toExpr.name
                if let frScalar = fr.nameAny[name] as? Tr3ValScalar {

                    // a(x in 2…4, y in 3…5) >> b b(x 1…2, y 2…3)
                    if let inScalar = toExpr.evalIsIn(from: frScalar ) {
                        to.nameAny[name] = inScalar
                    }
                    // a(x + 1, y + 2) << b(x 3, y 4) ⟹ a(x 4 , y 6)
                    else if let rScalar = toExpr.eval(frScalar: frScalar) ,
                            let toScalar = to.nameAny[name] as? Tr3ValScalar {

                        toScalar.setVal(rScalar)
                    }
                } else {
                    // a(x + 1, y + 2) << b(x, y) ⟹ a(x + 1, y + 2)
                    // skip
                }
            }
        }
    }

    func setNamed(_ name: String, _ value: Float) {
        if let scalar = nameAny[name] as? Tr3ValScalar {
            scalar.num = value
        } else {
            nameAny[name] = Tr3ValScalar(num: value)
        }
        addFlag(.num)
    }

}
