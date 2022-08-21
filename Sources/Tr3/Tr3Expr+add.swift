//  Created by warren on 8/21/22.
//

import Foundation

extension Tr3Expr {
    func addQuote(_ quote: String) {
        rvalue = quote
    }
    func addOpStr (_ opStr: String) {
        if let op = Tr3ExprOperator(rawValue: opStr) {
            exprOperator = op
        } else {
            print("🚫 unknown exprOp: \(opStr)")
        }
    }
    func addExprName(_ name: String) {
        if self.name.isEmpty {
            self.name = name
        } else {
            self.rvalue = name
        }
    }
    func addExprOp (_ exprOp: Tr3ExprOperator) {
        self.exprOperator = exprOp
    }
    func addExprScalar(_ scalar: Any) {
        self.rvalue = scalar
    }
}
