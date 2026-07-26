local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local config = require("config")

local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")

local M = {}

-- Layout name-to-object mapping
local layout_map = {
    ["fair"] = awful.layout.suit.fair,
    ["fair.horizontal"] = awful.layout.suit.fair.horizontal,
    ["max"] = awful.layout.suit.max,
    ["max.fullscreen"] = awful.layout.suit.max.fullscreen,
}

-- {{{ Wallpaper
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)
-- }}}

-- {{{ Taglist buttons
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t)
        i = t:get_index()
        for screen = 1, screen.count() do
            local tag = awful.tag.gettags(screen)[i]
            tag:view_only()
        end
    end),
    awful.button({ config.modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ config.modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)
-- }}}

-- {{{ Tasklist buttons
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),
    awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)
-- }}}

-- {{{ Textclock
local mytextclock = wibox.widget.textclock(
    config.textclock.format,
    1,
    config.textclock.timezone
)
-- }}}

-- {{{ Per-screen setup
function M.setup(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Tags
    local names = config.tags.names
    local layouts = {}
    for _, name in ipairs(config.tags.layouts) do
        layouts[#layouts + 1] = layout_map[name]
    end
    awful.tag(names, s, layouts)

    -- Promptbox
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))

    -- Taglist
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Tasklist
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Wibar
    s.mywibox = awful.wibar({ position = "top", screen = s })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            brightness_widget{
                tooltip = config.brightness.tooltip,
            },
            volume_widget{
                mixer_cmd = config.volume.mixer_cmd,
                device = config.volume.device,
                widget_type = config.volume.widget_type,
            },
            batteryarc_widget{
                show_current_level = config.batteryarc.show_current_level,
                arc_thickness = config.batteryarc.arc_thickness,
            },
            mytextclock,
        },
    }
end
-- }}}

return M
