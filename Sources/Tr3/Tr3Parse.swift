//
//  Tr3Parse.swift
//  
//
//  Created by warren on 3/10/19.
//

import Foundation
import Par

class Resource {
    static var resourcePath = "../Resources"

    let name: String
    let type: String

    init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    var path: String {
        let bundle = Bundle(for: Swift.type(of: self))
        guard let path: String = bundle.path(forResource: name, ofType: type) else {
            let filename: String = type.isEmpty ? name : "\(name).\(type)"
            return "\(Resource.resourcePath)/\(filename)"
        }
        return path
    }
}

public class Tr3Parse {

    public static let shared = Tr3Parse()

    public var rootParNode: ParNode!
    var tr3Par = [String:Tr3PriorParAny]()

    public init() {
        rootParNode = Par.shared.parse(script:Tr3Par)
        rootParNode.reps.repMax = Int.max
        makeParTr3()
    }

    public func parseFile(_ name:String,_ ext: String) -> ParNode {
        return ParNode("")
    }


    public func read(_ filename: String, _ ext:String) -> String {

        let resource = Resource(name: filename, type: ext)
        do {
            let resourcePath = resource.path
            return try String(contentsOfFile: resourcePath) }
        catch {
            print("*** ParStr::\(#function) error:\(error) loading contents of:\(resource.path)")
        }
        return ""
    }

    public func parseTr3(_ tr3:Tr3, _ filename:String) {
        let script = read(filename,"tr3")
        print(filename, terminator:" ")
        let success = parseScript(tr3, script, whitespace: "\n\t ")
        if success  { print("✓") }
        else        { print("🚫 parse failed") }
    }

