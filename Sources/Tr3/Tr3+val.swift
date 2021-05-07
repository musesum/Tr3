// Tr3+val.swift
//
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

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
        if let v = val as? Tr3Exprs {
            let ns = v.nameScalar
            if ns.count >= 4,
               let x = ns["x"]?.num,
               let y = ns["y"]?.num,
               let w = ns["w"]?.num,
               let h = ns["h"]?.num {
                    let rect = CGRect(x: CGFloat(x),
                                      y: CGFloat(y),
                                      width: CGFloat(w),
                                      height: CGFloat(h))
                    return rect
               }
        }
        return nil
    }

    public func FloatVal() -> Float? {
        if let v = val as? Tr3ValScalar {
            return v.num
        }
        else if let v = val as? Tr3Exprs {
            if v.scalars.count >= 1 {
                return v.scalars[0].num
            }
        }
        return nil
    }
    public func IntVal() -> Int? {
        if let v = val as? Tr3ValScalar {
            return Int(v.num)
        }
        else if let v = val as? Tr3Exprs {
            if v.scalars.count >= 1 {
                return Int(v.scalars[0].num)
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

        if let v = val as? Tr3Exprs {
            if let x = v.nameScalar["x"]?.num,
               let y = v.nameScalar["y"]?.num {

                return CGPoint(x: CGFloat(x), y: CGFloat(y))
            }
            else if v.scalars.count >= 2 {
                let x = v.scalars[0].num
                let y = v.scalars[1].num

                return CGPoint(x: CGFloat(x), y: CGFloat(y))
            }
        }
        return nil
    }
    
    public func CGPointValDefault() -> CGPoint? {

        if let v = val as? Tr3Exprs,
           v.scalars.count >= 2 {

            let x = CGFloat(v.scalars[0].num)
            let y = CGFloat(v.scalars[1].num)

            let p = CGPoint(x: x, y: y)
            return p
        }
        return nil
    }
    
    public func CGSizeVal() -> CGSize? {
        if let v = val as? Tr3Exprs, v.scalars.count >= 2 {

            let w = CGFloat(v.scalars[0].num)
            let h = CGFloat(v.scalars[1].num)
            let s = CGSize(width: w, height: h)
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

    public func NamesVal() -> [String]? {
        if let v = val as? Tr3Exprs,
           v.nameScalar.count > 0 {
            return Array<String>(v.nameScalar.keys)
        }
        return nil
    }
    
}
