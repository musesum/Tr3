√ {
    sky {  // visual music program
        main {  // main controls
            frame (0)  // frame counter
            fps (1..60 = 60)  // frames per second
            run (1)  // currently running
        }
        pipeline {  // default metal pipeline at atartup
            drawScroll "draw"  // drawing layer
            cellAverage "compute"  // compute layer
            colorize "colorize"  // colorizing layer
            render "render"  // render layer al
        }
        dock {  // list of panel items to put in dock
            fader average (1)
            melt timetunnel zhabatinski slide fredkin brush colorize scroll tile speed camera record }
        colorize {  // false color mapping palette
            pal0 "roygbik"  // palette 0: (r)ed (o)range (y)ellow ...
            pal1 "wKZ"  // palette 1: (w)hite blac(K) fractali(Z)e
            xfade (0..1 = 0.5)  // cross fade between pal0 and pal1
        }
        input {  // phone and tablet pencil input
            azimuth (x -0.2..0.2, y -0.2..0.2)  // pen tilt
            accel (x -0.3..0.3, y -0.3..0.3, z -0.3..0.3) {  // accelerometer
                on (0..1)
            }
            radius (1..92 = 9)  // finger silhouette
            tilt (0..1)  // use tilt
            force (0..0.5) >> draw.brush.size  // pen pressure
        }
        draw {  // draw on metal layer

            screen {  // fill 32 bit universe

                fillZero (0)  // all zeros 0x00000000
                fillOne (-1)  // all ones 0xFFFFFFFF
            }
            brush {  // type of brush and range

                type "dot"  // draw a circle
                size (1..64 = 10)  // range of radius
                press (0..1 = 1)  // pressure changes size
                index (1..255 = 127)  // index in 256 color palette
                                      // <<(osc.tuio.z osc.manos˚z) // redirect from OSC
            }
            line {  // place holder for line drawing

                prev (x 0..1, y 0..1)  // staring point of segment
                next (x 0..1, y 0..1)  // endint point of segment
            }
        }
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

