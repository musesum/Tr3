//
//  Tr3Parse.swift
//  
//
//  Created by warren on 3/10/19.
//

import Foundation
import Par

public class Tr3Parse {

    public static let shared = Tr3Parse()

    public var rootParNode: ParNode!
    var tr3Keywords = [String:Tr3PriorParItem]()

    public init() {
        rootParNode = Par.shared.parse(script:Tr3Par)
        rootParNode.reps.repMax = Int.max
        makeParTr3()
    }

    /// create a dictionary of parsing closures as a global dispatch
    ///
    /// - parameter tr3: current Tr3
    /// - parameter prior: prior keyword
    /// - parameter parItem: node in parse graph
    /// - parameter level: Level depth
    /// - returns: Tr3 depth first result
    ///
    func makeParTr3() {

        func dispatchFunc(_ fn: @escaping Tr3PriorParItem, from keywords: [String]) {
            for keyword in keywords { tr3Keywords[keyword] = fn }
        }
        dispatchFunc(parsePath,  from: ["name","path"])
        dispatchFunc(parseChild, from: ["child","many","proto"])
        dispatchFunc(parseValue, from: ["scalar","data","tuple","nameNums","names","nums","thru","upto","modu","incr","decr","min","max","dflt","quote","embed"])
        dispatchFunc(parseEdge,  from: ["edges","edgeOp","ternIf","ternThen","ternElse","ternRadio","ternCompare"])

        //tr3Par["comment"] = {t,_,_,_ in return t }
    }

    /// Translate names and paths to Tr3, Tr3Edges, but not Tuples
    ///
    ///     // a,b,c,d,e,f.g but not x y in
    ///     a { b <- (c ? d : e) } f.g:(x y)
    ///
    func parsePath(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern
        //Tr3Log.log("parsePath", prior, pattern ?? "")

        switch prior {

        case "edges", "ternIf", "ternThen", "ternElse", "ternRadio", "ternCompare":

            tr3.edgeDefs.lastEdgeDef().addPath(parItem)

        case "tuple": // prevent names for tuple from generating an addChild

            break
            
        case "proto":

            let _ = tr3.addChild(parItem, .proto)

        default:

            switch pattern {
            case "name" : return tr3.addChild(parItem, .name)
            case "path" : return tr3.addChild(parItem, .path)
            default     : break
            }
        }
        return tr3
    }
    /// decorate current value with attributes
    func parseDeepVal(_ val:Tr3Val?,_ parItem: ParItem)  {

        let pattern = parItem.node?.pattern ?? ""

        switch val {

        case let val as Tr3ValScalar:

            switch pattern {
            case "thru" : val.addFlag(.thru)
            case "upto" : val.addFlag(.upto)
            case "modu" : val.addFlag(.modu)
            case "incr" : val.addFlag(.incr)
            case "decr" : val.addFlag(.decr)
            case "min"  : val.addMin(parItem.getFirstFloat())
            case "max"  : val.addMax(parItem.getFirstFloat())
            case "dflt" : val.addDflt(parItem.getFirstFloat())
            default     : break
            }
        case let val as Tr3ValTuple:

            switch pattern {
            case "names"    : val.addNames(parItem.harvestValues(["name"]))
            case "nums"     : val.addNums(parItem.harvestValues(["num"]))
            case "nameNums" : val.addNameNums(parItem.harvestValues(["name","num"]))
            case "scalar"   : val.dflt = Tr3ValScalar()
            default         : if val.dflt != nil { parseDeepVal(val.dflt, parItem) }// decorate default scalar
            }
        case let val as Tr3ValTern:

            switch pattern {
            case "scalar" : val.deepAddVal(Tr3ValScalar())
            case "data"   : val.deepAddVal(Tr3ValData())
            case "tuple"  : val.deepAddVal(Tr3ValTuple())
            default       : parseDeepVal(val.getVal(), parItem) // decorate deepest non tern value
            }
        default: break
        }
    }

