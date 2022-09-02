//
//  Tr3Expr
//  
//
//  Created by warren on 1/1/21.

import Foundation

public class Tr3Expr {

    var op = Tr3ExprOp.none
    var val: Any?
    
    init(op _op : String)       { op = Tr3ExprOp(_op) }
    init(name   : String)       { op = .name   ; val = name }
    init(path   : String)       { op = .path   ; val = path }
    init(quote  : String)       { op = .quote  ; val = quote }
    init(from   : Tr3Expr)      { op = from.op ; val = from.val }
    init(scalar : Tr3ValScalar) { op = .scalar ; val = scalar }

    func script(session: Bool) -> String {
        
        switch op {
            case .name: return val as? String ?? "??"
            case .quote: return "\"\(val as? String ?? "??")\""
            case .scalar:
                if let v = val as? Tr3ValScalar {
                    return v.scriptVal(parens: false, session: session, expand: true)
                }
            case .comma: return op.rawValue
            default : break
        }
        return session ? "" : op.rawValue
        
    }

}

