///here is a Human body skeleton in defined three lines of code

body {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes}
˚˚ <-> .. // connect every node to its parent
˚˚:{pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000)})

// producing the following output:

√ { body<->√ {
    left<->body {
        shoulder<->body.left {
            elbow<->body.left.shoulder {
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
        hip<->body.left {
            knee<->body.left.hip {
                ankle<->left.hip.knee {
                    toes<->hip.knee.ankle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    right<->body {
        shoulder<->body.right {
            elbow<->body.right.shoulder {
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
        hip<->body.right {
            knee<->body.right.hip {
                ankle<->right.hip.knee {
                    toes<->hip.knee.ankle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    ˚˚<->.. }
