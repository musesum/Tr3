//  Tr3Parse.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

public class Tr3Parse {

    public static let shared = Tr3Parse()

    public var rootParNode: ParNode!
    var tr3Keywords = [String: Tr3PriorParItem]()

    public init() {
        rootParNode = Par.shared.parse(script: Tr3Par)
        rootParNode.reps.repMax = Int.max
        makeParTr3()
    }
    /// create a dictionary of parsing closures as a global dispatch
    func makeParTr3() {

        func dispatchFunc(_ fn: @escaping Tr3PriorParItem, from keywords: [String]) {
            for keyword in keywords { tr3Keywords[keyword] = fn }
        }
        dispatchFunc(parsePath, from: ["name", "path"])

        dispatchFunc(parseComma, from: ["comma"])
        dispatchFunc(parseComment, from: ["comment"])

        dispatchFunc(parseChild, from: ["child", "many", "copyat"])

        dispatchFunc(parseValue, from: ["data",
                                        "scalar1",
                                        "thru", "modu", "num",
                                        "quote", "embed", "tupExpr"])
                                        //"tuple", "tupExpr"])

        dispatchFunc(parseEdge, from: ["edges", "edgeOp", "ternIf", "ternThen",
                                       "ternElse","ternRadio","ternCompare"])

        dispatchFunc(parseTuple, from: ["tuple"])

        dispatchFunc(parseTupOp, from: ["<", "<=", ">", ">=", "==", "*", "\\", "+=", "-=", "%"])
    }

    /**
     Translate names and paths to Tr3, Tr3Edges, but not Tuples

     - Parameters:
         - tr3:     current Tr3
         - prior:   prior keyword
         - parItem: node in parse graph
         - level:   Level depth

     ```
     // a,b,c,d,e,f.g but not x y in
      a { b << (c ? d : e) } f.g(x y)
     ```
    */
    func parsePath(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        switch prior {

        case "edges", "ternIf", "ternThen", "ternElse", "ternRadio", "ternCompare":

            tr3.edgeDefs.lastEdgeDef().addPath(parItem)

        case "copyat":

            let _ = tr3.addChild(parItem, .copyat)

        case "tuple":
            if let val = tr3.val as? Tr3ValTuple {
                parseTupItem(val, parItem, prior)
            }

        default:
            let pattern = parItem.node?.pattern
            switch pattern {
            case "comment": tr3.comments.addComment(tr3, parItem, prior)
            case "name": return tr3.addChild(parItem, .name)
            case "path": return tr3.addChild(parItem, .path)
            default: break
            }
        }
        return tr3
    }

    func parseComma(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        if parItem.node?.pattern == "comma" {
            tr3.val?.addComma()
        }
        return tr3
    }
    func parseComment(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        if parItem.node?.pattern == "comment" {
            tr3.comments.addComment(tr3, parItem, prior)
        }
        return tr3
    }
    /// decorate current value with attributes
    func parseDeepVal(_ val: Tr3Val?,
                      _ parItem: ParItem)  {

        let pattern = parItem.node?.pattern ?? ""

        switch val {

        case let val as Tr3ValScalar:

            switch pattern {
            case "thru":  val.addFlag(.thru)
            case "modu":  val.addFlag(.modu)
            case "num":   val.addNum(parItem.getFirstFloat())
            //!! case "comma": val.addComma()

            default:     break
            }
        case let val as Tr3ValTuple:

            // tuple ~ "(" tupItems ")"
            // tupItems ~ (name | tupOp | scalar1 | ",") {2,}
            // tupOp ~ '^(< |<= |> |>= |== |\* |\\ |\+ |\- |\% )'
            switch pattern {

            case "name",
                 "scalar1",
                 "tupOper":  parseTupItem(val, parItem, pattern)
            default: break
            }
        case let val as Tr3ValTern:
            // ternary ~ "(" tern ")" | tern {
            // tern ~ ternIf ternThen ternElse? ternRadio?
            switch pattern {
            case "scalar1":
                let scalar = Tr3ValScalar()
                val.deepAddVal(scalar)
                parseDeepScalar(scalar,parItem)

            case "data":   val.deepAddVal(Tr3ValData())
            case "tuple":  val.deepAddVal(Tr3ValTuple())
            default:       parseDeepVal(val.getVal(), parItem) // decorate deepest non tern value
            }
        default: break
        }
    }
    /// decorate current value with attributes
    func parseDeepScalar(_ scalar: Tr3ValScalar,_ parItem: ParItem)  {

        let pattern = parItem.node?.pattern ?? ""

        switch pattern {
            case "thru"  : scalar.addFlag(.thru)
            case "modu"  : scalar.addFlag(.modu)
            case "num"   : scalar.addNum(parItem.getFirstFloat())
            //!! case "comma" : scalar.addComma()
            default      : break
        }
        for nextPar in parItem.nextPars {
            parseDeepScalar(scalar, nextPar)
        }
    }

