//  Tr3EdgeDef+connect.swift
//
//  Created by warren on 4/29/19.


import Foundation

extension Tr3EdgeDef {

    func connectNewEdge(_ leftTr3: Tr3, _ rightTr3: Tr3, _ tr3Val: Tr3Val?) {

        let newEdge = Tr3Edge(self, leftTr3, rightTr3, tr3Val)
        let newKey = newEdge.edgeKey

        func addEdge() {
            leftTr3.tr3Edges[newKey] = newEdge
            rightTr3.tr3Edges[newKey] = newEdge
            edges[newKey] = newEdge
        }
        func excludeEdge() {
            if let oldEdge = edges[newKey] {
                oldEdge.edgeFlags.remove(edgeFlags)
                if oldEdge.edgeFlags.isEmpty {
                    edges.removeValue(forKey: newKey)
                }
            }
        }
        // begin -----------------------------
        if edgeFlags.exclude {
            excludeEdge()
        } else if edgeFlags.copyat {
            addEdge()
            connectCopyr(leftTr3, rightTr3, tr3Val)
        } else {
            addEdge()
        }
    }
    func connectCopyr(_ leftTr3: Tr3, _ rightTr3: Tr3, _ tr3Val: Tr3Val?)  {
        var rights = [String: Tr3]()
        for rightChild in rightTr3.children {
            rights[rightChild.name] = rightChild
        }
        for leftChild in leftTr3.children {
            if let rightChild = rights[leftChild.name] {
                Tr3EdgeDef(flags: edgeFlags)
                .connectNewEdge(leftChild, rightChild, tr3Val)
            }
        }
    }

    /// find d.a1 relative to h
    func connectTernCondition(_ tern: Tr3ValTern, _ tr3: Tr3, _ ternPathTr3s: [Tr3]) {

        /// input to Ternary is output from pathTr3
        func connectTernIfEdge(_ ternPathTr3: Tr3, _ pathTr3: Tr3) {

            //print(pathTr3.scriptLineage(2) + " ◇→ " + ternPathTr3.scriptLineage(2))
            let edge = Tr3Edge(pathTr3, ternPathTr3, [.output, .ternIf])
            pathTr3.tr3Edges[edge.edgeKey] = edge

            for edgeDef in ternPathTr3.edgeDefs.edgeDefs {
                if edgeDef == self { return edgeDef.edges[edge.edgeKey] = edge }
            }
            let edgeDef = Tr3EdgeDef(with: self)
            edgeDef.edges[edge.edgeKey] = edge
            ternPathTr3.edgeDefs.edgeDefs.append(edgeDef)
        }

        // ────────────── begin ──────────────

        tern.pathTr3s.removeAll()

        let found = tr3.findPathTr3s(tern.path, [.parents, .children])
        if found.isEmpty {
            // find b1 relative to d.a1 and c1 relative to d.a1.b1
            // paths with a˚b may produce duplicates so filter out with foundSet
            var foundSet = Set<Tr3>()
            for ternPathTr3 in ternPathTr3s {
                let foundThen = ternPathTr3.findPathTr3s(tern.path, [.parents, .children])
                for tr3 in foundThen {
                    foundSet.insert(tr3)
                }
            }
            tern.pathTr3s.removeAll()
            tern.pathTr3s.append(contentsOf: foundSet)
            // sorting by triplet (a.b.c) is unnecessary for runtime, but nice for debugging
            tern.pathTr3s.sort(by:{ $0.scriptLineage(2) < $1.scriptLineage(2) })
        }
        else {
            tern.pathTr3s = found
        }
        for pathTr3 in tern.pathTr3s {
            connectTernIfEdge(tr3, pathTr3)
            if tern.compareOp != "",  let compareRight = tern.compareRight {
                compareRight.pathTr3s = pathTr3.findPathTr3s(compareRight.path, [.parents, .children])
                for rightTr3 in compareRight.pathTr3s {
                    connectTernIfEdge(tr3, rightTr3)
                }
            }
        }
    }

    /// output from ternary is input to pathTr3
    func connectTernPathEdge(_ ternTr3: Tr3, _ pathTr3: Tr3) {
        //print(pathTr3.scriptLineage(3) + " ◇→ " + pathTr3.scriptLineage(2))
        let flipFlags = Tr3EdgeFlags(flipIO: edgeFlags)
        let edge = Tr3Edge(pathTr3, ternTr3, flipFlags)
        
        edge.edgeFlags.insert(.ternGo)
        
        pathTr3.tr3Edges[edge.edgeKey] = edge
        if flipFlags.input {
            ternTr3.tr3Edges[edge.edgeKey] = edge
        }
    }

