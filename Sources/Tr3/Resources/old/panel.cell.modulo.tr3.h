panel.cell.modulo: _cell {
    base {
        title "Modulo"
        icon "icon.cell.modulo.png"
    }
    controls {
        ruleOn.icon "icon.cell.modulo.png"
        ruleOn.value >> sky.shader.mod.on
        version.value >> sky.shader.mod.buffer.version
    }
}
