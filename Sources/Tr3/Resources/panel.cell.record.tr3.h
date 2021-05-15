panel.cell.record: _cell {
    base {
        type "record"
        title "Record"
        icon "icon.record.png"
    }
    controls {
        ruleOn.icon "icon.record.png"
        ruleOn.value >> sky.shader.cellRecord.on
        version.value (0..1 = 0.5) >> sky.shader.record.buffer.version
        bitplane.value (0..1 = 0.2)
        lock {
            icon "icon.camera.flip.png"
            value >> sky.shader.record.flip
        }
    }
}