    /// create a dictionary of parsing closures as a global dispatch
    ///
    /// - parameter tr3: current Tr3
    /// - parameter prior: prior keyword
    /// - parameter parAny: node in parse graph
    /// - parameter level: Level depth
    /// - returns: Tr3 depth first result
    ///
    func makeParTr3() {

        func dispatchFunc(_ fn: @escaping Tr3PriorParAny, from keywords: [String]) {
            for keyword in keywords { tr3Par[keyword] = fn }
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
    func parsePath(_ tr3: Tr3,_ prior: String, parAny: ParAny,_ level: Int) -> Tr3 {

        let pattern = parAny.node?.pattern
        //Tr3Log.log("parsePath", prior, pattern ?? "")

        switch prior {

        case "edges", "ternIf", "ternThen", "ternElse", "ternRadio", "ternCompare":

            tr3.edgeDefs.lastEdgeDef().addPath(parAny)

        case "tuple": // prevent names for tuple from generating an addChild

            break
            
        case "proto":

            let _ = tr3.addChild(parAny, .proto)

        default:

            switch pattern {
            case "name" : return tr3.addChild(parAny, .name)
            case "path" : return tr3.addChild(parAny, .path)
            default     : break
            }
        }
        return tr3
    }
    /// decorate current value with attributes
    func parseDeepVal(_ val:Tr3Val?,_ parAny: ParAny)  {

        let pattern = parAny.node?.pattern ?? ""

        switch val {

        case let val as Tr3ValScalar:

            switch pattern {
            case "thru" : val.addFlag(.thru)
            case "upto" : val.addFlag(.upto)
            case "modu" : val.addFlag(.modu)
            case "incr" : val.addFlag(.incr)
            case "decr" : val.addFlag(.decr)
            case "min"  : val.addMin(parAny.getFirstFloat())
            case "max"  : val.addMax(parAny.getFirstFloat())
            case "dflt" : val.addDflt(parAny.getFirstFloat())
            default     : break
            }
        case let val as Tr3ValTuple:

            switch pattern {
            case "names"    : val.addNames(parAny.harvestValues(["name"]))
            case "nums"     : val.addNums(parAny.harvestValues(["num"]))
            case "nameNums" : val.addNameNums(parAny.harvestValues(["name","num"]))
            case "scalar"   : val.dflt = Tr3ValScalar()
            default: if val.dflt != nil { parseDeepVal(val.dflt, parAny) }// decorate default scalar
            }
        case let val as Tr3ValTern:

            switch pattern {
            case "scalar" : val.deepAddVal(Tr3ValScalar())
            case "data"   : val.deepAddVal(Tr3ValData())
            case "tuple"  : val.deepAddVal(Tr3ValTuple())
            default       : parseDeepVal(val.getVal(), parAny) // decorate deepest non tern value
            }
        default: break
        }
    }

    /// Tr3Parse will always parse a Tr3.val before starting to parse a series Tr3.edgeDef.val
    /// so check the last edgeDef, if empty edgeDefs, then check Tr3.val
    func parseValue(_ tr3: Tr3,_ prior: String, parAny: ParAny,_ level: Int) -> Tr3 {

        let pattern = parAny.node?.pattern ?? ""

        // 9 in `a:8 <- (b ? 9)`
        if let edgeDef = tr3.edgeDefs.edgeDefs.last {

            if let defVal = edgeDef.defVal { //Tr3Log.log("parseVal.A.defVal", prior, pattern)

                parseDeepVal(defVal,parAny)
            }
            else { //Tr3Log.log("parseVal.B.defVal", prior, pattern)

                switch pattern {
                case "embed"  : edgeDef.defVal = Tr3ValEmbed(with:parAny.getFirstValue())
                case "quote"  : edgeDef.defVal = Tr3ValQuote(with:parAny.getFirstValue())
                case "scalar" : edgeDef.defVal = Tr3ValScalar()
                case "data"   : edgeDef.defVal = Tr3ValData()
                case "tuple"  : edgeDef.defVal = Tr3ValTuple()
                case "ternIf" : edgeDef.defVal = Tr3ValTern(tr3,level)
                default: break
                }
            }
        }
            // nil in `a:_`
        else if tr3.val == nil { //Tr3Log.log("parseVal.C.defVal", prior, pattern)

            switch pattern {
            case "embed"  : tr3.val = Tr3ValEmbed(with:parAny.getFirstValue())
            case "quote"  : tr3.val = Tr3ValQuote(with:parAny.getFirstValue())
            case "scalar" : tr3.val = Tr3ValScalar()
            case "data"   : tr3.val = Tr3ValData()
            case "tuple" : tr3.val = Tr3ValTuple()
            default       : break
            }
        }
            // x y in `a:(x y)`
        else { //Tr3Log.log("parseVal.D.defVal", prior, pattern)

            parseDeepVal(tr3.val, parAny)
            // keep prior while decorating Tr3.val
            return parseNext(tr3, prior, parAny, level+1)
        }
        return parseNext(tr3, pattern, parAny, level+1)
    }

    /// Add edges to Tr3, set state of current TernaryEdge
    func parseEdge(_ tr3: Tr3,_ prior: String, parAny: ParAny,_ level: Int) -> Tr3 {

        let pattern = parAny.node?.pattern
        // Tr3Log.log("parseEdge", prior, pattern ?? "" )

        if let pattern = pattern {

            switch pattern {
            case "edgeOp"      : tr3.edgeDefs.addEdgeDef(parAny.getFirstValue())
            case "edges"       : break
            case "ternIf"      : tr3.addEdgeTernary(Tr3ValTern(tr3,level))
            case "ternThen"    : Tr3ValTern.setTernState(.Then,  level)
            case "ternElse"    : Tr3ValTern.setTernState(.Else,  level)
            case "ternRadio"   : Tr3ValTern.setTernState(.Radio, level)
            case "ternCompare" : Tr3ValTern.setCompare(parAny.getFirstValue())
            default: break
            }
            return parseNext(tr3, pattern, parAny, level+1)
        }
        return tr3
    }

    /// Parse ParAny into a tree.
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
    /// for calling a ParAny.next.children's nodes
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
    func parseChild(_ tr3: Tr3,_ prior: String, parAny: ParAny,_ level: Int) -> Tr3 {

        let pattern = parAny.node?.pattern ?? ""//Tr3Log.log("parseChild", prior, pattern ?? "")

        switch pattern {
        case "name": return tr3.addChild(parAny,.name)
        case "path": return tr3.addChild(parAny,.path)
        default    : break
        }

        let parentTr3 = pattern == "many" ? tr3.makeMany() : tr3
        var nextTr3 = parentTr3

        for nexti in parAny.next {

            switch  nexti.node?.pattern  {

            case "child","many": // push child of most recent name'd sibling to the next level

                let _ = self.parse(nextTr3, pattern, nexti, level+1)

            case "name","path": // add new named sibling to parent

                nextTr3 = self.parse(parentTr3, pattern, nexti, level+1)

            default: // decorate current sibling with new values

                nextTr3 = self.parse(nextTr3, pattern, nexti, level+1)
            }
        }
        return nextTr3
    }
    /// decorate current tr3 with additional attributes
    func parseNext(_ tr3: Tr3,_ prior: String,_ parAny: ParAny,_ level: Int) -> Tr3 {

        for nexti in parAny.next {
            let _ = self.parse(tr3,prior,nexti,level+1)
        }
        return tr3
    }
    /// Dispatch tr3Parse
    ///
    /// find corresponding tr3Parse dispatch to either
    /// - parsePath
    /// - parseValue
    /// - parseEdge
    func parse(_ tr3: Tr3,_ prior: String,_ parAny: ParAny,_ level: Int) -> Tr3 {

        //log(tr3,parAny,level)

        if  let pattern = parAny.node?.pattern,
            let tr3Parse = tr3Par[pattern] {

            return tr3Parse(tr3, prior, parAny, level+1)
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

        if let parAny = rootParNode.findMatch(parStr, 0) {

            if printGraph {
                rootParNode.printGraph(Visitor(0))
            }

            // reduce to keywords in tr3Par and print
            let reduce1 = parAny.reduce1(keywords:tr3Par)
            // print(reduce1.anyStr())
            // print(parAny.anyStr())

            let _ = parse(root, "", reduce1, 0)
            root.bindRoot()
           
            return true
        }
        return false
    }
}
