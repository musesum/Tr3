//  Tr3Parse.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

public class Tr3Parse {

    public static let shared = Tr3Parse()
    private var rootParNode: ParNode
    private var tr3Keywords = [String: Tr3PriorParItem]()

    public init() {
        rootParNode = Par.shared.parse(script: Tr3Par)
        rootParNode.reps.repMax = Int.max
        makeParTr3()
    }
    /**
     create a dictionary of parsing closures as a global dispatch
     */
    func makeParTr3() {

        func dispatchFunc(_ fn: @escaping Tr3PriorParItem, from keywords: [String]) {
            for keyword in keywords { tr3Keywords[keyword] = fn }
        }
        dispatchFunc(parseLeft, from: ["name", "path"])

        dispatchFunc(parseComment, from: ["comment"])

        dispatchFunc(parseBranch, from: ["child", "many", "copyat"])

        dispatchFunc(parseValue, from: ["data",
                                        "scalar1",
                                        "thru", "modu", "num",
                                        "quote", "embed", "expr"])

        dispatchFunc(parseEdge, from: ["edges", "edgeOp",
                                       "ternIf", "ternThen", "ternElse",
                                       "ternRadio","ternCompare"])

        dispatchFunc(parseExprs, from: ["exprs"])

        dispatchFunc(parseExprOp, from: ["<", "<=", ">", ">=", "==", "*",
                                        "/", "+=", "-=", "%", "in"])
    }
    /**
     Translate names and paths to Tr3, Tr3Edges, but not Exprs

     - Parameters:
         - tr3:     current Tr3
         - prior:   prior keyword
         - parItem: node in parse graph
         - level:   Level depth

     ```
     // a, b, c, d, e, f.g but not x y in
      a { b << (c ? d : e) } f.g(x y)
     ```
    */
    func parseLeft(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {

        switch prior {

        case "edges", "ternIf", "ternThen", "ternElse", "ternRadio", "ternCompare":

            tr3.edgeDefs.lastEdgeDef().addPath(parItem)

        case "copyat":

            let _ = tr3.addChild(parItem, .copyat)

        case "expr":
            if let edgeDef = tr3.edgeDefs.edgeDefs.last,
               let edgePath = edgeDef.pathVals.pathList.last,
               let edgeVal = edgeDef.pathVals.pathDict[edgePath] as? Tr3Exprs {

                parseExpression(edgeVal, parItem, prior)
            }
            else if let tr3Val = tr3.val as? Tr3Exprs {
                
                parseExpression(tr3Val, parItem, prior)
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
    /**
     Parse a comment or comma (which is a micro comment)
     */
    func parseComment(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {
        if let pattern = parItem.node?.pattern {

            switch pattern {
            case "comment": tr3.comments.addComment(tr3, parItem, prior)
            default: break
            }
        }
        return tr3
    }
    /**
     decorate current value with attributes
     */
    func parseDeepVal(_ val: Tr3Val?, _ parItem: ParItem)  {

        let pattern = parItem.node?.pattern ?? ""

        switch val {
            
            case let val as Tr3ValScalar:

                parseDeepScalar(val, parItem)

            case let val as Tr3Exprs:

                 parseExpression(val, parItem, pattern)

            case let val as Tr3ValTern:
                // ternary ~ "(" tern ")" | tern {
                // tern ~ ternIf ternThen ternElse? ternRadio?
                switch pattern {
                    
                    case "scalar1":
                        let scalar = Tr3ValScalar()
                        val.deepAddVal(scalar)
                        parseDeepScalar(scalar, parItem)
                        
                    case "data":  val.deepAddVal(Tr3ValData())
                    case "exprs": val.deepAddVal(Tr3Exprs())
                    default: parseDeepVal(val.getVal(), parItem) // decorate deepest non tern value
                }
            default: break
        }
    }
    /**
        decorate current value with attributes
     */
    func parseDeepScalar(_ scalar: Tr3ValScalar, _ parItem: ParItem)  {

        let pattern = parItem.node?.pattern ?? ""

        switch pattern {
            case "thru": scalar.addFlag(.thru)
            case "modu": scalar.addFlag(.modu)
            case "num":  scalar.addNum(parItem.getFirstFloat())
            default:     break
        }
        for nextPar in parItem.nextPars {
            parseDeepScalar(scalar, nextPar)
        }
    }
    /**
        parse expression

            exprs ~ "(" expr{2,} ")" {
                expr ~ (exprOp | name | scalar1)+ comma?
                exprOp ~ '^(<=|>=|==|<|>|\*|\/|\+|\-|\%|in)'
            }
     */
    public func parseExpression(_ exprs: Tr3Exprs?, _ parItem: ParItem, _ prior: String) {
        guard let exprs = exprs else { return }

        if prior == "expr" {
            exprs.addExpr()
        }

        for nextPar in parItem.nextPars {

            func addDeepScalar() {
                let scalar = exprs.addScalar()
                for deepPar in nextPar.nextPars {
                    parseDeepScalar(scalar, deepPar)
                }
            }
            func addEmptyPattern() {
                if prior != "num" {
                    exprs.addOper(nextPar.value)
                } else {
                    print("*** unexpected \(#function)")
                }
            }
            func addName() {
                if let name = nextPar.nextPars.first?.value {
                    exprs.addName(name)
                } else {
                    print("*** unexpected \(#function)")
                }
            }
            func addOper() {
                if let oper = nextPar.nextPars.first?.value {
                    exprs.addOper(oper)
                } else {
                    print("*** unexpected \(#function)")
                }
            }

            let pattern = nextPar.node?.pattern
            switch pattern {
                case "":        addEmptyPattern()
                case "name":    addName()
                case "exprOp":  addOper()
                case "scalar1": addDeepScalar()
                default: break
            }
        }
    }
    /**

     */
    func parseExprs(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {

        switch prior {
        case "many",
             "child": tr3.val = Tr3Exprs()

        case "edges": tr3.edgeDefs.addEdgeExprs()

        default: print("*** unknown prior: \(prior)")
        }
        let pattern = parItem.node?.pattern ?? ""
        let nextTr3 = parseNext(tr3, pattern, parItem, level+1)
        return nextTr3
    }
    /**

     */
    func parseExprOp(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {

        if let val = tr3.val as? Tr3Exprs,
           let oper = parItem.value {
            switch oper {
            case "<", "<=", ">", ">=", "==",
                 "*", "/", "+", "-", "%", "in":
                val.addOper(oper)
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
    func parseValue(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        // 9 in `a(8) <- (b ? 9)`
        if let edgeDef = tr3.edgeDefs.edgeDefs.last {

            if let lastPath = edgeDef.pathVals.pathList.last {

                if let lastVal = edgeDef.pathVals.pathDict[lastPath], lastVal != nil {
                    parseDeepVal(lastVal, parItem)
                    return tr3
                }
                else  {

                    func addVal(_ val: Tr3Val) { edgeDef.pathVals.add(path: lastPath, val: val) }

                    switch pattern {
                    case "embed":   addVal(Tr3ValEmbed(with: parItem.getFirstValue()))
                    case "quote":   addVal(Tr3ValQuote(with: parItem.getFirstValue()))

                    case "scalar",
                         "scalar1": addVal(Tr3ValScalar())

                    case "data":    addVal(Tr3ValData())
                    case "exprs":   addVal(Tr3Exprs())

                    case "ternIf":  addVal(Tr3ValTern(tr3, level))
                    default:       break
                    }
                }
            }
            else if let ternVal = edgeDef.ternVal {
                 parseDeepVal(ternVal, parItem)
            }
        }
            // nil in `a*_`
        else if tr3.val == nil {

            switch pattern {
            case "embed":   tr3.val = Tr3ValEmbed(with: parItem.getFirstValue())
            case "quote":   tr3.val = Tr3ValQuote(with: parItem.getFirstValue())
            case "scalar1": tr3.val = Tr3ValScalar()
            case "data":    tr3.val = Tr3ValData()
            case "exprs":   tr3.val = Tr3Exprs()
            default:        break
            }
        }
            // x y in `a(x y)`
        else {
            parseDeepVal(tr3.val, parItem)
            // keep prior while decorating Tr3.val
            return tr3
        }
        return parseNext(tr3, pattern, parItem, level+1)
    }
    /**
     Add edges to Tr3, set state of current TernaryEdge */
    func parseEdge(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern

        if let pattern = pattern {

            switch pattern {
            case "edgeOp":      tr3.edgeDefs.addEdgeDef(parItem.getFirstValue())
            case "edges":       break
            case "ternIf":      tr3.edgeDefs.addEdgeTernary(Tr3ValTern(tr3, level))
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
    /**
     Parse ParItem into a tree.

    Here are examples of how a parse generates a NodeAny

            a { b c } ⟹
            child:(name: a, child:(name: b, name: c))

            a { b { c } } ⟹
            child:(name: a, child:(name: b, child: name: c))

            a { b { c } d { e } } ⟹
            child:(name: a, child:(name: b, child: name: c, name: d, child: name: e))

     below shows a parse for a "many",
     where indentation on the left side represents
     level of recursion, for calling a ParItem.next.children's nodes

            a {b c}.{d e} ⟹
            child(name: a, child(name: b, name: c), many(name: d, name: e))

            (√, child)         [name, child, many]
                (√, name)       [a]
                (a, child)      [name, name]
                    (a, name)    [b]
                    (a, name)    [c]
                (a, many)       [name, name]
                    (_:_, name)  [d]
                    (_:_, name)  [e]

            √ { a { b { d e } c { d e } } }
     */
    func parseBranch(_ tr3: Tr3, _ prior: String, parItem: ParItem, _ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        switch pattern {
        case "name": return tr3.addChild(parItem, .name)
        case "path": return tr3.addChild(parItem, .path)
        case "comment": tr3.comments.addComment(tr3, parItem, prior)
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
    /**
     decorate current tr3 with additional attributes */
    func parseNext(_ tr3: Tr3, _ prior: String, _ parItem: ParItem, _ level: Int) -> Tr3 {

        for nextPar in parItem.nextPars {
            let _ = self.parse(tr3, prior, nextPar, level+1)
        }
        return tr3
    }
    /**
     Dispatch tr3Parse closure based on `pattern`

    find corresponding tr3Parse dispatch to either
        - parseLeft
        - parseValue
        - parseEdge
     */
    func parse(_ tr3: Tr3, _ prior: String, _ parItem: ParItem, _ level: Int) -> Tr3 {

        // log progress through parse, here !!
        // log(tr3, parItem, level)

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
    /**
     From root, parse script, deliminted by whitespace

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
