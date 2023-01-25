//  Created by warren on 1/24/23.


import Foundation

extension Tr3 { // + animation

    func setAnimation(_ fromTr3: Tr3) {
        if let val {
            switch val {
                case let v as Tr3ValScalar: v.setAnimation(fromTr3)
                case let v as Tr3Exprs:     v.setAnimation(fromTr3)
                default: break
            }
        }
    }
}
extension Tr3ValScalar {

    func setAnimation(_ fromTr3: Tr3) {

        switch fromTr3.val {

            case let from as Tr3ValScalar:

                setAnim(from.now)

            case let from as Tr3Exprs:

                for fromAny in from.nameAny.values {

                    if let fromScalar = fromAny as? Tr3ValScalar {

                        setAnim(fromScalar.now)
                        return // use only the first scalar it sees
                    }
                }

            default: break
        }
    }
}

extension Tr3Exprs {

    func setAnimation(_ fromTr3: Tr3) {

        switch fromTr3.val {

            case let fromScalar as Tr3ValScalar:

                for (destName,any) in nameAny {

                    if let destScalar = any as? Tr3ValScalar {

                        destScalar.setAnim(fromScalar.now)
                    }
                }
            case let fromExprs as Tr3Exprs:

                for (fromName,fromAny) in fromExprs.nameAny {

                    if let destScalar = nameAny[fromName] as? Tr3ValScalar,
                       let fromScalar = fromAny as? Tr3ValScalar {

                        destScalar.setAnim(fromScalar.now)
                    }
                }
            default: break
        }
    }
}
