//
//  File.swift
//  
//
//  Created by warren on 9/13/19.
//

import Foundation

#if false
/// currently cannot bundle resource with Swift package

func parseFile(_ fileName:String) -> Bool {
    if tr3Parse.parseTr3(root,fileName) {
        return 0
    }
    else {
        return 1
    }
}

func testInherit() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
    var err = 0
    let root = Tr3("√")
    err += parseFile("multiline")
    err += parseFile("multimerge")
    let actual = root.makeScript()
    print(actual)
    XCTAssertEqual(err,0)
}


func testSky() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

    var err = 0
    let root = Tr3("√")
    func parseFile(_ fileName:String) { tr3Parse.parseTr3(root,fileName) }


    err += parseFile("sky.main")
    err += parseFile("sky.shader")
    err += parseFile("panel.cell")
    err += parseFile("panel.cell.fader")
    err += parseFile("panel.cell.fredkin")
    err += parseFile("panel.cell.timeTunnel")
    err += parseFile("panel.cell.zhabatinski")
    err += parseFile("panel.cell.melt")
    err += parseFile("panel.cell.average")
    err += parseFile("panel.cell.slide")
    err += parseFile("panel.cell.brush")
    err += parseFile("panel.shader.colorize")
    err += parseFile("panel.cell.scroll")
    err += parseFile("panel.shader.tile")
    err += parseFile("panel.speed")

    // aways last to connect ruleOn, value state between dots

    let actual = root.makeScript(0,pretty:true)
    let planned =
    #"""