    /// Tr3Parse will always parse a Tr3.val before starting to parse a series Tr3.edgeDef.val
    /// so check the last edgeDef, if empty edgeDefs, then check Tr3.val
    func parseValue(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        // 9 in `a:8 <- (b ? 9)`
        if let edgeDef = tr3.edgeDefs.edgeDefs.last {

            if let lastPath = edgeDef.pathVals.pathList.last {

                if let lastVal = edgeDef.pathVals.pathDict[lastPath], lastVal != nil { //Tr3Log.log("parseVal.A.defVal", prior, pattern)

                    parseDeepVal(lastVal,parItem)
                }
                else  { //Tr3Log.log("parseVal.B.defVal", prior, pattern)

                    func addVal(_ v:Tr3Val) { edgeDef.pathVals.add(lastPath,v) }

                    switch pattern {
                    case "embed"  : addVal(Tr3ValEmbed(with:parItem.getFirstValue()))
                    case "quote"  : addVal(Tr3ValQuote(with:parItem.getFirstValue()))
                    case "scalar" : addVal(Tr3ValScalar())
                    case "data"   : addVal(Tr3ValData())
                    case "tuple"  : addVal(Tr3ValTuple())
                    case "ternIf" : addVal(Tr3ValTern(tr3,level))
                    default       : break
                    }
                }
            }
            else if let ternVal = edgeDef.ternVal {
                 parseDeepVal(ternVal,parItem)
            }
        }
            // nil in `a:_`
        else if tr3.val == nil { //Tr3Log.log("parseVal.C.defVal", prior, pattern)

            switch pattern {
            case "embed"  : tr3.val = Tr3ValEmbed(with:parItem.getFirstValue())
            case "quote"  : tr3.val = Tr3ValQuote(with:parItem.getFirstValue())
            case "scalar" : tr3.val = Tr3ValScalar()
            case "data"   : tr3.val = Tr3ValData()
            case "tuple"  : tr3.val = Tr3ValTuple()
            default       : break
            }
        }
            // x y in `a:(x y)`
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
        // Tr3Log.log("parseEdge", prior, pattern ?? "" )

        if let pattern = pattern {

            switch pattern {
            case "edgeOp"      : tr3.edgeDefs.addEdgeDef(parItem.getFirstValue())
            case "edges"       : break
            case "ternIf"      : tr3.edgeDefs.addEdgeTernary(Tr3ValTern(tr3,level))
            case "ternThen"    : Tr3ValTern.setTernState(.Then,  level)
            case "ternElse"    : Tr3ValTern.setTernState(.Else,  level)
            case "ternRadio"   : Tr3ValTern.setTernState(.Radio, level)
            case "ternCompare" : Tr3ValTern.setCompare(parItem.getFirstValue())
            default: break
            }
            return parseNext(tr3, pattern, parItem, level+1)
        }
        return tr3
    }

    /// Parse ParItem into a tree.
    ///
    /// Here are examples of how a parse generates a NodeAny
    ///
    ///     a { b c } ⟹
    ///     child:(name:a, child:(name:b, name:c))
    ///
    ///     a { b { c } } ⟹
    ///     child:(name:a, child:(name:b, child:name:c))
    ///
    ///     a { b { c } d { e } } ⟹
    ///     child:(name:a, child:(name:b, child:name:c, name:d, child:name:e))
    ///
    /// below shows a parse for a "many",
    /// where indentation on the left side represents level of recursion,
    /// for calling a ParItem.next.children's nodes
    ///
    ///     a {b c}:{d e} ⟹
    ///     child:(name:a, child:(name:b, name:c), many:(name:d, name:e))
    ///
    ///       (√,child)         [name, child, many]
    ///          (√,name)       [a]
    ///          (a,child)      [name, name]
    ///             (a,name)    [b]
    ///             (a,name)    [c]
    ///          (a,many)       [name, name]
    ///             (_:_,name)  [d]
    ///             (_:_,name)  [e]
    ///
    ///     √ { a { b { d e } c { d e } } }
    ///
    func parseChild(_ tr3: Tr3,_ prior: String, parItem: ParItem,_ level: Int) -> Tr3 {

        let pattern = parItem.node?.pattern ?? ""

        switch pattern {
        case "name" : return tr3.addChild(parItem,.name)
        case "path" : return tr3.addChild(parItem,.path)
        default     : break
        }

        let parentTr3 = pattern == "many" ? tr3.makeMany() : tr3
        var nextTr3 = parentTr3

        for nextPar in parItem.nextPars {

            switch  nextPar.node?.pattern  {

            case "child","many": // push child of most recent name'd sibling to the next level

                let _ = self.parse(nextTr3, pattern, nextPar, level+1)

            case "name","path": // add new named sibling to parent

                nextTr3 = self.parse(parentTr3, pattern, nextPar, level+1)

            default: // decorate current sibling with new values

                nextTr3 = self.parse(nextTr3, pattern, nextPar, level+1)
            }
        }
        return nextTr3
    }
    /// decorate current tr3 with additional attributes
    func parseNext(_ tr3: Tr3,_ prior: String,_ parItem: ParItem,_ level: Int) -> Tr3 {

        for nextPar in parItem.nextPars {
            let _ = self.parse(tr3, prior, nextPar, level+1)
        }
        return tr3
    }
    /// Dispatch tr3Parse
    ///
    /// find corresponding tr3Parse dispatch to either
    /// - parsePath
    /// - parseValue
    /// - parseEdge
    func parse(_ tr3: Tr3,_ prior: String,_ parItem: ParItem,_ level: Int) -> Tr3 {

        //log(tr3,parItem,level)

        if  let pattern = parItem.node?.pattern,
            let tr3Parse = tr3Keywords[pattern] {

            return tr3Parse(tr3, prior, parItem, level+1)
        }
        return tr3
    }
    /// From root, parse script, deliminted by whitespace
    ///
    /// - parameter root: starting node from which to attach subtree
    /// - parameter script: text of script to convert into subtree
    /// - parameter whitespace: default is single line, may add \n for multiline script
    public func parseScript(_ root     : Tr3,
                            _ script   : String,
                            whitespace : String = "\t ",
                            printGraph : Bool = false) -> Bool {

        let parStr = ParStr(script)
        parStr.whitespace = whitespace

        if let parItem = rootParNode.findMatch(parStr, 0).parLast {

            if printGraph {
                rootParNode.printGraph(Visitor(0))
            }

            // reduce to keywords in tr3Keywords and print
            let reduce1 = parItem.reduce1(keywords:tr3Keywords)
            // print(reduce1.anyStr())
            // print(parItem.anyStr())

            let _ = parse(root, "", reduce1, 0)
            root.bindRoot()
           
            return true
        }
        return false
    }
}
