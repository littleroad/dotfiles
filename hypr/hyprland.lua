-- ============================================================
-- Hyprland Lua Config
-- ============================================================

-- ---- Environment Variables -------------------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")

-- Input Method — Rime via Fcitx5
-- GTK_IM_MODULE intentionally unset — Wayland native protocol handles it
hl.env("QT_IM_MODULE", "fcitx")

-- QT Wayland
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- GDK / GTK
hl.env("GDK_BACKEND", "wayland,x11")

-- Native Wayland for Electron apps (Chrome, etc.)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("NIXOS_OZONE_WL", "1")


-- ---- Monitor ----------------------------------------------------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-- ---- Autostart --------------------------------------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaybg -i ~/.config/hypr/wallpaper.jpg -m fill")
    -- hl.exec_cmd("nm-applet --indicator")  -- Removed: uses systemd-networkd, not NetworkManager
    hl.exec_cmd("nextcloud")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("cliphist store")
    hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
end)


-- ---- Input ------------------------------------------------------------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        repeat_rate  = 40,
        repeat_delay = 250,

        accel_profile = "flat",
        sensitivity   = 0,

        touchpad = {
            natural_scroll        = true,
            tap_to_click          = true,
            tap_and_drag          = false,
            disable_while_typing  = true,
            middle_button_emulation = false,
        },
    },
})


-- ---- General / Look and Feel -----------------------------------------------

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(7fbbbcee)", "rgba(5e81acee)" }, angle = 45 },
            inactive_border = "rgba(4c566a88)",
        },

        resize_on_border       = true,
        extend_border_grab_area = 15,
        hover_icon_on_border   = true,

        allow_tearing = false,

        layout = "dwindle",
    },
})


-- ---- Decoration -------------------------------------------------------------

hl.config({
    decoration = {
        rounding = 8,

        shadow = {
            enabled      = true,
            range        = 6,
            render_power = 2,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            ignore_opacity    = false,
            noise             = 0.01,
            contrast          = 0.9,
            brightness        = 0.9,
            vibrancy          = 0.2,
            popups            = true,
            popups_ignorealpha = 0.2,
        },
    },
})


-- ---- Animations -------------------------------------------------------------

hl.curve("wind",   { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05}  } })
hl.curve("winIn",  { type = "bezier", points = { {0.1, 1.0},  {0.1, 1.1}   } })
hl.curve("winOut", { type = "bezier", points = { {0.0, 0.0},  {0.2, 1.0}   } })
hl.curve("liner",  { type = "bezier", points = { {1.0, 1.0},  {1.0, 1.0}   } })

hl.animation({ leaf = "global",          enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "windows",         enabled = true, speed = 6, bezier = "wind",  style = "slide" })
hl.animation({ leaf = "windowsIn",       enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut",      enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove",     enabled = true, speed = 5, bezier = "wind",  style = "slide" })
hl.animation({ leaf = "fade",            enabled = true, speed = 4, bezier = "liner" })
hl.animation({ leaf = "fadeDim",         enabled = true, speed = 5, bezier = "liner" })
hl.animation({ leaf = "workspaces",      enabled = true, speed = 4, bezier = "liner" })
hl.animation({ leaf = "border",          enabled = true, speed = 5, bezier = "liner" })


-- ---- Layouts ----------------------------------------------------------------

hl.config({
    dwindle = {
        preserve_split         = true,
        force_split            = 0,
        special_scale_factor   = 0.8,
        split_width_multiplier = 1.0,
        smart_split            = false,
        smart_resizing         = true,
    },
})

hl.config({
    master = {
        allow_small_split    = true,
        always_keep_position = true,
        orientation          = "left",
        mfact                = 0.55,
        new_status           = "master",
        smart_resizing       = true,
        drop_at_cursor       = true,
    },
})


-- ---- Window Rules -----------------------------------------------------------

hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "pavucontrol" },
    float = true,
})
hl.window_rule({
    name  = "float-nm-connection-editor",
    match = { class = "nm-connection-editor" },
    float = true,
})
hl.window_rule({
    name  = "float-blueman-manager",
    match = { class = "blueman-manager" },
    float = true,
})
hl.window_rule({
    name  = "float-pip",
    match = { title = "Picture-in-Picture" },
    float = true,
})
hl.window_rule({
    name  = "float-firefox-sharing",
    match = { title = "Firefox — Sharing Indicator" },
    float = true,
})
hl.window_rule({
    name  = "opacity-alacritty",
    match = { class = "Alacritty" },
    opacity = 0.95,
})
hl.window_rule({
    name  = "opacity-firefox",
    match = { class = "firefox" },
    opacity = 0.95,
})
hl.window_rule({
    name  = "workspace1-alacritty",
    match = { class = "Alacritty" },
    workspace = 1,
})
hl.window_rule({
    name  = "workspace2-firefox",
    match = { class = "firefox" },
    workspace = 2,
})
hl.window_rule({
    name  = "workspace3-chrome",
    match = { class = "google-chrome-canary" },
    workspace = 3,
})
hl.window_rule({
    name  = "workspace5-telegram",
    match = { class = "Telegram" },
    workspace = 5,
})
hl.window_rule({
    name  = "workspace6-keepassxc",
    match = { class = "org.keepassxc.KeePassXC" },
    workspace = 6,
})
hl.window_rule({
    name  = "workspace7-nautilus",
    match = { class = "org.gnome.Nautilus" },
    workspace = 7,
})
hl.window_rule({
    name  = "workspace7-pcmanfm",
    match = { class = "pcmanfm" },
    workspace = 7,
})
hl.window_rule({
    name  = "workspace8-software",
    match = { class = "org.gnome.Software|pamac-manager" },
    workspace = 8,
})
hl.window_rule({
    name  = "noblur-swaybg",
    match = { class = "swaybg" },
    no_blur = true,
})
hl.window_rule({
    name  = "noblur-waybar",
    match = { class = "waybar" },
    no_blur = true,
})


-- ---- Keybindings ------------------------------------------------------------

local M = "SUPER"

-- Terminal / Launcher
hl.bind(M .. " + T", hl.dsp.exec_cmd("alacritty"))
hl.bind(M .. " + W", hl.dsp.exec_cmd("google-chrome-canary"))
hl.bind(M .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(M .. " + D", hl.dsp.exec_cmd("wofi --show drun"))

-- Screenshots
hl.bind(M .. " + A",             hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(M .. " + SHIFT + A",      hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(M .. " + CTRL + A",       hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("Print",           hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(M .. " + Print",   hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(M .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))

-- Clipboard manager
hl.bind(M .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- Lock screen
hl.bind(M .. " + L",               hl.dsp.exec_cmd("swaylock"))

-- Close window / Exit Hyprland
hl.bind(M .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(M .. " + SHIFT + Q", hl.dsp.exit())

-- Fullscreen / Toggle float / Pseudo / Cycle next / Minimize
hl.bind(M .. " + F",     hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(M .. " + CTRL + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + P",     hl.dsp.window.pseudo())
hl.bind(M .. " + Tab",   hl.dsp.window.cycle_next())
hl.bind(M .. " + N",     hl.dsp.window.set_prop({ prop = "minimized", value = "true" }))
hl.bind(M .. " + CTRL + N", hl.dsp.exec_cmd("hyprctl dispatch focusurgentorlast"))

-- Resize submap
hl.bind(M .. " + R", hl.dsp.submap("resize"))

-- Reload Hyprland
hl.bind(M .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Focus (HJKL)
hl.bind(M .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(M .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(M .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(M .. " + L", hl.dsp.focus({ direction = "right" }))

-- Focus screen (Ctrl + JK)
hl.bind(M .. " + CTRL + J", hl.dsp.focus({ monitor = "e+1" }))
hl.bind(M .. " + CTRL + K", hl.dsp.focus({ monitor = "e-1" }))

-- Move windows (Shift + HJKL)
hl.bind(M .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(M .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(M .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(M .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Move window to other screen
hl.bind(M .. " + O", hl.dsp.window.move({ monitor = "e+1" }))

-- Workspace switching (1-9)
for i = 1, 9 do
    hl.bind(M .. " + " .. i,              hl.dsp.focus({ workspace = i }))
    hl.bind(M .. " + SHIFT + " .. i,      hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
hl.bind(M .. " + S",         hl.dsp.workspace.toggle_special())
hl.bind(M .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Screenshot key
hl.bind("XF86Search", hl.dsp.exec_cmd("wofi --show drun"))

-- Monitor configuration
hl.bind(M .. " + P", hl.dsp.exec_cmd("wdisplays"))


-- ---- Resize Submap ----------------------------------------------------------

hl.define_submap("resize", function()
    hl.bind("left",   hl.dsp.window.resize({ x = -10, y = 0 }))
    hl.bind("right",  hl.dsp.window.resize({ x = 10,  y = 0 }))
    hl.bind("up",     hl.dsp.window.resize({ x = 0,   y = -10 }))
    hl.bind("down",   hl.dsp.window.resize({ x = 0,   y = 10 }))
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)


-- ---- Misc -------------------------------------------------------------------

hl.config({
    misc = {
        disable_autoreload  = true,
        enable_swallow      = true,
        swallow_regex       = "^(Alacritty)$",
        focus_on_activate   = true,
        animate_manual_resizes = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },
})


-- ---- XWayland ---------------------------------------------------------------

hl.config({
    xwayland = {
        enabled = true,
    },
})


-- ---- Gestures ---------------------------------------------------------------

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


-- ---- Cursor -----------------------------------------------------------------

hl.config({
    cursor = {
        inactive_timeout = 3,
    },
})