    /**
     parse tuple stream

         tuple ~ "(" typeItems ")"
            typeItems ~ (name | tupOp | scalar1 | ","){2,}
            tupOp ~ '^(< |<= |> |>= |== |\* |\\ |\+ |\- |\% )'
    */
    public func parseTupItem(_ val: Tr3ValTuple?,_ parItem: ParItem,_ prior: String) {
        guard let val = val else { return }

        for par in parItem.nextPars {

            func newScalar(_ flags: Tr3ValFlags? = nil) {

                let scalar = val.addScalar()
                if let flags = flags {
                    scalar.valFlags.insert(flags)
                }
                for nextPar in par.nextPars {
                    parseDeepScalar(scalar, nextPar)
                }
            }

            let pattern = par.node?.pattern

            switch pattern {

            case "":        val.addName(par.value)
            case "name":    val.addName(par.nextPars.first?.value)
            case "tupOper": val.addOper(par.nextPars.first?.value)
            case "num":     val.addNum(parItem.getFirstFloat())
            //!! case "comma":   val.addComma()

            case "thru":    newScalar(.thru)
            case "modu":    newScalar(.modu)
            case "scalar1": newScalar()
            default: break
            }
        }
    }

    func parseTuple(_ tr3: Tr3, _ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        switch prior {
        case "many",
             "child": tr3.val = Tr3ValTuple()
        case "edges": tr3.edgeDefs.addEdgeTuple()
        default: print("*** unknown prior: \(prior)")
        }
        let pattern = parItem.node?.pattern ?? ""
        let nextTr3 = parseNext(tr3, pattern, parItem, level+1)
        return nextTr3
    }
    func parseTupOp(_ tr3: Tr3, _ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        if let val = tr3.val as? Tr3ValTuple,
           let oper = parItem.value {
            switch oper {
            case "<", "<=", ">", ">=", "==", "*", "\\", "+=", "-=", "%":
                val.addOper(oper)
            case ",": val.addComma()
            default:
                print("*** unknown prior: \(prior)")
            }
            let pattern = parItem.node?.pattern ?? ""
            let nextTr3 = parseNext(tr3, pattern, parItem, level+1)
            return nextTr3
        }
        let pattern = parItem.node?.pattern ?? ""
        let nextTr3 = parseNext(tr3, pattern, parItem, level+1)
        return nextTr3
    }

    /**
     Parse a value.

     - note: will always parse Tr3.val before a Tr3.edgeDef.val.
             So, check edgeDefs.last first.
     */
    func parseValue(_ tr3: Tr3, _ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        // 9 in `a(8) <- (b ? 9)`
        if let edgeDef = tr3.edgeDefs.edgeDefs.last {

            if let lastPath = edgeDef.pathVals.pathList.last {

                if let lastVal = edgeDef.pathVals.pathDict[lastPath], lastVal != nil {
                    parseDeepVal(lastVal, parItem)
                }
                else  { //Tr3Log.log("parseVal.B.defVal", prior, pattern)

                    func addVal(_ val: Tr3Val) { edgeDef.pathVals.add(path: lastPath, val: val) }

                    switch pattern {
                    case "embed":   addVal(Tr3ValEmbed(with: parItem.getFirstValue()))
                    case "quote":   addVal(Tr3ValQuote(with: parItem.getFirstValue()))

                    case "scalar",
                         "scalar1": addVal(Tr3ValScalar())

                    case "data":    addVal(Tr3ValData())
                    case "tuple":   addVal(Tr3ValTuple())

                    case "ternIf":  addVal(Tr3ValTern(tr3,level))
                    default:       break
                    }
                }
            }
            else if let ternVal = edgeDef.ternVal {
                 parseDeepVal(ternVal,parItem)
            }
        }
            // nil in `a*_`
        else if tr3.val == nil { //Tr3Log.log("parseVal.C.defVal", prior, pattern)

            switch pattern {
            case "embed":   tr3.val = Tr3ValEmbed(with: parItem.getFirstValue())
            case "quote":   tr3.val = Tr3ValQuote(with: parItem.getFirstValue())
            case "scalar1": tr3.val = Tr3ValScalar()
            case "data":    tr3.val = Tr3ValData()
            case "tuple":   tr3.val = Tr3ValTuple()
            default:        break
            }
        }
            // x y in `a(x y)`
        else { //Tr3Log.log("parseVal.D.defVal", prior, pattern)

            parseDeepVal(tr3.val, parItem)
            // keep prior while decorating Tr3.val
            return parseNext(tr3, prior, parItem, level+1)
        }
        return parseNext(tr3, pattern, parItem, level+1)
    }

