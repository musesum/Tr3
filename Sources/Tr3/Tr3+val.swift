
import Foundation

extension Tr3 {

    public func StringVal()->String? {
        if let v = val as? Tr3ValQuote {
            return v.quote
        }
        return nil
    }

    public func CGRectVal() -> CGRect? {
        if let v = val as? Tr3ValTuple, v.size >= 4 {
            let x = CGFloat(v.nums[0].num)
            let y = CGFloat(v.nums[1].num)
            let w = CGFloat(v.nums[2].num)
            let h = CGFloat(v.nums[3].num)
            let rect = CGRect(x:x, y:y, width:w, height:h)
            return rect
        }
        return nil
    }

    public func CGFloatVal() -> CGFloat? {
        if let v = val as? Tr3ValScalar {
            return CGFloat(v.num)
        }
        return nil
    }

    public func FloatVal() -> Float? {
        if let v = val as? Tr3ValScalar {
            return v.num
        }
        return nil
    }
}
