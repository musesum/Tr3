//
//  Tr3.swift
//  Par
//
//  Created by warren on 11/14/17.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

// this it language definition for the Tr3 Script,
// which is read by the Par package to produce a parse Graph
// A prettier version of this string is in Tr3.par.v2.h

public let Tr3Par =
#"""
tr3 ~ left right* {

    left ~ (path | name | quote) 

    right ~ (tr3Val | child | many | copier | array | edges | embed | comment)+

    tr3Val ~ value
    child ~ "{" comment* tr3+ "}"
    many ~ "." "{" tr3+ "}"
    copier ~ "©" (path | name)
    array ~ "[" thru "]"

    value ~ scalar | tuple | quote
    value1 ~ scalar1 | tuple | quote
    scalar ~ "(" scalar1 ")"
    scalar1 ~ thru | modu | incr | decr | data | dflt {
        thru ~ min ".." max eqDflt?
        modu ~ "%" max eqDflt?
        incr ~ "++"
        decr ~ "--"
        data ~ "*"
        min ~ num
        max ~ num
        dflt ~ num
        eqDflt ~ "=" dflt
    }
    tuple ~ "(" tupVal ")" {
        names ~ name (","? name)+
        scalars ~ scalar1 (","? scalar1)+
        nameScalars ~ name scalar1 (","? name scalar1)*
        tupVal ~ nameScalars | names | scalars
    }
    edges ~ edgeOp (edgePar | edgeItem) comment* {

        edgeOp ~ '^([<][<⋯!©ⓝⓒ\=\╌>]+|[⋯!©ⓝⓒ\=\╌>]+[>])'
        edgePar ~ "(" edgeItem+ ")" edges?
        edgeItem ~ (edgeVal | ternary) comment*

        edgeVal ~ (path | name) (edges+ | value)?

        ternary ~ 	"(" tern ")" | tern {
            tern ~ ternIf ternThen ternElse? ternRadio?
            ternIf ~ (path | name) ternCompare?
            ternThen ~ "?" (ternary | path | name | value1)
            ternElse ~ ":" (ternary | path | name | value1)
            ternCompare ~ compare (path | name | value1)
            ternRadio ~ "|" ternary
        }
    }
    path ~ '^((([A-Za-z_][A-Za-z0-9_]*)*([.˚*])+([A-Za-z_][A-Za-z0-9_.˚*]*)*)+)'
    name ~ '^([A-Za-z_][A-Za-z0-9_]*)'
    quote ~ '^\"([^\"]*)\"'
    num ~ '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+)([e][+-][0-9]+)?)'
    comment ~ '^[,]|^([/][/][ ]*(.*?)[\r\n]+|^[ \r\n\t]+)'
    compare ~ '^[<>!=][=]?'
    embed ~ '^[{][{](?s)(.*?)[}][}]'
}
"""#
