//  Created by warren on 8/21/22.
//

import Foundation
extension Tr3Exprs {

    func getCGPoint() -> CGPoint? {
        if nameAny.count == 2,
           let x = nameAny["x"] as? Tr3ValScalar,
           let y = nameAny["y"] as? Tr3ValScalar {
            let xNum = Double(x.num)
            let yNum = Double(y.num)
            return CGPoint(x: xNum, y: yNum)
        }
        return nil
    }
    func getCGRect() -> CGRect? {
        if nameAny.count == 4,
           let x = nameAny["x"] as? Tr3ValScalar,
           let y = nameAny["y"] as? Tr3ValScalar {
            let xNum = Double(x.num)
            let yNum = Double(y.num)

            if let w = nameAny["w"] as? Tr3ValScalar,
               let h = nameAny["h"] as? Tr3ValScalar {
                let wNum = Double(w.num)
                let hNum = Double(h.num)
                return CGRect(x: xNum, y: yNum, width: wNum, height: hNum)
            }
            else  if let w = nameAny["width"] as? Tr3ValScalar,
                     let h = nameAny["height"] as? Tr3ValScalar {
                let wNum = Double(w.num)
                let hNum = Double(h.num)
                return CGRect(x: xNum, y: yNum, width: wNum, height: hNum)
            }
        }
        return nil
    }
    func getFloats() -> [Float]? {
        var floats = [Float]()
        for value in nameAny.values {
            switch value {
                case let v as Tr3ValScalar: floats.append(Float(v.num))
                case let v as CGFloat: floats.append(Float(v))
                case let v as Float: floats.append(v)
                default: return nil
            }
        }
        return floats.isEmpty ? nil : floats
    }
}
