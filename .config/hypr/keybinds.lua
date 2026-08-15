local config = require("config")

hl.bind(config.mainMod .. " + Q", hl.dsp.exec_cmd(config.terminal))
local closeWindowBind = hl.bind(config.mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(config.mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(config.mainMod .. " + E", hl.dsp.exec_cmd(config.fileManager))
hl.bind(config.mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(config.mainMod .. " + R", hl.dsp.exec_cmd(config.menu))
hl.bind(config.mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(config.mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(config.mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(config.mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(config.mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(config.mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(config.mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(config.mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(config.mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(config.mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(config.mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(config.mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(config.mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(config.mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


hl.bind(config.mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
