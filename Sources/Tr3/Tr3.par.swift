//
//  Tr3.swift
//  Par
//
//  Created by warren on 11/14/17.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

// this it language definition for the Tr3 Script,
// which is read by the Par package to produce a parse Graph
// A prettier version of this string is in Tr3.par.h
public let Tr3Par =
#"""
tr3 : left right* {

    left : comment* (path | name | quote)

    right : (tr3Val | child | many | proto | array | edges | embed | comment)+

    child  :     "{" tr3+ "}"
    many   : ":" "{" tr3+ "}"
    proto  : ":" (path | name)
    tr3Val : ":" value

    value  : (scalar | tuple | quote)

    scalar : ("(" scalar1 ")" | scalar1)
    scalar1 : (thru | upto | modu | incr | decr | data | dflt) {

        thru : min "..." max ("=" dflt)?
        upto : min "..<" max ("=" dflt)?
        modu : "%" max ("=" dflt)?
        incr : "++"
        decr : "--"
        data : "*"
        min  : num
        max  : num
        dflt : num
    }
    tuple : "(" (nameNums | names | nums) ")" tupVal? {
        names    : name{2,}
        nums     : num{2,}
        nameNums : (name ":" num){1,}
        tupVal   : ":" (scalar1 | tuple)
    }
    edges : edgeOp (edgePar | edgeItem) comment* {

        edgeOp   : '^([<][-=?!\╌>]+|[-=?!\˚]+[>])'
        edgePar  : "(" edgeItem+ ")" edges?
        edgeItem : (edgeVal | ternary) comment*
        
        edgeVal  :  (path | name) (edges+ | ":" value)?

        ternary  : ("(" tern ")" | tern) {

            tern        : ternIf ternThen ternElse? ternRadio?
            ternIf      : (path | name) ternCompare?
            ternThen    : "?" (ternary | path | name | value)
            ternElse    : ":" (ternary | path | name | value)
            ternRadio   : "|" ternary
            ternCompare : compare (path | name | value)
        }
    }
    path    : '^((([A-Za-z_][A-Za-z0-9_]*)*([.˚*])+([A-Za-z_][A-Za-z0-9_.˚*]*)*)+)'
    name    : '^([A-Za-z_][A-Za-z0-9_]*)'
    quote   : '^\"([^\"]*)\"'
    num     : '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+)([e][+-][0-9]+)?)'
    array   : '^\:?\[[ ]*([0-9]+)[ ]*\]'
    comment : '^[/][/][ ]*((.*?)[\r\n]+|^[ \r\n\t]+)'
    compare : '^[<>!=][=]?'
    embed   : '^[{][{](?s)(.*?)[}][}]'
}
"""#
