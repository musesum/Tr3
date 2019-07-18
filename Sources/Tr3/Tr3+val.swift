
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

    public func DoubleVal() -> Double? {
        if let v = val as? Tr3ValScalar {
            return Double(v.num)
        }
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
    
    public func setVal(_ p:CGPoint, _ options:Tr3SetOptions, _ visitor:Visitor) {

        if visitor.newVisit(id) {
            if options.contains(.changed),
                let v = val as? Tr3ValTuple,
                v.nums.count >= 2  {
                
                let x = CGFloat(v.nums[0].num)
                let y = CGFloat(v.nums[1].num)
                if p.x == x, p.y == y { return }
            }
            if options.contains(.cache) {
                cacheVal = p
                Tr3Cache.add(self,options,visitor)
                return
            }
            else {
                setVal(p,options)
            }
        }
    }

    
    public func flushCache(_ opt:Tr3SetOptions, _ visitor:Visitor) {

        var optNow = opt
        optNow.remove(.cache)

        if cacheVal != nil {

            setVal(cacheVal,opt)
            cacheVal = nil
        }
    }
}
