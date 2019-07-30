
import QuartzCore
import Par

extension Tr3 {

    public func StringVal()->String? {
        if let v = val as? Tr3ValQuote {
            return v.quote
        }
        return nil
    }

    public func CGRectVal() -> CGRect? {
        if let v = val as? Tr3ValTuple, v.nums.count >= 4 {
            let x = CGFloat(v.nums[0].num)
            let y = CGFloat(v.nums[1].num)
            let w = CGFloat(v.nums[2].num)
            let h = CGFloat(v.nums[3].num)
            let rect = CGRect(x:x, y:y, width:w, height:h)
            return rect
        }
        return nil
    }

    public func FloatVal() -> Float? {
        if let v = val as? Tr3ValScalar {
            return v.num
        }
        else if let v = val as? Tr3ValTuple {
            if v.nums.count >= 1 {
                return v.nums[0].num
            }
        }
        return nil
    }
    public func IntVal() -> Int? {
        if let v = val as? Tr3ValScalar {
            return Int(v.num)
        }
        else if let v = val as? Tr3ValTuple {
            if v.nums.count >= 1 {
                return Int(v.nums[0].num)
            }
        }
        return nil
    }

    public func CGFloatVal() -> CGFloat? {
        if let f = FloatVal() { return CGFloat(f) }
        return nil
    }
    
    public func DoubleVal() -> Double? {
        if let f = FloatVal() { return Double(f) }
        return nil
    }

    public func CGPointVal() -> CGPoint? {

        if let v = val as? Tr3ValTuple, v.nums.count >= 2 {
            let x = CGFloat(v.nums[0].num)
            let y = CGFloat(v.nums[1].num)

            let p = CGPoint(x:x, y:y)
            return p
        }
        return nil
    }
    
    public func CGPointValDefault() -> CGPoint? {

        if let v = val as? Tr3ValTuple,
            let d = v.dflt as? Tr3ValTuple,
            d.nums.count >= 2 {

            let x = CGFloat(d.nums[0].num)
            let y = CGFloat(d.nums[1].num)

            let p = CGPoint(x:x, y:y)
            return p
        }
        return nil
    }
    
    public func CGSizeVal() -> CGSize? {
        if let v = val as? Tr3ValTuple, v.nums.count >= 2 {
            let w = CGFloat(v.nums[0].num)
            let h = CGFloat(v.nums[1].num)

            let s = CGSize(width:w, height:h)
            return s
        }
        return nil
    }
    public func BoolVal() -> Bool {
        if let v = val as? Tr3ValScalar {
            return v.num > 0
        }
        return false
    }

    
}