√ {
    sky {
        main {
        frame:0  fps:(1...60=60)
            shader { uniform.shift:(0...1=0)  fragment {{ #version 300 es

                in highp vec2 vTexCoord;
                out highp vec4 fragColor;

                precision highp float;
                uniform sampler2D drawBuf; // 2D texture
                uniform sampler2D drawPal; // 256x1 color palette for texture
                uniform float fade; // fade key slider value

                void main () {
                    vec4 realColor   = texture(drawBuf, vTexCoord.xy);
                    vec4 falseColorB = texture(drawPal, vec2(realColor.b,0.));
                    vec4 falseColorR = texture(drawPal, vec2(realColor.r,0.));
                    float fadeInverse = 1.-fade;
                    fragColor = vec4(falseColorR.r * fadeInverse + falseColorB.r * fade,
                                     falseColorR.g * fadeInverse + falseColorB.g * fade,
                                     falseColorR.b * fadeInverse + falseColorB.b * fade, 1.);
                }
            }}
                vertex {{ #version 300 es

                    in mediump vec4 aPosition;
                    in mediump vec2 aTexCoord;
                    out mediump vec2 vTexCoord;

                    void main() {
                        gl_Position = aPosition;
                        vTexCoord = aTexCoord.xy;
                    }
                }}
            }
        }
        input { shake azimuth:(x y):(-1...1=0)  force:(0...0.5=0)  accel:(x y z):(-0.3...0.3) .on:(0...1)  radius:(1...64=9)  }
        screen {
        realfake:(0...100=100)
            fade { real:(0...1000=1000)  fake:(0...1000=1000)  cross:(0...1000=1000)  }
            luma { size:(0...12700=700)  black:(0...25600=0)  white:(0...25600=25600)  }
            projector { on:(0...1=1)  width:1920  height:1080  }
        fullscreen:(%21)  dispatch:(0...1)  mode:(0...1)  limit:(%2)  type ogl.mapping
            face {
            rendertex:(%2)  automipmap:(%2)  reflection:(%2)  background:(%2)  foreground:(%2)  texture:(%2)  wireframe:(%2)
                set { background:(%2)  foreground:(%2)  wireframe:(%2)  texture:(%2)  }
                univ.wrap }
            shift {
                real { on:(0...1=1)  changed:(0...1=0)  reverse:(%2)  sum:(x y)  ofs:(x y):(-16...16=0)  add:(x y):(-16...16=0)  }
                fake { on:(0...1=1)  changed:(0...1=0)  reverse:(%2)  sum:(x y)  ofs:(x y):(-16...16=0)  add:(x y):(-16...16=0)  }
            }
            shift.fake.add<- sky.input.azimuth  }
        cell {
            _rule {
            version:(1...4=1)  mix.plane:(0...23=0)
                brush { size:(1...32=1)  index:(0...255=127)  }
            }
            rule {
                add melt zero one version:(1...4=1)  mix.plane:(0...23=0)
                brush { size:(1...32=1)  index:(0...255=127)  }
            }
        }
        pal {
            status { dyna:(0...11=0)  bw:(%2)  bwVal:(0...200=100)  }
            cycle { step:(-55...55=0)  ofs:(%256)  inc:(-16...16=0)  div:(1...30=4)  }
            change { changes:0  realpal:(0...1)  xfade:(0...255=128)  mix smooth:(1...255=255)  insert zeno:(0...1)  remove back add:(0...8)  }
            ripple { pulse:(8...240=239)  width:(16...255=12)  hue:(%3600)  sat:(0...100=100)  val:(0...100=100)  dur:(0...4=0.08)  }
            pal0:"= k k + r o y g b i v"  pal1:"= k k + w z"  }
        osc {
            in { host port:8000  message }
            out { host port:9000  message }
        brush:(0...1)  { size color }
        accxyz:(x y z):(-1...1)  msaremote.accelerometer:(x y z):(-1...1)
            tuio { prev:(x y z f)  next:(x y z f)  }
            midi.note { number:(0...127)  velocity:(0...127)  channel:(1...16)  duration }
            manos:(x y z):(0...1)  }
        time {
            clock {
                frame status
            lock:(0...1)  { fps:(0...12000=24)  base:(0...10000=1)  }
                fps:(0...120=20) .now:(0...200)  }
        adsr:(on amp dur):(0...1=1)  { global attack decay sustain release }
            lfo { type:(1...4=1)  radians:(1...8=2)  amp:(0...255=200)  dur count }
            beat { new rec stop play span now sync tick }
        }
        recorder { filename:"recorder"  useframe:(0...1=0)  loop:(0...1=1)  record pause play rewind toend erase event }
    }
    _controlBase {
        base { type:"unknown"  title:"Unknown"  frame:(x:0 y:0 w:320 h:176)  icon:"control.ring.white.png"  }
        elements.ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
    }
    _controlRule {
        base { type:"unknown"  title:"Unknown"  frame:(x:0 y:0 w:320 h:176)  icon:"control.ring.white.png"  }
        elements.ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
    }
    _controlSpeed {
        base { type:"rule"  title:"Rule"  frame:(x:0 y:0 w:320 h:222)  icon:"control.ring.white.png"  }
        elements {
            ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
            speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
        }
        shader.falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
        renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
    }
    control {
        shader.plane {
            base { type:"shader"  title:"Plane"  frame:(x:0 y:0 w:220 h:188)  icon:"control.shader.tile.png"  }
            elements {
                ruleOn { type:"switch"  title:"Active"  frame:(x:166 y:6 w:48 h:32)  lag:0  value:(0...1)  icon:"control.shader.tile.png"  }
                mirrorBox { type:"box"  title:"Mirror"  frame:(x:10 y:106 w:56 h:56)  radius:10  tap2:(1 1)  lag:0  master:(0...1=1)  value:(0 0):(0...1=0) -> control.shader.tile.shader.uniform.mirror  }
                repeatBox { type:"box"  title:"Repeat"  frame:(x:80 y:52 w:120 h:120)  radius:10  tap2:(-1 -1)  lag:0.5  master:(0...1=1)  value:(0 0):(0...1) -> control.shader.tile.shader.uniform.repeat  }
            }
            shader.render:"render.basic.metal"  { type:"render"  repeat:(x y) <- elements.repeatBox.value  mirror:(x y) <- elements.mirrorBox.value  }
        }
        cell {
            shift {
                base { type:"cell"  title:"Shift"  frame:(x:0 y:0 w:270 h:226)  icon:"control.shift.png"  }
                elements {
                    ruleOn { type:"switch"  title:"Active"  frame:(x:216 y:6 w:48 h:32)  lag:0  value icon:"control.shift.png"  }
                    shiftBox { type:"box"  title:"Screen Shift"  frame:(x:86 y:52 w:128 h:128)  radius:10  tap2:(-1 -1)  lag:0.5  value:(x y):(0...1=0.5) <-> sky.input.azimuth  master:(0...1)  }
                    brushTilt { type:"switch"  title:"Brush Tilt"  frame:(x:10 y:52 w:66 h:44)  icon:"control.pen.tilt.png"  value-> sky.draw.brush.tilt  }
                    accelTilt { type:"switch"  title:"Accelerometer Tilt"  frame:(x:10 y:112 w:66 h:44)  icon:"control.shift.png"  value<-> sky.input.accel.on  }
                }
                shader.cellDraw:"cell.draw.metal"  { version:(0...1=0) <- elements.version.value  scroll:(x y):(0...1) <- elements.shiftBox.value  on:(0...1=0) <- elements.ruleOn.value  type:"draw"  }
            }
            rule {
                timetunnel {
                    base { type:"rule"  title:"Time Tunnel"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.timeTunnel.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellTimetunnel:"cell.rule.timetunnel.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                fader {
                    base { type:"rule"  title:"Fader"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.fader.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellFader:"cell.rule.fader.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                zhabatinski {
                    base { type:"rule"  title:"Rule"  frame:(x:0 y:0 w:320 h:222)  icon:"control.ring.white.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader.falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                melt {
                    base { type:"rule"  title:"Melt"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.melt.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellMelt:"cell.rule.melt.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                average {
                    base { type:"rule"  title:"Average"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.average.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellAverage:"cell.rule.average.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                slide {
                    base { type:"rule"  title:"Slide Bit Planes"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.slide.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellSlide:"cell.rule.slide.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                fredkin {
                    base { type:"rule"  title:"Fredkin"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.fredkin.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellFredkin:"cell.rule.fredkin.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
            }
            brush {
                base { type:"brush"  title:"Brush"  frame:(x:0 w:0 w:320 h:168)  icon:"control.cell.brush.png"  }
                elements {
                    fillZero { type:"trigger"  title:"clear 0"  frame:(x:4 y:50 w:44 h:44)  icon:"control.drop.clear.png"  value:(0...1=0) -> sky.cell.rule.zero  }
                    fillOne { type:"trigger"  title:"clear 0xFFFF"  frame:(x:266 y:50 w:44 h:44)  icon:"control.drop.gray.png"  value:(0...1=0) -> sky.cell.rule.one  }
                    palScrub { type:"slider"  title:"Scrub Palette"  frame:(x:64 y:50 w:192 h:44)  value:(0...1=0) <-> sky.draw.brush.index  }
                    brushPress { type:"switch"  title:"Pressure"  frame:(x:10 y:108 w:66 h:44)  icon:"control.pen.press.png"  value:(0...1=0) <->(brushSize.master ? 0 ) <-(brushSize.master ? 0 )  }
                    brushSize { type:"slider"  title:"Size"  frame:(x:86 y:108 w:206 h:44)  value:(0...1) <-> sky.draw.brush.size  master:(0...1)  }
                    brushPress.value:0 <-(brushSize.master ? 0 )  }
                renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
            }
        }
        pal.main {
            base { type:"palette"  title:"Palette"  frame:(x:0 y:0 w:320 h:176)  icon:"control.pal.main.png"  }
            elements {
                ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  icon:"control.pal.main.png"  lag:0  value:0  }
                fillZero { type:"trigger"  title:"fill 0"  frame:(x:10 y:50 w:44 h:44)  icon:"control.drop.clear.png"  value:(0...1=0) -> sky.cell.rule.zero  }
                palFade { type:"slider"  title:"Pal A <-> B"  frame:(x:64 y:50 w:192 h:44)  icon:"control.pearl.white.png"  lag:0.25  value:(0...1=0) <-> sky.pal.change.xfade  }
                fillOne { type:"trigger"  title:"fill 1"  frame:(x:260 y:50 w:44 h:44)  icon:"control.drop.gray.png"  value:(0...1=0) -> sky.cell.rule.one  }
                shiftLeft { type:"trigger"  title:"Shift Left"  frame:(x:10 y:108 w:44 h:44)  icon:"control.arrow.left.png"  value:(0...255=0) -> sky.pal.cycle.inc  }
                palScrub { type:"slider"  title:"Scrub Palette"  frame:(x:64 y:108 w:192 h:44)  icon:"control.cell.brush.png"  value:(0...1=0) <-> sky.draw.brush.index  }
                shiftRight { type:"trigger"  title:"Shift Right"  frame:(x:260 y:108 w:44 h:44)  icon:"control.arrow.right.png"  value:(0...255=0) -> sky.pal.cycle.inc  }
            }
        }
    }
}
"""#
    err += ParStr.testCompare(planned, actual, echo:true)
    //print(actual)
    let d3Script = root.makeD3Script()
    print(d3Script)
    XCTAssertEqual(err,0)
}
#endif
