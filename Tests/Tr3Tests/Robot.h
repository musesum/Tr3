///here is a robot in defined three lines of code

robot {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes}
˚˚ <-> .. // connect every node to its parent
˚˚:{pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000)})

// producing the following output:

√ { robot<->√ {
    left<->robot {
        shoulder<->robot.left {
            elbow<->robot.left.shoulder {
                wrist<->left.shoulder.elbow {
                    thumb<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    index<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    middle<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    ring<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pinky<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        hip<->robot.left {
            knee<->robot.left.hip {
                ankle<->left.hip.knee {
                    toes<->hip.knee.ankle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    right<->robot {
        shoulder<->robot.right {
            elbow<->robot.right.shoulder {
                wrist<->right.shoulder.elbow {
                    thumb<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    index<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    middle<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    ring<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pinky<->shoulder.elbow.wrist {
                        meta<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        prox<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        dist<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        hip<->robot.right {
            knee<->robot.right.hip {
                ankle<->right.hip.knee {
                    toes<->hip.knee.ankle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    ˚˚<->.. }
