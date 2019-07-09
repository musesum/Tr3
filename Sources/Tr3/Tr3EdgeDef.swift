//
//  Tr3EdgeDef.swift
//  Par iOS
//
//  Created by warren on 3/10/19.
//

import Foundation
import Par // ParAny 

public class Tr3EdgeDef {

    var edgeFlags = Tr3EdgeFlags()
    var defPaths = [String]() // b in a <- b
    var defVal: Tr3Val? // 9 in a -> (b:9)
    var edges = [Tr3Edge]() // each edge is also shared by two Tr3s

    // currently ternary in ternary tree to parse
    var parseTern: Tr3ValTern? // * in a -> (a ? * ? * ? * : * : *)
    
    init() { }

    init(flags: Tr3EdgeFlags) { self.edgeFlags = flags }

    init(with: Tr3EdgeDef) {

        edgeFlags = with.edgeFlags
        defPaths = with.defPaths

        switch with.defVal {
        case let v as Tr3ValTern   : defVal = Tr3ValTern(with: v)
        case let v as Tr3ValScalar : defVal = Tr3ValScalar(with: v)
        case let v as Tr3ValTuple  : defVal = Tr3ValTuple(with: v)
        case let v as Tr3ValQuote  : defVal = Tr3ValQuote(with: v)
        default: break
        }
    }
    func copy() -> Tr3EdgeDef {
        return Tr3EdgeDef(with: self)
    }

    func addPath(_ parAny:ParAny) {

        if let path = parAny.next.first?.value {

            if let _ = defVal as? Tr3ValTern {
                Tr3ValTern.ternStack.last?.addPath(path)
            }
            else {
                defPaths.append(path)
            }

        }
        else {
            print("*** Tr3EdgeDef: \(self) cannot process addPath(\(parAny))")
        }
    }

    static func == (lhs: Tr3EdgeDef, rhs: Tr3EdgeDef) -> Bool {

        if lhs.edgeFlags != rhs.edgeFlags { return false } // not same type
        for leftPath in lhs.defPaths {
            if rhs.defPaths.contains(leftPath) {continue}
            else { return false } // different main path
        }

        if let lval = lhs.defVal {
            if let rval = rhs.defVal   { return lval == rval } // compare both values
            else                       { return false } // lhs has a value, but rhs is nil
        }
        if rhs.defVal != nil           { return false } // lhs is nil, but right has a value
        else                           { return true  } // both values are nil
    }

}
