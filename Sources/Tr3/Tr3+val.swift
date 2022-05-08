// Tr3+val.swift
//
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore
import Par

extension Tr3 {

    public func StringVal() -> String? {
        if let v = val as? Tr3ValQuote {
            return v.quote
        }
        return nil
    }

    public func BoolVal() -> Bool {
        if let v = val as? Tr3ValScalar {
            return v.num > 0
        }
        return false
    }

    public func FloatVal() -> Float? {
        if let v = val as? Tr3ValScalar {
            return v.num
        }
        else if let exprs = val as? Tr3Exprs {
            if let f = exprs.nameScalar["v"]?.num {
                return f
            } else if let name = exprs.names.last,
               let scalar = exprs.nameScalar[name] {
                return scalar.num
            } else if exprs.scalars.count >= 1 {
                let scalar = exprs.scalars[0]
                return scalar.num
            }
        }
        return nil
    }


    public func IntVal() -> Int? {
        if let num = FloatVal() { return Int(num) }
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

        if let exprs = val as? Tr3Exprs {
            if let x = exprs.nameScalar["x"]?.num,
               let y = exprs.nameScalar["y"]?.num {

                return CGPoint(x: CGFloat(x), y: CGFloat(y))
            }
            else if exprs.scalars.count >= 2 {
                let x = exprs.scalars[0].num
                let y = exprs.scalars[1].num

                return CGPoint(x: CGFloat(x), y: CGFloat(y))
            }
        }
        return nil
    }
    
    public func CGSizeVal() -> CGSize? {
        if let v = val as? Tr3Exprs {
            if let w = v.nameScalar["w"]?.num,
               let h = v.nameScalar["h"]?.num {

                return CGSize(width: CGFloat(w), height: CGFloat(h))
            }
            else if v.scalars.count >= 2 {
                let w = v.scalars[0].num
                let h = v.scalars[1].num

                return CGSize(width: CGFloat(w), height: CGFloat(h))
            }
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

    public func NamesVal() -> [String]? {
        if let v = val as? Tr3Exprs,
           v.nameScalar.count > 0 {
            return Array<String>(v.nameScalar.keys)
        }
        return nil
    }
    
}
