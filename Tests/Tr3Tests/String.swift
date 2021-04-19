//
//  File.swift
//  
//
//  Created by warren on 3/25/21.
//

/// see https://stackoverflow.com/a/50202999/419740
extension String {
    func titleCase() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
