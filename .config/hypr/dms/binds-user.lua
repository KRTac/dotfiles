-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + T")
hl.bind("SUPER + T", hl.dsp.exec_cmd("ghostty"), { description = "Ghostty Terminal" })

hl.unbind("SUPER + E")
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"), { description = "Nautilus File Manager" })
