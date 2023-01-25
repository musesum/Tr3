//
//  Tr3Expr
//  
//
//  Created by warren on 1/1/21.

import Foundation

public class Tr3Expr {

    var op = Tr3ExprOp.none
    var val: Any?
    
    init(op     : String)       { self.op = Tr3ExprOp(op) }
    init(name   : String)       { self.op = .name   ; val = name }
    init(path   : String)       { self.op = .path   ; val = path }
    init(quote  : String)       { self.op = .quote  ; val = quote }
    init(from   : Tr3Expr)      { self.op = from.op ; val = from.val }
    init(scalar : Tr3ValScalar) { self.op = .scalar ; val = scalar }

    func script(_ scriptFlags: Tr3ScriptFlags) -> String {
        
        switch op {
            case .name: return val as? String ?? "??"
            case .quote: return "\"\(val as? String ?? "??")\""
            case .scalar:
                if let v = val as? Tr3ValScalar {
                    var scriptFlags2 = scriptFlags
                    scriptFlags2.remove(.parens)
                    scriptFlags2.insert(.expand)
                    return v.scriptVal(scriptFlags2)
                }
            case .comma: return op.rawValue
            default : break
        }
        return scriptFlags.now ? "" : op.rawValue
        
    }

}