    /// b in `<- (a ? b)`
    /// Connect results of ternIf. Filter out redundant results in Set.
    ///
    /// in the following example:
    ///
    ///         d {a1 a2}:{b1 b2} e <- (d˚b1 ? d˚b2)
    ///
    /// the results of d˚b2 for both d.a1.b1 and d.a1.b2, will produce
    ///
    ///         (d.a1.b2 d.a2.b2) and (d.a1.b2 d.a2.b2)
    ///
    /// so use a Set<Tr3> to filter out redundant tr3s
    /// before saving filtered results into valPath.pathTr3s
    ///
    func connectValPath(_ valPath: Tr3ValPath, _ tr3: Tr3, _ leftTr3s: [Tr3]) {

        var foundSet = Set<Tr3>()

        for leftTr3 in leftTr3s {
            let foundTr3s = leftTr3.findPathTr3s(valPath.path, [.parents, .children])
            for tr3 in foundTr3s {
                foundSet.insert(tr3)
            }
        }
        valPath.pathTr3s.removeAll()
        valPath.pathTr3s.append(contentsOf: foundSet)
        valPath.pathTr3s.sort(by:{ $0.scriptLineage(2) < $1.scriptLineage(2) })
        for pathTr3 in valPath.pathTr3s {
            connectTernPathEdge(tr3, pathTr3)
        }
    }

    /// b1 in `<- (a1 ? b1 ? c1 : 1)` Connect inner ternary.
    ///
    /// Location of b1 maybe relative a1, for example:
    ///
    ///     d {a1 a2}:{b1 b2}:{c1 c2} h <- (d.a1 ? b1 ? c1 : 1)
    ///
    /// will find b1 as child of d.a1
    ///
    func connectValTern(_ tern: Tr3ValTern, _ tr3: Tr3, _ foundTr3s: [Tr3]) {
        // IF
        connectTernCondition(tern, tr3, foundTr3s) // f.i
        // THEN
        switch tern.thenVal {
        case let thenTern as Tr3ValTern: connectValTern(thenTern, tr3, tern.pathTr3s)
        case let thenPath as Tr3ValPath: connectValPath(thenPath, tr3, tern.pathTr3s)
        default: break
        }
        // ELSE
        switch tern.elseVal {
        case let elseTern as Tr3ValTern: connectValTern(elseTern, tr3, tern.pathTr3s)
        case let elsePath as Tr3ValPath: connectValPath(elsePath, tr3, tern.pathTr3s)
        default: break
        }
        // RADIO
        if let radioNext = tern.radioNext {
            connectValTern(radioNext, tr3, [])
        }
    }

    /// batch connect edges - convert from Tr3EdgeDef to Tr3Edges
    func connectEdges(_ tr3: Tr3)  {
        
        // non ternary edges
        if pathVals.pathVal.count > 0 {
            
            for (path,val) in pathVals.pathVal {
                if let pathrefs = tr3.pathrefs {
                    for pathref in pathrefs {
                        let rightTr3s = pathref.findPathTr3s(path, [.parents, .children])
                        for rightTr3 in rightTr3s {
                            connectNewEdge(pathref, rightTr3, val)
                        }
                    }
                }
                else {
                    let rightTr3s = tr3.findPathTr3s(path, [.parents, .children])
                    for rightTr3 in rightTr3s {
                        connectNewEdge(tr3, rightTr3, val)
                    }
                }
            }
        }
        // ternary
        else if let tern = ternVal {
            // a˚z <- (...)
            if tr3.type == .path {
                let found =  tr3.findAnchor(tr3.name, [.parents, .children])
                if found.count > 0 {
                    for foundi in found {
                        let foundTern = Tr3ValTern(with: tern)
                        if !foundi.edgeDefs.overideEdgeTernary(foundTern) {
                            foundi.edgeDefs.addEdgeTernary(foundTern, copyFrom: tr3)
                            connectValTern(foundTern, foundi, [])
                        }
                    }
                    return
                }
            }
            // a <- (...) single instance
            connectValTern(tern, tr3, [])
        }
    }
}
