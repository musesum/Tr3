//  Created by warren on 8/21/22.

import Foundation
import Par

extension Tr3Exprs {

    func addExpr() {
        let expr = Tr3Expr()
        exprs.append(expr)
        valFlags.insert(.exprs)
    }
    func addPath(_ parItem: ParItem) {
        if let name = parItem.nextPars.first?.value {
            addName(name)
        }
    }
    func addScalar(_ scalar: Tr3ValScalar) {

        if let expr = exprs.last {
            if expr.rvalue != nil {
                let expr = Tr3Expr()
                exprs.append(expr)
                expr.addExprScalar(scalar)
            } else {
                expr.addExprScalar(scalar)
            }
            if let lastName = nameAny.keys.last,
               expr.exprOperator == .none {
                nameAny[lastName] = scalar
            }
        }
    }
    func addScalar(_ num: Float? = nil ) -> Tr3ValScalar {
        var scalar: Tr3ValScalar
        if let num = num {
            scalar = Tr3ValScalar(num: num)
        } else {
            scalar = Tr3ValScalar()
        }
        addScalar(scalar)
        return scalar
    }
    func addOper(_ opStr: String?) {
        if let opStr = opStr?.without(trailing: " ")  {
            exprs.last?.addOpStr(opStr)
        }
    }
    func addQuote(_ quote: String?) {
        if let quote = quote?.without(trailing: " ")  {
            exprs.last?.addQuote(quote)
            if let name = nameAny.keys.last {
                nameAny[name] = quote
            }
        }
    }
    func addName(_ name: String?) {
        guard let name = name else { return }
        if !nameAny.keys.contains(name) {
            nameAny[name] = Tr3ValScalar() //placeholder
            valFlags.insert([.names])
        }
        if let expr = exprs.last {
            expr.addExprName(name)
            valFlags.insert([.exprs])
        }
    }
    func addNum(_ num: Float) {
        if let name = nameAny.keys.last,
           let scalar = nameAny[name] as? Tr3ValScalar {
            scalar.addNum(num)
        } else {
            _ = addScalar(num)
        }
    }
   
}
