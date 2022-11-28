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
            dispatchFunc(parseHash, from: ["hash"])
            dispatchFunc(parseTime, from: ["time"])

            dispatchFunc(parseTree, from: ["child", "many", "copyat"])

            dispatchFunc(parseValue, from: ["data",
                                            "scalar1",
                                            "thru", "modu", "dflt", "now", "num",
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
    ///      - par: node in parse graph
    ///      - level:   Level depth
    ///
    ///
    ///   a, b, c, d, e, f.g but not x y in
    ///
    ///      a { b << (c ? d : e) } f.g(x y)
    ///
    func parseLeft(_ tr3: Tr3,
                   _ prior: String,
                   _ par: ParItem,
                   _ level: Int) -> Tr3 {

        switch prior {

            case "edges", "ternIf", "ternThen", "ternElse", "ternRadio", "ternCompare":

                tr3.edgeDefs.lastEdgeDef().addPath(par)

            case "copyat":

                let _ = tr3.addChild(par, .copyat)

            case "expr":
                if let edgeDef = tr3.edgeDefs.edgeDefs.last,
                   let edgePath = edgeDef.pathVals.pathVal.keys.last,
                   let edgeVal = edgeDef.pathVals.pathVal[edgePath] as? Tr3Exprs {

                    parseNextExpr(tr3, edgeVal, par, prior)
                }
                else if let tr3Val = tr3.val as? Tr3Exprs {

                    parseNextExpr(tr3, tr3Val, par, prior)
                }

            default:
                let pattern = par.node?.pattern
                switch pattern {
                    case "comment": tr3.comments.addComment(tr3, par, prior)
                    case "name": return tr3.addChild(par, .name)
                    case "path": return tr3.addChild(par, .path)
                    default: break
                }
        }
        return tr3
    }



    /// Dispatched: Parse a hash value.
    /// Usually at runtime for synchronizing values v
    ///
    func parseHash(_ tr3: Tr3,
                   _ prior: String,
                   _ par: ParItem,
                   _ level: Int) -> Tr3 {

        if par.node?.pattern == "hash" {
            tr3.parseHash(par.getFirstDouble())
        }
        return tr3
    }
    /// Dispatched: Parse a time of change.
    /// Usually at runtime for recording and playback values.
    /// Or for menu tree to bookmark most rececently used. 
    ///
    func parseTime(_ tr3: Tr3,
                   _ prior: String,
                   _ par: ParItem,
                   _ level: Int) -> Tr3 {

        if par.node?.pattern == "time" {
            tr3.parseHash(par.getFirstDouble())
        }
        return tr3
    }



    /// Dispatched: Parse a comment or comma (which is a micro comment)
    ///
    func parseComment(_ tr3: Tr3,
                      _ prior: String,
                      _ par: ParItem,
                      _ level: Int) -> Tr3 {

        if par.node?.pattern == "comment" {
            tr3.comments.addComment(tr3, par, prior)
        }
        return tr3
    }

    // MARK: - values

    ///
    /// decorate current value with attributes
    ///
    func parseDeepVal(_ tr3: Tr3,
                      _ val: Tr3Val?,
                      _ par: ParItem)  {

        let pattern = par.node?.pattern ?? ""

        switch val {
            case let val as Tr3ValScalar: parseDeepScalar(val, par)
            case let val as Tr3Exprs:     parseNextExpr(tr3, val, par, pattern)
            case let val as Tr3ValTern:   parseTernary(tr3, val, par, pattern)
            default: break
        }
    }

    /// parse Ternary
    ///
    func parseTernary(_ tr3: Tr3,
                      _ val: Tr3ValTern,
                      _ par: ParItem,
                      _ pattern: String)  {
        switch pattern {

            case "scalar1":
                let scalar = Tr3ValScalar(tr3)
                val.deepAddVal(scalar)
                parseDeepScalar(scalar, par)

            case "data":  val.deepAddVal(Tr3ValData(tr3))
            case "exprs": val.deepAddVal(Tr3Exprs(tr3))
            default: parseDeepVal(tr3, val.getVal(), par) // decorate deepest non tern value
        }
    }

    /// decorate current scalar with min, …, max, num, = dflt
    ///
    func parseDeepScalar(_ scalar: Tr3ValScalar,
                         _ par: ParItem)  {

        let pattern = par.node?.pattern ?? ""

        switch pattern {
            case "thru": scalar.addFlag(.thru)
            case "modu": scalar.addFlag(.modu)
            case "num" : scalar.parseNum(par.getFirstDouble())
            case "dflt": scalar.parseDflt(par.getFirstDouble())
            case "now" : scalar.parseNow(par.getFirstDouble())
            default:     break
        }
        for nextPar in par.nextPars {
            parseDeepScalar(scalar, nextPar)
        }
    }

    /// parse next expression
    ///
    ///     exprs ~ "(" expr+ ("," expr+)* ")" {
    ///         expr ~ (exprOp | name | scalars | scalar1 | quote)
    ///         exprOp ~ '^(<=|>=|==|<|>|\*|\/|\+[ ]|\-[ ]|in)'
    ///     }
    ///
    func parseNextExpr(_ tr3: Tr3,
                       _ exprs: Tr3Exprs,
                       _ par: ParItem,
                       _ prior: String) {

        var hasOp = false
        var hasIn = false
        var scalar: Tr3ValScalar?
        var name: String?

        for nextPar in par.nextPars {
            let pattern = nextPar.node?.pattern
            switch pattern {
                case ""        : addExprOp(nextPar)
                case "name"    : addName(nextPar)
                case "quote"   : addQuote(nextPar)
                case "scalar1" : addDeepScalar(nextPar)
                default        : break
            }
        }
        finishExpr()
        func finishExpr() {
            if hasIn, let name, let scalar {
                hasIn = false
                let copy = scalar.copy()
                exprs.nameAny[name] = copy
            }
        }
        func addDeepScalar(_ nextPar: ParItem) {
            scalar = Tr3ValScalar(tr3)
            guard let scalar else { return }

            if hasOp {
                /// `c` in `a(b < c)` so don't add nameAny["c"]
                exprs.addScalar(scalar)
            } else {
                /// `b` in `a(b < c)` so add a nameAny["c"]
                exprs.addDeepScalar(scalar)
            }
            for deepPar in nextPar.nextPars {
                parseDeepScalar(scalar, deepPar)
            }
        }
        func addName(_ nextPar: ParItem)  {
            name = nextNextVal(nextPar)
            exprs.addName(name)
        }
        func addQuote(_ nextPar: ParItem)  {
            exprs.addQuote(nextNextVal(nextPar))
        }

        func addExprOp(_ nextPar: ParItem)  {

            let val = nextPar.value
            exprs.addOpStr(val)
            switch val {
                case ",":
                    finishExpr()
                    hasOp = false

                case "in":

                    hasOp = true
                    hasIn = true

                default:
                    hasOp = true
            }
        }
        func nextNextVal(_ nextPar: ParItem) -> String? {
            if let str = nextPar.nextPars.first?.value {
                return str
            } else {
                print("🚫 \(#function) unexpected value for \(nextPar.node?.pattern.description ?? "")")
            }
            return nil
        }
    }

    /// Dispatched: parse first expression in left value or edge
    ///
    func parseExprs(_ tr3: Tr3,
                    _ prior: String,
                    _ par: ParItem,
                    _ level: Int) -> Tr3 {
        switch prior {
            case "many",
                "child":

                tr3.val = Tr3Exprs(tr3)
                
            case "edges":

                tr3.edgeDefs.parseEdgeExprs(tr3)

            default: print("🚫 unknown prior: \(prior)")
        }
        let pattern = par.node?.pattern ?? ""
        let nextTr3 = parseNext(tr3, pattern, par, level+1)
        return nextTr3
    }

    ///  Dispatched: Parse a Tr3Val
    ///
    ///  Will always parse `Tr3.val` before a `Tr3.edgeDef.val`.
    ///  So, check edgeDefs.last first.
    ///
    func parseValue(_ tr3: Tr3,
                    _ prior: String,
                    _ par: ParItem,
                    _ level: Int) -> Tr3 {

        let pattern = par.node?.pattern ?? ""

        if let edgeDef = tr3.edgeDefs.edgeDefs.last {

            return parseEdgeDef(tr3, edgeDef, par, level)

        } else if tr3.val == nil {
            // nil in `a*_`
            switch pattern {
                case "embed"    : tr3.val = Tr3ValEmbed(tr3, str: par.getFirstValue())
                case "scalar1"  : tr3.val = Tr3ValScalar(tr3)
                case "data"     : tr3.val = Tr3ValData(tr3)
                case "exprs"    : tr3.val = Tr3Exprs(tr3)
                default         : break
            }
        } else {
            // x y in `a(x y)`
            parseDeepVal(tr3, tr3.val, par)
            // keep prior while decorating Tr3.val
            return tr3
        }
        return parseNext(tr3, pattern, par, level+1)
    }

    func parseEdgeDef(_ tr3: Tr3,
                      _ edgeDef: Tr3EdgeDef,
                      _ par: ParItem,
                      _ level: Int) -> Tr3 {

        let pattern = par.node?.pattern ?? ""
        // 9 in `a(8) <- (b ? 9)`
        if let path = edgeDef.pathVals.pathVal.keys.last {

            if let lastVal = edgeDef.pathVals.pathVal[path], lastVal != nil {
                parseDeepVal(tr3, lastVal, par)
                return tr3

            } else  {
                func addVal(_ val: Tr3Val) {
                    edgeDef.pathVals.add(path: path, val: val)
                }
                switch pattern {
                    case "embed"   : addVal(Tr3ValEmbed(tr3, str: par.getFirstValue()))
                    case "scalar1" : addVal(Tr3ValScalar(tr3))
                    case "data"    : addVal(Tr3ValData(tr3))
                    case "exprs"   : addVal(Tr3Exprs(tr3))
                    case "ternIf"  : addVal(Tr3ValTern(tr3, level))
                    default        : break
                }
            }

        } else if let ternVal = edgeDef.ternVal {

            parseDeepVal(tr3, ternVal, par)
        }
        return parseNext(tr3, pattern, par, level+1)
    }
    // MARK: - Tree Graph

    /// Dispatched: add edges to Tr3, set state of current TernaryEdge
    ///
    func parseEdge(_ tr3: Tr3,
                   _ prior: String,
                   _ par: ParItem,
                   _ level: Int) -> Tr3 {

        if let pattern = par.node?.pattern {

            switch pattern {
                case "edgeOp"      : tr3.edgeDefs.addEdgeDef(par.getFirstValue())
                case "edges"       : tr3.edgeDefs.addEdgeDef(par.getFirstValue())
                case "ternIf"      : tr3.edgeDefs.addEdgeTernary(Tr3ValTern(tr3, level))
                case "ternThen"    : Tr3ValTern.setTernState(.thenVal,  level)
                case "ternElse"    : Tr3ValTern.setTernState(.elseVal,  level)
                case "ternRadio"   : Tr3ValTern.setTernState(.radioVal, level)
                case "ternCompare" : Tr3ValTern.setCompare(par.getFirstValue())
                default            : break
            }
            return parseNext(tr3, pattern, par, level+1)
        }
        return tr3
    }

    /// Dispatched: Parse ParItem into a tree
    ///
    func parseTree(_ tr3: Tr3,
                   _ prior: String,
                   _ par: ParItem,
                   _ level: Int) -> Tr3 {

        let pattern = par.node?.pattern ?? ""

        switch pattern {
            case "name"     : return tr3.addChild(par, .name)
            case "path"     : return tr3.addChild(par, .path)
            case "comment"  : tr3.comments.addComment(tr3, par, prior)
            default         : break
        }

        let parentTr3 = pattern == "many" ? tr3.makeMany() : tr3
        var nextTr3 = parentTr3

        for nextPar in par.nextPars {

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
                   _ par: ParItem,
                   _ level: Int) -> Tr3 {

        for nextPar in par.nextPars {
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
                       _ par: ParItem,
                       _ level: Int) -> Tr3 {

        // log(tr3, par, level)  // log progress through parse, here

        if  let pattern = par.node?.pattern,
            let tr3Parse = tr3Keywords[pattern] {

            return tr3Parse(tr3, prior, par, level+1)
        }
        // `^( < | <= | > | >= | == | *[ ] | \[ ] | +[ ] | -[ ] | \% | ,)`
        else if let value = par.value,
                let tr3Parse = tr3Keywords[value] {
            
            return tr3Parse(tr3, prior, par, level+1)
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
    
        if let par = rootParNode.findMatch(parStr, 0).parLast {

            if printGraph {
                rootParNode.printGraph(Visitor(0))
            }
            // reduce to keywords in tr3Keywords and print
            let reduce1 = par.reduceStart(tr3Keywords)
            let _ = dipatchParse(root, "", reduce1, 0)
            root.bindRoot()
           
            return true
        }
        return false
    }
}
