//
//  Tr3Parse2.swift
//  Tr3
//
//  Created by warren on 4/2/21.
//

import Foundation

// a(+) << b(1) b(10) b! a:1 b! a:2 b! a:3
// a(/) << b, a(1) a:1, b(2)! a:.50, b! a:.25, ...
// a(1 * b / c) << (b c), b(1) a:nil, c(2) a:0.5, b(3) a:1.5, c(4) a:.75
// a(1 * b / c) << z, z(3 4) a:.75, z(c 4 b 1) a:.25

class T {}

public typealias fn = ((T)->(T?))

let tr3: fn =  { t in
    let nodes: fn = { t in
        let path: fn = { t in }
        let name: fn = { t in }
    }
    let edges: fn = { t in
        let edgeOp: fn = { t in }
        let edgeParen: fn = { t in tr3.edges.edge(t+1).many() }
        let edge: fn = { t in
            let nodes: fn = { t in tr3.nodes(t+1) }
            let exprs: fn = { t in }
            let quote: fn = { t in }
            let ternary: fn = { t in }
            let comment: fn = { t in }
        }
    }
    let values: fn = { t in
        let exprs: fn = { t in tr3.values.expr(t+1).many() }
        let expr: fn = { t in
            let exprOp: fn = { t in }
            let names: fn = { t in }
            let scalar: fn = { t in }
            let ternary: fn = { t in }
            let comma: fn = { t in }
        }
        let scalar: fn = { t in
            let thru: fn = { t in
                let num: fn = { t in }
            }
            let modu: fn = { t in
                let max: fn = { t in }
                let dflt: fn = { t in }
            }
            let index: fn = { t in
                let name: fn = { t in }
                let num: fn = { t in }
            }
            let data: fn = { t in }
            let num: fn = { t in }
        }
        let ternary: fn = { t in
            let ternIf: fn = { t in tr3.val.expr(t+1).addTo(Tr3ValTern) }
            let ternThen: fn = { t in tr3.val.expr(t+1).addTo(Tr3ValTern) }
            let ternElse: fn = { t in tr3.val.expr(t+1).addTo(Tr3ValTern) }
            let ternRadio: fn = { t in tr3.val.expr(t+1).addTo(Tr3ValTern) }
        }
        let embed: fn = { t in }
    }
    let branches: fn = { t in
        let child: fn = { t in
            let comment: fn = { t in }
            let tr3: fn = { t in }
        }
        let many: fn = { t in }
        let array: fn = { t in }
        let copyat: fn = { t in }
    }
    let quote: fn = { t in }
    let comment: fn = { t in }
}

let _tr3: Fn = { token in
    switch token.name {
    case "nodes":    _nodes(token)?.add()
    case "edges":    _edges(token)?.add()
    case "values":   _values(token)?.add()
    case "branches": _branches(token)?.add()
    case "comment":  _coment(token)?.add()
    default: break
    }
    return token
}
let _nodes: Fn = { token in
    switch token.name {
    case "path":  _path(token)?.add()
    case "name":  _name(token)?.add()
    default: break
    }
    return token
}
let _values: Fn = { token in
    switch token.name {
    case "exprs":   _exprs(token)?.add()
    case "quote":   _quote(token)?.add()
    case "scalar":  _scalar(token)?.add()
    case "ternary": _ternary(token)?.add()
    case "embed":   _embed(token)?.add()
    default: break
    }
    return token
}

let _exprs: Fn = { token in
    switch token.name {
    case "expr": _expr(token.next)?.add()
    default: break
    }
    return token
}
let _expr: Fn = { token in
    switch token.name {
    case "exprOp":  _exprOp(token)?.add()
    case "names":   _names(token)?.add()
    case "scalar":  _scalar(token)?.add()
    case "ternary": _ternary(token)?.add()
    case "comma":   _comma(token)?.add()
    default: break
    }
    return token
}

let _scalar: Fn = { token in
    switch token.name {
    case "thru":  _thru(token)?.add()
    case "modu":  _modu(token)?.add()
    case "data":  _data(token)?.add()
    case "comma": _comma(token)?.add()
    case "num":   _num(token)?.add()
    default: break
    }
    return token
}
let _ternary: Fn = { token in
    switch token.name {
    case "ternIf":    return _expr(token)?.add()
    case "ternThen":  return _expr(token)?.add()
    case "ternElse":  return _expr(token)?.add()
    case "ternRadio": return _ternary(token)?.add()
    default: break
    }
    return token
}

let _embed: Fn = { token in
    return token
}

let _branches: Fn = { token in
    switch token.name {
    case "child":   return _child(token)?.add()
    case "many":    return _many(token)?.add()
    case "array":   return _array(token)?.add()
    case "copyat":  return _copyat(token)?.add()
    default: break
    }
    return token
}
let _quote: Fn = { token in
    return token
}
let _comment: Fn = { token in
    switch token.prev.pattern {
    case "tr3":   return token.tr3.addComment()
    case "edges": return token.edges.addComment()
    case "child": return token.addChild().addComment(token.value)
    default: break
    }
}
