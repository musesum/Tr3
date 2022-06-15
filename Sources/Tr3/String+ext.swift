//
//  File.swift
//  
//
//  Created by warren on 3/25/21.
//


extension String {

    /// transform `"CamelBackName"` => `"camel back name"`
    /// - note: https://stackoverflow.com/a/50202999/419740
    func titleCase() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    /// transform `" one  two   three  "` => `"one two three"`
    public func reduceSpaces() -> String {
        var result = ""
        var prevChar = Character("\0")
        for char in self {
            if char == " ", prevChar == " " { continue }
            result.append(char)
            prevChar = char
        }
        if result.last == " " {
            result.removeLast()
        }
        return result
    }
    /// transform `"one\n\n two\n \n three   "` => `"one\n two\n three   "`
    public func reduceLines() -> String {
        var result = ""
        var prevChar = Character("\n")
        for char in self {
            if (prevChar.isNewline || prevChar.isWhitespace) &&
                (char.isNewline || char.isWhitespace) {
                continue
            }
            result.append(char)
            prevChar = char
        }
        return result
    }

}
