tr3 ~ name (_edges | _values | _branches | comment)* {

    _edges ~ edgeOp (_edgePar | edge) comment* {
        edgeOp ~ '^([<][<⋯!@&\=\╌>]+|[⋯!@&\=\╌>]+[>])'
        _edgePar ~ "(" edge+ ")"
        edge ~ (path | name)? (exprs | quote | ternary) comment*
    }
    _values ~ _exprs | quote | ternary | embed {

        _exprs ~ "(" expr+ ")"
        expr ~ exprOp? (names | scalar | ternary) comma? {
            exprOp ~ '^(<=|>=|==|<|>|\*[ ]|\/[ ]|\+[ ]|\-[ ]|in)'
        }
        scalar ~ (thru | modu | data | num) comma? {
            thru ~ num ".." num ("=" dflt)?
            modu ~ "%" num ("=" num)?
            index ~ "[" (name | num) "]"
            data ~ "*"
            num ~ '^([+-]*([0-9]+[.][0-9]+|[.][0-9]+|[0-9]+[.](?![.])|[0-9]+)([e][+-][0-9]+)?)'
        }
        ternary ~ ternIf ternThen ternElse? ternRadio? {
            ternIf ~ expr
            ternThen ~ "?" expr
            ternElse ~ ":" expr
            ternRadio ~ "|" ternary
        }
        embed ~ '^[{][{](?s)(.*?)[}][}]'
        comma ~ '^([,])'
    }
    _branches ~ child | many | array | copyat {
        child ~ "{" comment* tr3+ "}"
        many ~ "." "{" tr3+ "}"
        array ~ "[" thru "]"
        copyat ~ "@" (path | name)
    }
    path ~ '^(([A-Za-z_][A-Za-z0-9_]*)?[.º˚*]+[A-Za-z0-9_.º˚*]*)'
    name ~ '^([A-Za-z_][A-Za-z0-9_]*)'
    quote ~ '^\"([^\"]*)\"'
    comment ~ '^([,]+|^[/]{2,}[ ]*(.*?)[\n\r\t]+|\/[*]+.*?\*\/)'
}

class Tr3 {
    public var nodes = Nodes()
    public var edges = Edges()
    public var value = Value()
    public var branches = Branches()
    public var comments = Comments()
}
class Nodes {
}
class Edges {
}
class Value {
}
class Branches {
}
class Values {
}
class Comments: String {
}

