panel.cell.tunl: _cell {
    base {
        title "Time Tunnel"
        icon "icon.cell.timeTunnel.png"
    }
    controls {
        ruleOn.icon "icon.cell.timeTunnel.png"
        ruleOn.value >> sky.shader.tunl.on
        version.value >> sky.shader.tunl.buffer.version
    }
}
