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
        if let tr3Root = Par.shared.parse(script: Tr3Par) {
            rootParNode = tr3Root
            rootParNode.reps.repMax = Int.max
            makeParTr3()
        } else {
            rootParNode = ParNode("",[])
            print("🚫 Tr33Parse::init could not parse Tr3Par")
        }

        // make a dispatch dictionary of parsing closures
        func makeParTr3() {

            func dispatchFunc(_ fn: @escaping Tr3PriorParItem, from keywords: [String]) {
                for keyword in keywords { tr3Keywords[keyword] = fn }
            }
            dispatchFunc(parseLeft, from: ["name", "path"])

            dispatchFunc(parseComment, from: ["comment"])

            dispatchFunc(parseTree, from: ["child", "many", "copyat"])

            dispatchFunc(parseValue, from: ["data",
                                            "scalar1",
                                            "thru", "modu", "num",
                                            "quote", "embed", "expr"])

            dispatchFunc(parseEdge, from: ["edges", "edgeOp",
                                           "ternIf", "ternThen", "ternElse",
                                           "ternRadio","ternCompare"])

            dispatchFunc(parseExprs, from: ["exprs"])
        }
    }

    // MARK: - names paths comments

    ///  Dispatched: parse lvalue name, paths to Tr3, Tr3Edges, but not Exprs
    ///
    ///  - Parameters:
    ///      - tr3:     current Tr3
    ///      - prior:   prior keyword
    ///      - parItem: node in parse graph
    ///      - level:   Level depth
    ///
    ///
    ///   a, b, c, d, e, f.g but not x y in
    ///
    ///      a { b << (c ? d : e) } f.g(x y)
    ///
    func parseLeft(_ tr3: Tr3,
                   _ prior: String,
                   _ parItem: ParItem,
                   _ level: Int) -> Tr3 {

        switch prior {

            case "edges", "ternIf", "ternThen", "ternElse", "ternRadio", "ternCompare":

                tr3.edgeDefs.lastEdgeDef().addPath(parItem)

            case "copyat":

                let _ = tr3.addChild(parItem, .copyat)

            case "expr":
                if let edgeDef = tr3.edgeDefs.edgeDefs.last,
                   let edgePath = edgeDef.pathVals.pathVal.keys.last,
                   let edgeVal = edgeDef.pathVals.pathVal[edgePath] as? Tr3Exprs {

                    parseNextExpr(edgeVal, parItem, prior)
                }
                else if let tr3Val = tr3.val as? Tr3Exprs {

                    parseNextExpr(tr3Val, parItem, prior)
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

    /// Dispatched: Parse a comment or comma (which is a micro comment)
    ///
    func parseComment(_ tr3: Tr3,
                      _ prior: String,
                      _ parItem: ParItem,
                      _ level: Int) -> Tr3 {

        if parItem.node?.pattern == "comment" {
            tr3.comments.addComment(tr3, parItem, prior)
        }
        return tr3
    }

    // MARK: - values

    ///
    /// decorate current value with attributes
    ///
    func parseDeepVal(_ tr3: Tr3,
                      _ val: Tr3Val?,
                      _ parItem: ParItem)  {

        let pattern = parItem.node?.pattern ?? ""

        switch val {
            case let val as Tr3ValScalar: parseDeepScalar(val, parItem)
            case let val as Tr3Exprs:     parseNextExpr(val, parItem, pattern)
            case let val as Tr3ValTern:   parseTernary(tr3, val, parItem, pattern)
            default: break
        }
    }

    ///
    /// parse Ternary
    ///
    func parseTernary(_ tr3: Tr3,
                      _ val: Tr3ValTern,
                      _ parItem: ParItem,
                      _ pattern: String)  {
        switch pattern {

            case "scalar1":
                let scalar = Tr3ValScalar(tr3)
                val.deepAddVal(scalar)
                parseDeepScalar(scalar, parItem)

            case "data":  val.deepAddVal(Tr3ValData(tr3))
            case "exprs": val.deepAddVal(Tr3Exprs(tr3))
            default: parseDeepVal(tr3, val.getVal(), parItem) // decorate deepest non tern value
        }
    }
    ///
    /// decorate current value with attributes
    ///
    func parseDeepScalar(_ scalar: Tr3ValScalar,
                         _ parItem: ParItem)  {

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

    ///
    /// parse next expression
    ///
    ///     exprs ~ "(" expr+ ("," expr+)* ")" {
    ///         expr ~ (exprOp | name | scalars | scalar1 | quote)
    ///         exprOp ~ '^(<=|>=|==|<|>|\*|\/|\+[ ]|\-[ ]|in)'
    ///     }
    ///
    func parseNextExpr(_ exprs: Tr3Exprs,
                       _ parItem: ParItem,
                       _ prior: String) {

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
            func addExprOp() {
                exprs.addOpStr(nextPar.value)
            }
            func nextNextVal() -> String? {
                if let str = nextPar.nextPars.first?.value {
                    return str
                } else {
                    print("🚫 \(#function) unexpected value for \(pattern)")
                }
                return nil
            }
            let pattern = nextPar.node?.pattern
            switch pattern {
                case ""        : exprs.addOpStr(nextPar.value)
                case "name"    : exprs.addName(nextNextVal())
                case "quote"   : exprs.addQuote(nextNextVal())
                case "scalar1" : addDeepScalar()
                default        : break
            }
        }
    }

    /// Dispatched: parse first expression in left value or edge
    ///
    func parseExprs(_ tr3: Tr3,
                    _ prior: String,
                    _ parItem: ParItem,
                    _ level: Int) -> Tr3 {
        switch prior {
            case "many",
                "child":

                tr3.val = Tr3Exprs(tr3)
                
            case "edges":

                tr3.edgeDefs.addEdgeExprs(tr3)

            default: print("🚫 unknown prior: \(prior)")
        }
        let pattern = parItem.node?.pattern ?? ""
        let nextTr3 = parseNext(tr3, pattern, parItem, level+1)
        return nextTr3
    }

    ///  Dispatched: Parse a Tr3Val
    ///
    ///  Will always parse `Tr3.val` before a `Tr3.edgeDef.val`.
    ///  So, check edgeDefs.last first.
    ///
    func parseValue(_ tr3: Tr3,
                    _ prior: String,
                    _ parItem: ParItem,
                    _ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        if let edgeDef = tr3.edgeDefs.edgeDefs.last {

            return parseEdgeDef(tr3, edgeDef, parItem, level)

        } else if tr3.val == nil {
            // nil in `a*_`
            switch pattern {
                case "embed"    : tr3.val = Tr3ValEmbed(tr3, str: parItem.getFirstValue())
                case "scalar1"  : tr3.val = Tr3ValScalar(tr3)
                case "data"     : tr3.val = Tr3ValData(tr3)
                case "exprs"    : tr3.val = Tr3Exprs(tr3)
                default         : break
            }
        } else {
            // x y in `a(x y)`
            parseDeepVal(tr3, tr3.val, parItem)
            // keep prior while decorating Tr3.val
            return tr3
        }
        return parseNext(tr3, pattern, parItem, level+1)
    }

    func parseEdgeDef(_ tr3: Tr3,
                      _ edgeDef: Tr3EdgeDef,
                      _ parItem: ParItem,
                      _ level: Int) -> Tr3 {
        let pattern = parItem.node?.pattern ?? ""
        // 9 in `a(8) <- (b ? 9)`
        if let path = edgeDef.pathVals.pathVal.keys.last {

            if let lastVal = edgeDef.pathVals.pathVal[path], lastVal != nil {
                parseDeepVal(tr3, lastVal, parItem)
                return tr3

            } else  {
                func addVal(_ val: Tr3Val) { edgeDef.pathVals.add(path: path, val: val) }
                switch pattern {
                    case "embed"   : addVal(Tr3ValEmbed(tr3, str: parItem.getFirstValue()))
                    case "scalar1" : addVal(Tr3ValScalar(tr3))
                    case "data"    : addVal(Tr3ValData(tr3))
                    case "exprs"   : addVal(Tr3Exprs(tr3))
                    case "ternIf"  : addVal(Tr3ValTern(tr3, level))
                    default        : break
                }
            }

        } else if let ternVal = edgeDef.ternVal {

            parseDeepVal(tr3, ternVal, parItem)
        }
        return parseNext(tr3, pattern, parItem, level+1)
    }
    // MARK: - Tree Graph

    /// Dispatched: add edges to Tr3, set state of current TernaryEdge
    ///
    func parseEdge(_ tr3: Tr3,
                   _ prior: String,
                   _ parItem: ParItem,
                   _ level: Int) -> Tr3 {

        if let pattern = parItem.node?.pattern {

            switch pattern {
                case "edgeOp":
                    let firstVal = parItem.getFirstValue()
                    tr3.edgeDefs.addEdgeDef(firstVal)
                case "edges":
                    let firstVal = parItem.getFirstValue()
                    tr3.edgeDefs.addEdgeDef(firstVal)//??? break
                case "ternIf"      : tr3.edgeDefs.addEdgeTernary(Tr3ValTern(tr3, level))
                case "ternThen"    : Tr3ValTern.setTernState(.Then,  level)
                case "ternElse"    : Tr3ValTern.setTernState(.Else,  level)
                case "ternRadio"   : Tr3ValTern.setTernState(.Radio, level)
                case "ternCompare" : Tr3ValTern.setCompare(parItem.getFirstValue())
                default            : break
            }
            return parseNext(tr3, pattern, parItem, level+1)
        }
        return tr3
    }

    /// Dispatched: Parse ParItem into a tree
    ///
    func parseTree(_ tr3: Tr3,
                   _ prior: String,
                   _ parItem: ParItem,
                   _ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        switch pattern {
            case "name"     : return tr3.addChild(parItem, .name)
            case "path"     : return tr3.addChild(parItem, .path)
            case "comment"  : tr3.comments.addComment(tr3, parItem, prior)
            default         : break
        }

        let parentTr3 = pattern == "many" ? tr3.makeMany() : tr3
        var nextTr3 = parentTr3

        for nextPar in parItem.nextPars {

            switch  nextPar.node?.pattern  {

                case "child", "many":
                    // push child of most recent name'd sibling to the next level
                    let _ = self.dipatchParse(nextTr3, pattern, nextPar, level+1)

                case "name", "path":
                    // add new named sibling to parent
                    nextTr3 = self.dipatchParse(parentTr3, pattern, nextPar, level+1)

                default:
                    // decorate current sibling with new values
                    nextTr3 = self.dipatchParse(nextTr3, pattern, nextPar, level+1)
            }
        }
        return nextTr3
    }

    // MARK: - script

   ///  decorate current tr3 with additional attributes
   ///
    func parseNext(_ tr3: Tr3,
                   _ prior: String,
                   _ parItem: ParItem,
                   _ level: Int) -> Tr3 {

        for nextPar in parItem.nextPars {
            let _ = self.dipatchParse(tr3, prior, nextPar, level+1)
        }
        return tr3
    }

    ///  Dispatch tr3Parse closure based on `pattern`
    ///
    /// find corresponding tr3Parse dispatch to either
    ///     - parseLeft
    ///     - parseValue
    ///     - parseEdge
    ///
    func dipatchParse(_ tr3: Tr3,
                       _ prior: String,
                       _ parItem: ParItem,
                       _ level: Int) -> Tr3 {

        // log(tr3, parItem, level)  // log progress through parse, here

        if  let pattern = parItem.node?.pattern,
            let tr3Parse = tr3Keywords[pattern] {

            return tr3Parse(tr3, prior, parItem, level+1)
        }
        // `^( < | <= | > | >= | == | *[ ] | \[ ] | +[ ] | -[ ] | \% )`
        else if let value = parItem.value,
                let tr3Parse = tr3Keywords[value] {
            
            return tr3Parse(tr3, prior, parItem, level+1)
        }
        return tr3
    }

    ///  Parse script, starting from  root, deliminted by whitespace
    ///
    /// - Parameters:
    ///     - root: starting node from which to attach subtree
    ///     - script: text of script to convert into subtree
    ///     - whitespace: default is single line, may add \n for multiline script
    ///
    public func parseScript(_ root:     Tr3,
                            _ script:   String,
                            whitespace: String = "\n\t ",
                            printGraph: Bool = false,
                            tracePar: Bool = false) -> Bool {

        ParStr.tracing = tracePar
        Tr3.LogBindScript = false
        Tr3.LogMakeScript = false

        let parStr = ParStr(script)
        parStr.whitespace = whitespace
    
        if let parItem = rootParNode.findMatch(parStr, 0).parLast {

            if printGraph {
                rootParNode.printGraph(Visitor(0))
            }
            // reduce to keywords in tr3Keywords and print
            let reduce1 = parItem.reduceStart(tr3Keywords)
            let _ = dipatchParse(root, "", reduce1, 0)
            root.bindRoot()
           
            return true
        }
        return false
    }
}
