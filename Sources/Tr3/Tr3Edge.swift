//
//  Tr3Edge.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

public class Tr3Edge: Hashable {

    var id = Visitor.nextId()
    var key = "" // created with makeKey()

    var edgeFlags = Tr3EdgeFlags()
    var active = true
    var leftTr3: Tr3
    var rightTr3: Tr3
    var defVal: Tr3Val?

    public static var LineageDepth = 2 // useful for debugging

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public static func == (lhs: Tr3Edge, rhs: Tr3Edge) -> Bool {
        return lhs.key == rhs.key
    }

    convenience init(with: Tr3Edge) { // was operator = in c++ version
        self.init(with.leftTr3, with.rightTr3, with.edgeFlags)
        self.active    = with.active
        self.defVal    = with.defVal
        makeKey()
    }

   init(_ leftTr3: Tr3, _ rightTr3: Tr3, _ edgeflags: Tr3EdgeFlags) {
        //self.init()
        self.edgeFlags = edgeflags
        self.leftTr3   = leftTr3
        self.rightTr3  = rightTr3
        makeKey()
    }
    convenience init(_ def: Tr3EdgeDef, _ leftTr3: Tr3, _ rightTr3: Tr3, _ tr3Val: Tr3Val?) {
        self.init(leftTr3, rightTr3, def.edgeFlags)
        self.defVal    = tr3Val
        makeKey()
    }
    func makeKey() {
        let lhs = "\(leftTr3.id)"
        let rhs = "\(rightTr3.id)"
        let arrow = scriptEdgeFlag()
        key = lhs+arrow+rhs
    }
    func dumpEdgeVal(_ tr3: Tr3, session: Bool = false) -> String {

        var script = ""

        if leftTr3 == tr3 {
            script += rightTr3.scriptLineage(Tr3Edge.LineageDepth)
        }
        else if rightTr3 == tr3 {
            script += leftTr3.scriptLineage(Tr3Edge.LineageDepth)
        }
        script += defVal?.dumpVal(session: session) ?? ""
        return script
    }

}
