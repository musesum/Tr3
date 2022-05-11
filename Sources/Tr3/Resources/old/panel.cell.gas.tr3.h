panel.cell.gas: _cell {
    base {
        title "Gas"
        icon "icon.cell.gas.png"
    }
    controls {
        ruleOn.icon "icon.cell.gas.png"
        ruleOn.value >> sky.shader.gas.on
        version.value >> sky.shader.gas.buffer.version
    }
}
