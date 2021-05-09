//
//  File.swift
//  
//
//  Created by warren on 11/27/20.
//

import Foundation
import Par

public enum Tr3CommentType { case unknown, child, edges }
public class Tr3Comment {
    let type: Tr3CommentType
    let name: String
    let text: String
    var index: Int

    init(_ type: Tr3CommentType, _ name: String, _ text: String, _ index: Int) {
        self.type  = type
        self.name  = name
        self.text  = text
        self.index = index
    }
}

public class Tr3Comments {

    var comments = [Tr3Comment]()
    var haveType = Set<Tr3CommentType>()

    public func addComment(_ tr3: Tr3, _ parItem: ParItem, _ prior: String) {
        if parItem.node?.pattern == "comment",
           let value = parItem.nextPars.first?.value {

            func insertComment(_ type: Tr3CommentType, _ index: Int ) {
                let tr3Comment = Tr3Comment(type, tr3.name, value, index)
                haveType.insert(type)
                comments.append(tr3Comment)
            }
            switch prior {
                case "child": insertComment(.child, tr3.children.count)
                case "edges": insertComment(.edges, tr3.edgeDefs.edgeDefs.count)
                default:      insertComment(.unknown, 0)
            }
        }
    }

    public func mergeComments(_ tr3: Tr3, _ merge: Tr3) {

        tr3.comments.comments.append(contentsOf: merge.comments.comments) // TODO really  merge both
        tr3.comments.haveType = tr3.comments.haveType.union(merge.comments.haveType)

        var nameIndex = [String: Int]()
        var index = 0
        for child in tr3.children {
            index += 1
            nameIndex[child.name] = index
        }
        for comment in comments {
            if comment.type == .child {
                comment.index = nameIndex[comment.name] ?? 0
            }
        }
    }

    public func have(type: Tr3CommentType) -> Bool {
        return haveType.contains(type)
    }

    public func getComments(_ getType: Tr3CommentType, index: Int) -> String {
        var result = ""
        if have(type: getType) {
            for comment in comments {
                if comment.type == getType,
                   comment.index == index || index == -1 {
                    switch comment.text.prefix(1) {
                        case ",": result += ","
                        default: result += " " + comment.text
                    }
                }
            }
        }
        return result
    }
}