    /// Add edges to Tr3, set state of current TernaryEdge
    func parseEdge(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern
        //log(tr3,parItem,level) // bTr3Log.log("parseEdge", prior, pattern ?? "" )

        if let pattern = pattern {

            switch pattern {
            case "edgeOp":      tr3.edgeDefs.addEdgeDef(parItem.getFirstValue())
            case "edges":       break
            case "ternIf":      tr3.edgeDefs.addEdgeTernary(Tr3ValTern(tr3,level))
            case "ternThen":    Tr3ValTern.setTernState(.Then,  level)
            case "ternElse":    Tr3ValTern.setTernState(.Else,  level)
            case "ternRadio":   Tr3ValTern.setTernState(.Radio, level)
            case "ternCompare": Tr3ValTern.setCompare(parItem.getFirstValue())
            default: break
            }
            return parseNext(tr3, pattern, parItem, level+1)
        }
        return tr3
    }

    /** Parse ParItem into a tree.

    Here are examples of how a parse generates a NodeAny

            a { b c } ⟹
            child:(name:a, child:(name:b, name:c))

            a { b { c } } ⟹
            child:(name:a, child:(name:b, child:name:c))

            a { b { c } d { e } } ⟹
            child:(name:a, child:(name:b, child:name:c, name:d, child:name:e))

     below shows a parse for a "many",
     where indentation on the left side represents
     level of recursion, for calling a ParItem.next.children's nodes

            a {b c}.{d e} ⟹
            child(name:a, child(name:b, name:c), many(name:d, name:e))

            (√,child)         [name, child, many]
                (√,name)       [a]
                (a,child)      [name, name]
                    (a,name)    [b]
                    (a,name)    [c]
                (a,many)       [name, name]
                    (_:_,name)  [d]
                    (_:_,name)  [e]

            √ { a { b { d e } c { d e } } }
     */
    func parseChild(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        switch pattern {
        case "comment": tr3.comments.addComment(tr3, parItem, prior)
        case "name": return tr3.addChild(parItem,.name)
        case "path": return tr3.addChild(parItem,.path)
        default:     break
        }

        let parentTr3 = pattern == "many" ? tr3.makeMany() : tr3
        var nextTr3 = parentTr3

        for nextPar in parItem.nextPars {

            switch  nextPar.node?.pattern  {

            case "child", "many": // push child of most recent name'd sibling to the next level

                let _ = self.parse(nextTr3, pattern, nextPar, level+1)

            case "name", "path": // add new named sibling to parent

                nextTr3 = self.parse(parentTr3, pattern, nextPar, level+1)

            default: // decorate current sibling with new values

                nextTr3 = self.parse(nextTr3, pattern, nextPar, level+1)
            }
        }
        return nextTr3
    }
    /** decorate current tr3 with additional attributes */
    func parseNext(_ tr3: Tr3,_ prior: String,_ parItem: ParItem,_ level: Int) -> Tr3 {

        for nextPar in parItem.nextPars {
            let _ = self.parse(tr3, prior, nextPar, level+1)
        }
        return tr3
    }

    /** Dispatch tr3Parse closure based on `pattern`

    find corresponding tr3Parse dispatch to either
        - parsePath
        - parseValue
        - parseEdge
     */
    func parse(_ tr3: Tr3,_ prior: String,_ parItem: ParItem,_ level: Int) -> Tr3 {

        log(tr3, parItem, level)

        if  let pattern = parItem.node?.pattern,
            let tr3Parse = tr3Keywords[pattern] {

            return tr3Parse(tr3, prior, parItem, level+1)

        }
        // `^( < | <= | > | >= | == | \* | \\ | \+= | \-= | \% )`
        else if let value = parItem.value,
                let tr3Parse = tr3Keywords[value] {
            return tr3Parse(tr3, prior, parItem, level+1)
        }
        return tr3
    }

    /** From root, parse script, deliminted by whitespace

    - Parameters:
        - root: starting node from which to attach subtree
        - script: text of script to convert into subtree
        - whitespace: default is single line, may add \n for multiline script
    */
    public func parseScript(_ root:     Tr3,
                            _ script:   String,
                            whitespace: String = "\n\t ",
                            printGraph: Bool = false) -> Bool {

        // ParStr.tracing = true
        // Tr3.BindDumpScript = true
        // Tr3.BindMakeScript = true

        let parStr = ParStr(script)
        parStr.whitespace = whitespace
    
        if let parItem = rootParNode.findMatch(parStr, 0).parLast {

            if printGraph {
                rootParNode.printGraph(Visitor(0))
            }
            // reduce to keywords in tr3Keywords and print
            let reduce1 = parItem.reduceStart(tr3Keywords)
            let _ = parse(root, "", reduce1, 0)
            root.bindRoot()
           
            return true
        }
        return false
    }
}
