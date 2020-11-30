
/// functional Human body skeleton in defined three lines of code (version 2)

body {left right}.{ shoulder.elbow.wrist.{thumb index middle ring pinky}.{meta prox dist}, hip.knee.ankle.toes}
˚˚ { pos (x 0..1, y 0..1, z 0..1), angle (roll %360, pitch %360, yaw %360), mm (0..3000) }
˚˚pos <> ...pos,  ˚˚angle <> ...angle // connect every node to its parent

// producing the following output

√ {
    body {
        left {
            shoulder {
                elbow {
                    wrist {
                        thumb {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        index {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        middle {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        ring {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        pinky {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                    pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
            hip {
                knee {
                    ankle {
                        toes { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                    pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
        right {
            shoulder {
                elbow {
                    wrist {
                        thumb {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        index {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        middle {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        ring {
                            meta { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        pinky {
                            meta <> ..{ pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            prox <> ..{ pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            dist <> ..{ pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                    pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
            hip {
                knee {
                    ankle {
                        toes { pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                        pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                    pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
                pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
            pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
        pos (x 0..1, y 0..1, z 0..1) <> ...pos, angle (roll %360, pitch %360, yaw %360) <> ...angle, mm (0..3000) }
    ˚˚ }
}
/// todo: here is the current test, replace with above:

body {left right}.{shoulder.elbow.wrist {thumb index middle ring pinky}.{meta prox dist} hip.knee.ankle.toes}
˚˚ <> ..
˚˚ {pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000)})

///  result

√ {
    body<>√ {
        left<>body {
            shoulder<>body.left {
                elbow<>body.left.shoulder {
                    wrist<>left.shoulder.elbow {
                        thumb<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.thumb { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.thumb { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.thumb { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        index<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.index { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.index { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.index { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        middle<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.middle { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.middle { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.middle { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        ring<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.ring { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.ring { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.ring { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        pinky<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.pinky { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.pinky { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.pinky { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                    pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
            hip<>body.left {
                knee<>body.left.hip {
                    ankle<>left.hip.knee {
                        toes<>hip.knee.ankle {
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                    pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
        right<>body {
            shoulder<>body.right {
                elbow<>body.right.shoulder {
                    wrist<>right.shoulder.elbow {
                        thumb<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.thumb { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.thumb { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.thumb { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        index<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.index { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.index { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.index { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        middle<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.middle { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.middle { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.middle { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        ring<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.ring { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.ring { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.ring { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        pinky<>shoulder.elbow.wrist {
                            meta<>elbow.wrist.pinky { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            prox<>elbow.wrist.pinky { pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            dist<>elbow.wrist.pinky { pos{ pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                    pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
            hip<>body.right {
                knee<>body.right.hip {
                    ankle<>right.hip.knee {
                        toes<>hip.knee.ankle {
                            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                        pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                    pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
                pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
            pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
        pos(x 0..1, y 0..1, z 0..1) angle(roll %360, pitch %360, yaw %360) mm(0..3000) }
    ˚˚ <> .. }
