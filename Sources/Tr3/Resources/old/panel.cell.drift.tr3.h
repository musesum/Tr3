panel.cell.drift: _cell {
    base {
        title "Drift"
        icon "icon.cell.drift.png"
    }
    controls {
        ruleOn.icon "icon.cell.drift.png"
        ruleOn.value >> sky.shader.drift.on
        version.value >> sky.shader.drift.buffer.version
    }
}
