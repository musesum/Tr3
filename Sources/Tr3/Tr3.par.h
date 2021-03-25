tr3 ~ left right* {

    left ~ (path | name | quote)

    right ~ (value | child | many | copyat | array | edges | embed | comment)+

    child ~ "{" comment* tr3+ "}"
    many ~ "." "{" tr3+ "}"
    array ~ "[" thru "]"
    copyat ~ "@" (path | name)

    value ~ scalar | tuple | quote
    value1 ~ scalar1 | tuple | quote

    scalar ~ "(" scalar1 ")"
    scalar1 ~ (thru | modu | data | num) comma? {
        thru ~ num ".." num ("=" num)?
        modu ~ "%" num ("=" num)?
        index ~ "[" (name | num) "]"
        data ~ "*"
        comma ~ '^([,])'
    }
    tuple ~ "(" tupExpr{2,} ")" {
        tupExpr ~ (tupOper | name | scalar1) comma?
        tupOper ~ tupOp (name | scalar1)
        tupOp ~ '^(<|<=|>|>=|==|\*|\\|\+=|\-=|\%|in)'
    }
    edges ~ edgeOp (edgePar | edgeItem) comment* {

        edgeOp ~ '^([<][<⋯!@&\=\╌>]+|[⋯!@&\=\╌>]+[>])'
        edgePar ~ "(" edgeItem + ")" edges?
        edgeItem ~ (edgeVal | ternary) comment* {
            edgeVal ~ (path | name) (edges+ | value)?
        }
        ternary ~ "(" tern ")" | tern {
            tern ~ ternIf ternThen ternElse? ternRadio?
            ternIf ~ (path | name) ternCompare?
            ternThen ~ "?" (ternary | path | name | value1)
            ternElse ~ ":" (ternary | path | name | value1)
            ternCompare ~ compare (path | name | value1)
            ternRadio ~ "|" ternary
        }
    }
    path ~ '^(([A-Za-z_][A-Za-z0-9_]*)?[.º˚*]+[A-Za-z0-9_.º˚*]*)'
    name ~ '^([A-Za-z_][A-Za-z0-9_]*)'
    quote ~ '^\"([^\"]*)\"'
    num ~ '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+)([e][+-][0-9]+)?)'
    comment ~ '^([,]+|^[/]{2,}[ ]*(.*?)[\n\r\t]+|\/[*]+.*?\*\/)'
    compare ~ '^[<>!=][=]?'
    embed ~ '^[{][{](?s)(.*?)[}][}]'
}
