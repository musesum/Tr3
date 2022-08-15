hader.model {
    cell {
        fade  (val 0…1 = 0.5)
        ave   (val 0…1 = 0.5)
        melt  (val 0…1 = 0.5)
        tunl  (seg 0…5 = 1  )
        slide (seg 0…7 = 3  )
        fred  (seg 0…4 = 4  )
        zha   (seg 0…6 = 2, bits 2…4 = 3)
        cell˚.{ on(0…1) >> cell˚.on(0) }
        zha.loops(11)
    }
    pipe {
        record (tog 0)
        camera (tog 0) { flip (tog) }
        camix  (tog 0)
        draw   (x 0…1 = 0.5,
                y 0…1 = 0.5)

        render {
            frame (x 0, y 0, w 1080, h 1920)
            repeat (x, y)
            mirror (x, y)
        }
        color(val 0…1 = 0.3) // bitplane
    }
}
shader.file {
    cell {
        fade  ("cell.fader.metal")
        ave   ("cell.ave.metal"  )
        melt  ("cell.melt.metal" )
        tunl  ("cell.tunl.metal" )
        slide ("cell.slide.metal")
        fred  ("cell.fred.metal" )
        zha   ("cell.zha.metal"  )
    }
    pipe {
        record
        camera ("cell.camera.metal")
        camix  ("cell.camix.metal" )
        draw   ("pipe.draw.metal" )
        render ("pipe.render.metal")
        color  ("pipe.color.metal" )
    }
}
