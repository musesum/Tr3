menu {
    canvas (icon "icon.drop.clear") {
        fill (icon "icon.speed.png") {
            plane (slide)
            zero  (drum, icon "icon.drop.clear") // fillZero
            one   (drum, icon "icon.drop.gray") // fillOne
        }
        tile (icon "icon.shader.tile.png") {
            mirror (boxy, icon "icon.shader.tile.png") // mirrorBox
            repeat (boxy, icon "icon.shader.tile.png") // repeatBox
        }
        scroll (icon "icon.cell.scroll.png") {
            box  (boxy, icon "icon.cell.scroll.png") // scrollBox
            tilt (toggl, icon "icon.pen.tilt.png") // brushTilt
        }
        color(icon "icon.pal.main.png") {
            fade (boxy, icon "icon.scroll.png") // scrollBox
            tilt (toggl, icon "icon.pen.tilt.png") // brushTilt
        }
    }
    speed (icon "icon.speed.png") {
        fps   (slide, icon "icon.speed.png")
        pause (toggl, icon "icon.thumb.x.png")
    }
    brush (icon "icon.cell.brush.png") {
        size  (slide, icon "icon.pen.press.png") // brushSize
        press (toggl, icon "icon.pen.press.png") // brushPress
        tilt  (toggl, icon "icon.pen.tilt.png") // brushPress
    }
    cell {
        fade  (slide, icon "icon.cell.fader")
        ave   (slide, icon "icon.cell.average")
        melt  (slide, icon "icon.cell.melt")
        tunl  (segmt 0...5, icon "icon.cell.time")
        zha   (segmt 0...6, icon "icon.cell.zha")
        slide (segmt 0...7, icon "icon.cell.slide.png")
        fred  (segmt 0...4, icon "icon.cell.fred.png")
    }
    camera (icon "icon.camera.png") {
        fake (toggl, icon "icon.camera.png")
        real (toggl, icon "icon.camera.png")
        face (toggl, icon "icon.camera.flip.png") >> sky.shader.camera.flip
        xfade(slide, icon "icon.pearl.white.png")
        snap (drum,  icon "icon.camera.png")
    }
}
