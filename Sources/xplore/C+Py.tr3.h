Rules:
    key
        "↘︎" next line INDENT tab
        "↓" next line NODENT same column on next line
        "↙︎" next line DEDENT tab
        "," same line - equivalent to NODENT "↓"
        "{ ... }" same line - equivalent to "↘︎ ... ↙︎"

    "A,B"  ( user removes "," after A) => "A↓B"
    "A{B}" ( user removes "{" after A) => "A↘︎B"
    "A↘︎B"  ( user inserts "{" after A) => "A{B}"
    "A↘︎B"  ( user removes "\n" befor B) => "A{B}"

    "A,B,C" ( user removes "," after A) => "A↓B,C"
    "A,B,C" ( user inserts "\n" before B) => "A↓B,C"

    "A{B,C}" ( user removes "{" after A) => "A↘︎B,C"
    "A↘︎B,C"  ( user inserts "{" after A) => "A{B,C}"

    "A↘︎B↘︎C"  ( user tabs "↘︎" before A) => "↘︎A↘︎B↘︎C"
    "↘︎A↘︎B↘︎C" ( user untabs "↙︎" before A) => "A↘︎B↘︎C"

    "A↘︎B↘︎C"  ( can fit on same line) => "A{B{C}}"
    "A{B{C}}" (cannot fit on same line) => "A↘︎B{C}"
    "A,B,C" (cannot fit on same line) => "A↓B,C" or "A,B↓C", where both lines balance length
            "A↓B,C", when ABS(length(A)-length(B,C)) < ABS(length(A,B)-length(C)
            "A,B↓C", when ABS(length(A)-length(B,C)) >= ABS(length(A,B)-length(C)

Discussion

    Python style INDENT DEDENT is more readable but vertically verbose
    C style curly { } pairs ofuscates hierarchy but is vertically concise
    So, combine both INDENT+{ DEDINT+} and choose based on editor dimensions
    Also, create a unique editor extension to support: code folding, auto indentation, and hosting




sky // visual music program

    main // main controls
        frame (0)  // frame counter
        fps (1..60 = 60)  // frames per second
        run (1)  // currently running

    pipeline // default metal pipeline at atartup
        drawScroll "draw"  // drawing layer
        cellAverage "compute"  // compute layer
        colorize "colorize"  // colorizing layer
        render "render"  // render layer al

    dock { fader, average (1), melt, timetunnel, zhabatinski, slide, fredkin, brush, colorize, scroll, tile, speed, camera, record }

    colorize // false color mapping palette
        pal0 "roygbik"  // rainbow palette
        pal1 "wKZ"  // (w)hite blac(K) fractali(Z)e
        xfade (0..1 = 0.5)  // cross fade between pal0 and pal1

    input // phone and tablet pencil input
        azimuth (x -0.2..0.2, y -0.2..0.2)  // pen tilt
        accel (x -0.3..0.3, y -0.3..0.3, z -0.3..0.3)   // accelerometer
            on (0..1)  // use accel

        radius (1..92 = 9)  // finger silhouette
        tilt (0..1)  // use tilt
        force (0..0.5) >> draw.brush.size  // pen pressure

    draw   // draw on metal layer
        screen   // fill 32 bit universe
            fillZero (0)  // all zeros 0x00000000
            fillOne (-1)  // all ones 0xFFFFFFFF

        brush // type of brush and range
            type "dot"  // draw a circle
            size (1..64 = 10)  // range of radius
            press (0..1 = 1)  // pressure changes size
            index (1..255 = 127)  // index in 256 color palette
                                  // <<(osc.tuio.z osc.manos˚z) // redirect from OSC
        line   // place holder for line drawing
            prev (x 0..1, y 0..1)  // staring point of segment
            next (x 0..1, y 0..1)  // endint point of segment

    shader
        _compute { type "compute", file "whatever.metal", on (0..1), buffer.version (0..1) }
        cellMelt: _compute { type "compute", file "cell.melt.metal", on (0..1), buffer.version (0..1) }
        cellFredkin: _compute { type "compute", file "cell.fredkin.metal", on (0..1), buffer.version (0..1) }
        cellGas: _compute { type "compute", file "cell.gas.metal", on (0..1), buffer.version (0..1) }
        cellAverage: _compute { type "compute", file "cell.average.metal", on (0..1), buffer.version (0..1) }
        cellModulo: _compute { type "compute", file "cell.modulo.metal", on (0..1), buffer.version (0..1) }
        cellFader: _compute { type "compute", file "cell.fader.metal", on (0..1), buffer.version (0..1) }
        cellSlide: _compute { type "compute", file "cell.slide.metal", on (0..1), buffer.version (0..1) }
        cellDrift: _compute { type "compute", file "cell.drift.metal", on (0..1), buffer.version (0..1) }
        cellTimetunnel: _compute { type "compute", file "cell.timetunnel.metal", on (0..1), buffer.version (0..1) }
        cellZhabatinski: _compute { type "compute", file "cell.zhabatinski.metal", on (0..1), buffer.version (0..1), bits (2..0.4 = 3), repeat (11) }
        record { type "record", file "record.metal", on (0..1), buffer.version (0..1), flip (0..1) }
        cellCamera { type "camera", file "cell.camera.metal", on (0..1), buffer.version (0..1), flip (0..1) }
        cellCamix { type "camix", file "cell.camix.metal", on (0..1), buffer.version (0..1), flip (0..1) }
        drawScroll { type "draw", file "drawScroll.metal", on (0..1), buffer.scroll (x 0..1.5, y 0..1.5) }
        colorize { type "colorize", file "colorize.metal", buffer.bitplane (0..1) }
        render { type "render", file "render.metal", buffer.repeat (x, y), mirror (x, y) }

panel
    _cell
        base { type "cell", title "_cell", frame (x 0, y 0, w 250, h 130), icon "icon.ring.white.png" }
        controls
            hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
            ruleOn
                type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.ring.white.png",
                value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart), lag (0)
            version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 1), user >>controls.ruleOn.value(1) }
            lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { off "icon.lock.closed.png", on "icon.lock.open.png" }, value (0..1), lag (0) }
            bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
            fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }
    cell
        fader: _cell
            base { type "cell", title "Fader", frame (x 0, y 0, w 250, h 130), icon "icon.cell.fader.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.fader.png",
                    value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellFader.on), lag (0)
                version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 0.5) >>cellFader.buffer.version, user >>controls.ruleOn.value(1) }
                lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { off "icon.lock.closed.png", on "icon.lock.open.png"}, value (0..1), lag (0) }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1 = 0.2) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }
        fredkin: _cell
            base { type "cell", title "Fredkin", frame (x 0, y 0, w 250, h 130), icon "icon.cell.fredkin.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.fredkin.png"
                    value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellFredkin.on), lag (0)
                version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 0.5) >>cellFredkin.buffer.version, user >>controls.ruleOn.value(1) }
                lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { off "icon.lock.closed.png", on "icon.lock.open.png"}, value (0..1), lag (0) }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32) icon, "icon.drop.gray.png" value (0..1) >>draw.screen.fillOne }

        timetunnel: _cell
            base { type "cell", title "Time Tunnel", frame (x 0, y 0, w 250, h 130), icon "icon.cell.timeTunnel.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.timeTunnel.png"
                    value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellTimetunnel.on), lag (0)
                version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 1) >>cellTimetunnel.buffer.version, user >>controls.ruleOn.value(1) }
                lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { "icon.lock.closed.png", on "icon.lock.open.png" }, value (0..1), lag (0) }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }

        zhabatinski: _cell
            base { type "cell", title "Zhabatinski", frame (x 0, y 0, w 250, h 130), icon "icon.cell.zhabatinski.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.zhabatinski.png"
                    value (0..1) >> (controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellZhabatinski.on), lag (0)
                version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 0.75) >>cellZhabatinski.buffer.version, user >>controls.ruleOn.value(1) }
                lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { "icon.lock.closed.png", on "icon.lock.open.png" }, value (0..1), lag (0) }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }

        melt: _cell
            base { type "cell", title "Melt", frame (x 0, y 0, w 250, h 130), icon "icon.cell.melt.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png" value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.melt.png", value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellMelt.on), lag (0)
                version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 1) >>cellMelt.buffer.version, user >>controls.ruleOn.value(1) }
                lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { "icon.lock.closed.png", on "icon.lock.open.png" }, value (0..1), lag (0) }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (1.67772e+07) >>draw.screen.fillOne }
                fillZero.value (1.67772e+07)
        average: _cell
            base { type "cell", title "Average", frame (x 0, y 0, w 250, h 130), icon "icon.cell.average.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.average.png",
                    value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellAverage.on), lag (0)
                version { type "segment", title "Version", frame (x 10, y 44, w 192, h 32) value (0..1 = 0.4) >>cellAverage.buffer.version, user >>controls.ruleOn.value(1) }
                lock { type "switch", title "Lock", frame (x 210, y 44, w 32, h 32), icon { "icon.lock.closed.png", on "icon.lock.open.png" }, value (0..1), lag (0)
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }

        slide: _cell
            base { type "cell", title "Slide Bit Planes", frame (x 0, y 0, w 250, h 130), icon "icon.cell.slide.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                ruleOn
                    type "panelon", title "Active", frame (x 202, y 4, w 40, h 32), icon "icon.cell.slide.png", value (0..1) >>(controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), controls.ruleOn.value(0), cell.speed.restart, shader.cellSlide.on), lag (0)
                version
                    type "segment", title "Version", frame (x 10, y 44, w 192, h 32), value (0..1 = 1) >>cellSlide.buffer.version, user >>controls.ruleOn.value(1)
                lock
                    type "switch", title "Lock", frame (x 210, y 44, w 32, h 32)
                    icon { "icon.lock.closed.png", on "icon.lock.open.png" }
                    value (0..1), lag (0)
                bitplane
                    type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane
                fillOne   // ffffffde

                    type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne
        brush
            base { type "brush", title "Brush", frame (x 0, y 0, w 262, h 120), icon "icon.cell.brush.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                brushSize { type "slider", title "Size", frame (x 10, y 40, w 192, h 32), value (0..1) <>draw.brush.size, user >>controls.brushPress.value(0) }
                brushPress { type "switch", title "Pressure", frame (x 210, y 40, w 44, h 32), icon "icon.pen.press.png", value (0..1) <>draw.brush.press }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 80, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "clear 0xFFFF", frame (x 210, y 80, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }

        scroll
            base { type "cell", title "Scroll", frame (x 0, y 0, w 192, h 180), icon "icon.scroll.png" }
            controls
                scrollOn
                    type "panelon", title "Active", frame (x 148, y 6, w 40, h 32), icon "icon.scroll.png", value (0..1), lag (0),
                    user >>(controls.scrollBox.value(x 0.5, y 0.5)
                    controls.brushTilt.value(0))
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                scrollBox
                    type "box", title "Screen Scroll", frame (x 8, y 44, w 128, h 128), radius (10), tap2 (-1, -1), lag (0)
                    value (x 0..1.5, y 0..1.5) <> sky.input.azimuth >>drawScroll.buffer.scroll
                    user >> (controls.brushTilt.value(0)
                    controls.scrollOn.value(1))
                brushTilt { type "switch", title "Brush Tilt", frame (x 144, y 62, w 40, h 32), icon "icon.pen.tilt.png", value (0..1) <> sky.input.tilt }
                fillZero { type "trigger", title "Fill Zero", frame (x 148, y 116, w 32, h 32), icon "icon.drop.clear.png", value (0..1) >> draw.screen.fillZero }

        speed
            restart >>controls.speed.value(60)
            base { type "cell", title "Speed", frame (x 0, y 0, w 212, h 104), icon "icon.speed.png" }
            controls
                speedOn
                    type "panelon", title "Active", frame (x 154, y 6, w 48, h 32), icon "icon.speed.png", value (0..1) >>sky.main.run, user  >> scrollBox.value(x 0.5, y 0.5), lag (0)
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                speed
                    type "slider", title "Frames per second", frame (x 10, y 50, w 192, h 44), icon "icon.pearl.white.png", value (1..60 = 60) <>sky.main.fps, user >>controls.speedOn.value(1)
    shader
        colorize
            base { type "colorize", title "Colorize", frame (x 0, y 0, w 250, h 130), icon "icon.pal.main.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                palFade { type "slider", title "Palette Cross Fade", frame (x 10, y 44, w 192, h 32), icon "icon.pearl.white.png", value (0..1) <>sky.colorize.xfade, lag (0) }
                bitplane { type "slider", title "Bit Plane", frame (x 10, y 84, w 192, h 32), icon "icon.pearl.white.png", value (0..1) >>colorize.buffer.bitplane }
                fillOne { type "trigger", title "Fill Ones", frame (x 210, y 84, w 32, h 32), icon "icon.drop.gray.png", value (0..1) >>draw.screen.fillOne }

        tile
            base { type "shader", title "Tile", frame (x 0, y 0, w 230, h 170), icon "icon.shader.tile.png" }
            controls
                hide { type "panelx", title "hide", frame (x 0, y 0, w 40, h 40), icon "icon.thumb.X.png", value (0..1) }
                tileOn { type "panelon", title "Active", frame (x 174, y 6, w 40, h 32), icon "icon.shader.tile.png", value (0..1), user >>controls.repeatBox.value(x 0, y 0), lag (0) }
                repeatBox
                    type "box", title "Repeat", frame (x 10, y 40, w 120, h 120), radius (10), tap2 (-1, -1), lag (0), user (0..1 = 1) >>controls.tileOn.value(1), value (x 0..1, y 0..1) >>render.buffer.repeat
                mirrorBox
                    type "box", title "Mirror", frame (x 140, y 60, w 80, h 80), radius (10), tap2 (1, 1), lag (0), user (0..1 = 1), value (x 0..1, y 0..1) >>render.buffer.mirror

