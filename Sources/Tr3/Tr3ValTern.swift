//  Tr3ValTern.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

public typealias CallTern = ((Tr3ValTern)->())

public enum Tr3Act { case
    activate, // activate and pass values when condition is true
    sneak     // set values and adjust connections w/o activation
}

public enum Tr3TernState { case
    If,     // `a` in `a ? b : c`
    Then,   // `b` in `a ? b : c`
    Else,   // `c` in `a ? b : c`
    Radio,  // … in (… | …) exclusive switch, like 'radio' button 
    Neither // deactivated sub-Tern in Radio
}

/// bidirection switched flow ternary with radio-button style extension
///
///     w << (a == b) // receive bang to w with no value
///     w << (a == b : 1) // recv value 1 to w
///     w << (a == b ? c : d) // recv c or d to w
///     w << (a ? 1 : b ? 2 : c ? 3) // recv 1 if a, 2 if a&b, 3 if a & b & c
///     w << (a ? a1 : a2 | b ? b1 : b2 | c ? c1 : c2) // if a, recv a1, else recv a2, b block b1, b2, c1, c2
///
///     w >> (a == b) // undefined
///     w >> (a == b : 1) // undefined
///     w >> (a == b : 1 1s) // undefined
///     w >> (a == b ? c : d) // if a==b, send w to c, else send w to d
///     w >> (a ? 1 : b ? 2 : c ? 3) // recv 1 if a, 2 if a&b, 3 if a & b & c
///     w >> (a ? a1 : a2 | b ? b1 : b2 | c ? c1 : c2) // if a, recv a1, else recv a2, b block b1, b2, c1, c2
///
///     w << (a ? 1 | b ? b1 : b2 | c ? c1 ? c2 | d ? d1 : d2)
///     w << (a ? a1 : a2 ) | (b ? b2 : b2) | (c ? c1 : c2)
///     w << (a ? a1 : a2   |  b ? b1 : b2  |  c ? c1 : c2)
///     w <<  a ? a1 : a2   |  b ? b1 : b2  |  c ? c1 : c2

public class Tr3ValTern: Tr3ValPath {
    
    static var ternStack = [Tr3ValTern]() // only single threaded parse allowed

    var parseLevel = 0 // a, b, c are at different levels in (a ? b ? c ? 3 : 2 : 1 )
    var ternState = Tr3TernState.If
    var compareRight: Tr3ValPath?   // b in `(a == b ? c : d)`, Tr3ValPath.path contains a
    var compareOp = ""              // "==" in (a == b ? c : d)
    
    var thenVal: Tr3Val?
    var elseVal: Tr3Val?

    /// When activated, a radio segment needs to deactive all its neighbors
    /// via linked list of all the tern segments that occur before and after
    var radioPrev: Tr3ValTern?
    var radioNext: Tr3ValTern?
    
    override init(with from: Tr3Val) {

        if let from = from as? Tr3ValTern {

            super.init(with: from)

            self.tr3     = from.tr3
            ternState    = from.ternState
            compareRight = from.compareRight?.copy() ?? nil
            compareOp    = from.compareOp
            thenVal      = from.thenVal?.copy() ?? nil
            elseVal      = from.elseVal?.copy() ?? nil
            radioPrev    = from.radioPrev
            radioNext    = from.radioNext
            parseLevel   = from.parseLevel
        }
        else {
            //TODO: placeholder?
            super.init(Tr3())
        }
    }
    override func copy() -> Tr3ValTern {
        let newTr3ValTern = Tr3ValTern(with: self)
        return newTr3ValTern
    }

    init(_ tr3: Tr3, _ parseLevel: Int) {
        super.init(tr3)
        self.tr3 = tr3
        self.parseLevel = parseLevel
    }

    static func getTernLevel(_ level: Int) -> Tr3ValTern?  {
        while ternStack.last?.parseLevel ?? 0 > level {
            let _ = ternStack.popLast()
        }
        if let ternLast = ternStack.last {
            return ternLast
        }
        else {
            print("🚫 Tr3ValTern.getTernLevel(\(level)) not found")
        }
        return nil
    }
    
    static func setTernState(_ ternState_: Tr3TernState, _ level: Int) {
        if let tern = getTernLevel(level) {
            tern.ternState = ternState_
        }
    }

    static func setCompare(_ compareOp: String?) {
        if let compareOp = compareOp {
            if let tern = ternStack.last {
                tern.compareOp = compareOp
            }
        }
    }

    public func addPath(_ path_: String) {

        switch ternState {
            
        case .If:   if path == "" { path = path_ }
         /**/       else { compareRight = Tr3ValPath(tr3, with: path_) }

        case .Then: thenVal = Tr3ValPath(tr3, with: path_)
        case .Else: elseVal = Tr3ValPath(tr3, with: path_)
        default:    break
        }
    }

    /// While parsing, get most recently added Tr3Val to decorate with additional attributes.
    func getVal() -> Tr3Val? {
        switch ternState {
        case .If:    return nil
        case .Then:  return thenVal
        case .Else:  return elseVal
        case .Radio: return radioNext
        default: break
        }
        return nil
    }

    func addVal(_ val: Tr3Val) {
        
        if let ternVal = val as? Tr3ValTern {
            switch ternState {
                case .If, .Then: thenVal = ternVal
                case .Else:      elseVal = ternVal
                case .Radio:

                    if let lastTern = Tr3ValTern.ternStack.last {
                        if lastTern.id != ternVal.id {
                            lastTern.radioNext = ternVal
                            ternVal.radioPrev = lastTern
                        }
                    }
                default: break
            }
            Tr3ValTern.ternStack.append(ternVal)
        }
        else {
            switch ternState {
                case .If, .Then: thenVal = val
                case .Else:      elseVal = val
                default: break
            }
        }
    }
    func deepAddVal(_ val: Tr3Val) {

        if let ternVal = Tr3ValTern.ternStack.last {
            ternVal.addVal(val)
        }
    }

}
