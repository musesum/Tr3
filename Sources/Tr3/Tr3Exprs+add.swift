// Tr3Exprs+add
//
//  Created by warren on 8/21/22.

import Foundation
import Par

extension Tr3Exprs {

    func addScalar(_ scalar: Tr3ValScalar) {
        let expr = Tr3Expr(scalar: scalar)
        exprs.append(expr)
        opSet.insert(.scalar)
    }
    func addDeepScalar(_ scalar: Tr3ValScalar) {
        let expr = Tr3Expr(scalar: scalar)
        exprs.append(expr)
        nameAny[nameAny.keys.last ?? anonKey] = scalar
        opSet.insert(.scalar)
    }
    func addNameNum(_ name: String, _ num: Double) {
        addName(name)
        addDeepScalar(Tr3ValScalar(tr3, name: name, num: num))
    }
    func injectNameNum(_ name: String, _ num: Double) {
        if let val = nameAny[name] as? Tr3ValScalar {
            val.now = num
        } else {
            nameAny[name] = Tr3ValScalar(tr3, name: name, num: num)
        }
        opSet.insert(.name)
        opSet.insert(.scalar)
    }

    func addPoint(_ p: CGPoint) {
        opSet = Set<Tr3ExprOp>([.name,.num])
        injectNameNum("x", Double(p.x))
        addOpStr(",")
        injectNameNum("y", Double(p.y))
    }
    func addOpStr(_ opStr: String?) {
        if let opStr = opStr?.without(trailing: " ")  {
            let expr = Tr3Expr(op: opStr)
            exprs.append(expr)
        }
    }
    func addQuote(_ quote: String?) {
        if let quote = quote?.without(trailing: " ")  {
            let expr = Tr3Expr(quote: quote)
            exprs.append(expr)
            nameAny[nameAny.keys.last ?? anonKey] = quote
            opSet.insert(.quote)
        }
    }
    func addName(_ name: String?) {

        guard let name else { return }
        let expr = Tr3Expr(name: name)
        exprs.append(expr)
        opSet.insert(.name)

        if !nameAny.keys.contains(name) {
            nameAny[name] = ""
        }
    }
   
}
