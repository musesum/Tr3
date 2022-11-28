//  Created by warren on 8/21/22.
//

import Foundation
extension Tr3Exprs {

    func getCGPoint() -> CGPoint? {
        if nameAny.count == 2,
           let x = nameAny["x"] as? Tr3ValScalar,
           let y = nameAny["y"] as? Tr3ValScalar {
            let xNum = Double(x.now)
            let yNum = Double(y.now)
            return CGPoint(x: xNum, y: yNum)
        }
        return nil
    }
    func getCGRect() -> CGRect? {
        if nameAny.count == 4,
           let x = nameAny["x"] as? Tr3ValScalar,
           let y = nameAny["y"] as? Tr3ValScalar {
            let xNum = Double(x.now)
            let yNum = Double(y.now)

            if let w = nameAny["w"] as? Tr3ValScalar,
               let h = nameAny["h"] as? Tr3ValScalar {
                let wNum = Double(w.now)
                let hNum = Double(h.now)
                return CGRect(x: xNum, y: yNum, width: wNum, height: hNum)
            }
            else  if let w = nameAny["width"] as? Tr3ValScalar,
                     let h = nameAny["height"] as? Tr3ValScalar {
                let wNum = Double(w.now)
                let hNum = Double(h.now)
                return CGRect(x: xNum, y: yNum, width: wNum, height: hNum)
            }
        }
        return nil
    }
    func getNums() -> [Double]? {
        var nums = [Double]()
        for value in nameAny.values {
            switch value {
                case let v as Tr3ValScalar  : nums.append(Double(v.now))
                case let v as CGFloat       : nums.append(Double(v))
                case let v as Float         : nums.append(Double(v))
                case let v as Double        : nums.append(v)
                default: return nil
            }
        }
        return nums.isEmpty ? nil : nums
    }
}
