local M = {}

-- Terminal
M.terminal = "alacritty"

-- Modifier key
M.modkey = "Mod4"

-- Font
M.font = "WenQuanYi Micro Hei 12"

-- Theme
M.theme = "awesome-arc-theme/themes/arc-dark/theme.lua"

-- Textclock
M.textclock = {
    format = "%a %Y/%m/%d %H:%M:%S",
    timezone = "Asia/Shanghai",
}

-- Tags
M.tags = {
    names  = { "Work", "Personal", "Windows" },
    layouts = { "fair", "fair", "max.fullscreen" },
}

-- Layouts (order matters for awful.layout.inc)
M.layouts = {
    "fair",
    "fair.horizontal",
    "max",
}

-- Widget options
M.brightness = {
    tooltip = true,
}

M.volume = {
    mixer_cmd = "pavucontrol",
    device = "hw:1",
    widget_type = "arc",
}

M.batteryarc = {
    show_current_level = true,
    arc_thickness = 2,
}

-- Auto DPI
M.auto_dpi = true

return M
