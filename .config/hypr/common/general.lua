hl.config({
  input = {
    -- empty inherits XKB_DEFAULT_LAYOUT (libxkbcommon), falls back to "us"
    kb_layout = "",
    numlock_by_default = true,
    follow_mouse = 0,
  },
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    layout = "dwindle",
  },
  decoration = {
    rounding = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 30,
      render_power = 5,
      offset = "0 0",
      color = "rgba(00000050)",
    },
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
  dwindle = {
    preserve_split = true,
  },
  master = {
    mfact = 0.5,
  },
})
