√ {
    sky {
        main { frame:0 fps:(1...60=60) }
        colorize { xfade:(0...1=0.5) pal0:"rgbK" pal1:"wKZ" }
        input { azimuth:(x y):(-0.2...0.2=0) force:(0...0.5=0) -> sky.draw.brush.size accel:(x y z):(-0.3...0.3) { on:(0...1) } radius:(1...92=9) tilt:(0...1=0) }
        draw {
            screen { fillZero:0 fillOne:-1 }
            brush { type:"dot" size:(1...64=10) press:(0...1=1) index:(1...255=127) }
            line { prev:(x y):(0...1) next:(x y):(0...1) } }
        shader {
            _compute { type:"compute" file:"whatever.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellMelt { type:"compute" file:"cell.melt.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellFredkin { type:"compute" file:"cell.fredkin.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellGas { type:"compute" file:"cell.gas.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellAverage { type:"compute" file:"cell.average.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellModulo { type:"compute" file:"cell.modulo.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellFader { type:"compute" file:"cell.fader.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellSlide { type:"compute" file:"cell.slide.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellDrift { type:"compute" file:"cell.drift.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellTimetunnel { type:"compute" file:"cell.timetunnel.metal" on:(0...1=0) buffer { version:(0...1=0) } }
            cellZhabatinski { type:"compute" file:"cell.zhabatinski.metal" on:(0...1=0) buffer { version:(0...1=0) bits:(2...4=3) } repeat:11 }
            drawScroll { type:"draw" file:"drawScroll.metal" on:(0...1=0) buffer { scroll:(x y):(0...1=0.5) } }
            colorize { type:"colorize" file:"colorize.metal" buffer { bitplane:(0...1=0) } }
            render { type:"render" file:"render.metal"
                buffer { repeat:(x y) mirror:(x y) } } } }
    panel {
        _cell {
            base { type:"cell" title:"_cell" frame:(x:0 y:0 w:320 h:152) icon:"icon.ring.white.png" }
            controls {
                ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.ring.white.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 lag:0 }
                version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) user -> ruleOn.value:1 }
                fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
        cell {
            fader {
                base { type:"cell" title:"Fader" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.fader.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.fader.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellFader.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=0.5) -> sky.shader.cellFader.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            fredkin {
                base { type:"cell" title:"Fredkin" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.fredkin.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.fredkin.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellFredkin.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) -> sky.shader.cellFredkin.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            timetunnel {
                base { type:"cell" title:"Time Tunnel" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.timeTunnel.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.timeTunnel.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellTimetunnel.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) -> sky.shader.cellTimetunnel.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            zhabatinski {
                base { type:"cell" title:"Zhabatinski" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.zhabatinski.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.zhabatinski.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellZhabatinski.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) -> sky.shader.cellZhabatinski.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            melt {
                base { type:"cell" title:"Melt" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.melt.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.melt.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellMelt.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) -> sky.shader.cellMelt.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            average {
                base { type:"cell" title:"Average" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.average.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.average.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellAverage.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) -> sky.shader.cellAverage.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            slide {
                base { type:"cell" title:"Slide Bit Planes" frame:(x:0 y:0 w:320 h:152) icon:"icon.cell.slide.png" }
                controls {
                    ruleOn { type:"switch" title:"Active" frame:(x:252 y:6 w:48 h:32) icon:"icon.cell.slide.png" value:(0...1=0) -> panel.cell˚ruleOn.value:0 -> sky.shader.cellSlide.on lag:0 }
                    version { type:"segment" title:"Version" frame:(x:70 y:40 w:192 h:44) value:(0...1=1) -> sky.shader.cellSlide.buffer.version user -> ruleOn.value:1 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:10 y:96 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:96 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:96 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            brush {
                base { type:"brush" title:"Brush" frame:(x:0 w:0 w:320 h:168) icon:"icon.cell.brush.png" }
                controls {
                    brushPress { type:"switch" title:"Pressure" frame:(x:10 y:50 w:66 h:44) icon:"icon.pen.press.png" value:(0...1=0) <-> sky.draw.brush.press }
                    brushSize { type:"slider" title:"Size" frame:(x:86 y:50 w:206 h:44) value:(0...1) <-> sky.draw.brush.size user -> brushPress.value:0 }
                    fillZero { type:"trigger" title:"clear 0" frame:(x:4 y:108 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:108 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"clear 0xFFFF" frame:(x:266 y:108 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            scroll {
                base { type:"cell" title:"Scroll" frame:(x:0 y:0 w:224 h:178) icon:"icon.scroll.png" }
                controls {
                    scrollBox { type:"box" title:"Screen Scroll" frame:(x:86 y:40 w:128 h:128) radius:10 tap2:(-1 -1) lag:0.5 value:(x y):(0...1=0.5) <-> sky.input.azimuth -> sky.shader.drawScroll.buffer.scroll user ->(brushTilt.value:0 accelTilt.value:0 ) }
                    brushTilt { type:"switch" title:"Brush Tilt" frame:(x:10 y:52 w:66 h:44) icon:"icon.pen.tilt.png" value:(0...1=0) <-> sky.input.tilt -> accelTilt.value:0 }
                    accelTilt { type:"switch" title:"Accelerometer Tilt" frame:(x:10 y:112 w:66 h:44) icon:"icon.scroll.png" value:(0...1) <-> sky.input.accel.on -> brushTilt.value:0 } } }
            speed {
                base { type:"cell" title:"Speed" frame:(x:0 y:0 w:212 h:94) icon:"icon.magnet.png" } controls {
                    speed { type:"slider" title:"Frames per second" frame:(x:10 y:40 w:192 h:44) icon:"icon.pearl.white.png" value:(1...60=60) <-> sky.main.fps } } } }
        shader {
            colorize {
                base { type:"colorize" title:"Colorize" frame:(x:0 y:0 w:320 h:176) icon:"icon.pal.main.png" }
                controls {
                    palFade { type:"slider" title:"Palette Cross Fade" frame:(x:64 y:50 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) <-> sky.colorize.xfade lag:0 }
                    fillZero { type:"trigger" title:"Fill Zero" frame:(x:4 y:108 w:44 h:44) icon:"icon.drop.clear.png" value:(0...1=0) -> sky.draw.screen.fillZero }
                    bitplane { type:"slider" title:"Bit Plane" frame:(x:64 y:108 w:192 h:44) icon:"icon.pearl.white.png" value:(0...1=0) -> sky.shader.colorize.buffer.bitplane }
                    fillOne { type:"trigger" title:"Fill Ones" frame:(x:266 y:108 w:44 h:44) icon:"icon.drop.gray.png" value:(0...1=0) -> sky.draw.screen.fillOne } } }
            tile {
                base { type:"shader" title:"Tile" frame:(x:0 y:0 w:230 h:170) icon:"icon.shader.tile.png" }
                controls {
                    mirrorBox { type:"box" title:"Mirror" frame:(x:10 y:80 w:80 h:80) radius:10 tap2:(1 1) lag:0 user:(0...1=1) value:(0 0):(0...1=0) -> sky.shader.render.buffer.mirror }
                    repeatBox { type:"box" title:"Repeat" frame:(x:100 y:40 w:120 h:120) radius:10 tap2:(-1 -1) lag:0.5 user:(0...1=1) value:(0 0):(0...1) -> sky.shader.render.buffer.repeat } } } } } }
