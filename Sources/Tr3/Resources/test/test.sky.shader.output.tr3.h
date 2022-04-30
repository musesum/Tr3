√ {
    sky {
        shader {
            cell {
                fade (compute, slide, file "cell.fader.metal") {
                    on (0..1)
                }
                melt (compute, slide, file "cell.melt.metal") {
                    on (0..1)
                }
                ave (compute, slide, file "cell.ave.metal") {
                    on (0..1)
                }
                fred (compute, segmt, file "cell.fred.metal") {
                    on (0..1)
                }
                gas (compute, segmt, file "cell.gas.metal") {
                    on (0..1)
                }
                mod (compute, segmt, file "cell.mod.metal") {
                    on (0..1)
                }
                slide (compute, segmt, file "cell.slide.metal") {
                    on (0..1)
                }
                drift (compute, segmt, file "cell.drift.metal") {
                    on (0..1)
                }
                tunl (compute, segmt, file "cell.tunl.metal") {
                    on (0..1)
                }
                zha (compute, segmt, file "cell.zha.metal") {
                    on (0..1)
                    repeat (11)
                    buffer {
                        bits (2..4 = 3)
                    }
                }
            }
            pipeline {
                record (record, file "record.metal") {
                    on (0..1)
                    version (0..1)
                    flip (0..1)
                }
                camera (camera, file "cell.camera.metal") {
                    on (0..1)
                    version (0..1)
                    flip (0..1)
                }
                camix (camix, file "cell.camix.metal") {
                    on (0..1)
                    version (0..1)
                    flip (0..1)
                }
                draw (draw, file "drawScroll.metal") {
                    on (0..1)
                    scroll (x 0..1 = 0.5, y 0..1 = 0.5)
                }
                color (colorize, file "colorize.metal") {
                    bitplane (0..1)
                }
                render (render, file "render.metal") {
                    clip (x 0, y 0, w 1080, h 1920)
                    repeat (x, y)
                    mirror (x, y)
                }
            }
        }
    }
}
