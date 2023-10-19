local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

local bar = {}

spacer = wibox.widget.textbox("")
spacer.forced_width = beautiful.useless_gap*2.5

half_spacer = wibox.widget.textbox("")
half_spacer.forced_width = beautiful.useless_gap*1.25

time = wibox.widget{
    {
        {
            helpers.horizontal_pad(20),
            -- {
            --     markup = helpers.colorize_foreground("奦", x.color0..'b0'),
            --     font = beautiful.icon,
            --     widget = wibox.widget.textbox,
            -- },
            -- helpers.horizontal_pad(5),
            {
                format = "%a %b. %d, %I:%M %p",
                widget = wibox.widget.textclock
            },
            helpers.horizontal_pad(20),
            layout = wibox.layout.fixed.horizontal
        },
        bg = beautiful.ui_accent_bg,
        shape = helpers.rrect(beautiful.ui_radius),
        widget = wibox.container.background
    },
    margins = 10,
    widget = wibox.container.margin
}

-- helper function that updates the taglist and sets the icon/color properly depending on the situation
local update_taglist = function (item, tag, index)
    item.font = beautiful.icon_large
    item.forced_width = dpi(25)
    item.halign = "center"
    if tag.selected then
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_focused[index], beautiful.taglist_text_color_focused[index])
    elseif tag.urgent then
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_urgent[index], beautiful.taglist_text_color_urgent[index])
    elseif #tag:clients() > 0 then
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_occupied[index], beautiful.taglist_text_color_occupied[index])
    else
        item.markup = helpers.colorize_foreground(beautiful.taglist_text_empty[index], beautiful.taglist_text_color_empty[index])
    end
end

local recording = wibox.widget{
    font = beautiful.icon,
    markup = helpers.colorize_foreground("苭", x.color1),
    widget = wibox.widget.textbox
}

local recording_cont = wibox.widget{
    recording,
    forced_width = 30,
    widget = wibox.container.place
}

helpers.add_hover_cursor(recording, "hand1")
recording:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("pkill recordmydesktop")
        recording.visible = false
    end)
})
recording.visible = false

awesome.connect_signal("keys::recording", function()
    recording.visible = true
end)

start_width = 400;
local host_text = wibox.widget{
    halign = "left",
    valign = "center",
    font = beautiful.font_mono,
    widget = wibox.widget.textbox
}
awful.spawn.easy_async_with_shell("hostname", function(stdout)
    -- remove the newline at the end of stdout
    stdout = stdout:gsub('^%s*(.-)%s*$', '%1')
    host_text.markup = helpers.colorize_foreground("@"..stdout, x.color8)
end)

local kill_button = wibox.widget{
    {
        text = "湒",
        font = beautiful.icon,
        widget = wibox.widget.textbox
    },
    -- forced_height = 20,
    widget = wibox.container.background
}
kill_button:connect_signal("mouse::enter", function ()
    kill_button.fg = x.color1
end)
kill_button:connect_signal("mouse::leave", function ()
    kill_button.fg = x.foreground
end)

local restart_button = wibox.widget{
    {
        text = "湟",
        font = beautiful.icon,
        widget = wibox.widget.textbox
    },
    -- forced_height = 20,
    widget = wibox.container.background
}
restart_button:connect_signal("mouse::enter", function ()
    restart_button.fg = x.color2
end)
restart_button:connect_signal("mouse::leave", function ()
    restart_button.fg = x.foreground
end)

local logout_button = wibox.widget{
    {
        text = "滃",
        font = beautiful.icon,
        widget = wibox.widget.textbox
    },
    -- forced_height = 20,
    widget = wibox.container.background
}
logout_button:connect_signal("mouse::enter", function ()
    logout_button.fg = x.color3
end)
logout_button:connect_signal("mouse::leave", function ()
    logout_button.fg = x.foreground
end)

local user_widget = wibox.widget{
    {
        {
            {
                {
                    resize = true,
                    upscale = true,
                    downscale = true,
                    image = user.profile,
                    widget = wibox.widget.imagebox
                },
                forced_width = dpi(90),
                forced_height = dpi(90),
                border_width = beautiful.ui_border_width,
                border_color = beautiful.ui_border_color,
                shape = helpers.rrect(beautiful.ui_radius),
                -- shape = helpers.rrect(dpi(3)),
                widget = wibox.container.background
            },
            {
                {
                    {
                        halign = "center",
                        valign = "center",
                        font = beautiful.font_large,
                        -- markup = helpers.colorize_foreground(os.getenv("USER"), x.foreground),
                        markup = os.getenv("USER").."!",
                        widget = wibox.widget.textbox
                    },
                    host_text,
                    {
                        kill_button,
                        restart_button,
                        logout_button,
                        spacing = 10,
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.fixed.vertical
                },
                widget = wibox.container.place
            },
            layout = wibox.layout.align.horizontal
        },
        margins = beautiful.useless_gap,
        widget = wibox.container.margin
    },
    bg = beautiful.ui_accent_bg,
    widget = wibox.container.background,
}

-- mpd widget
local loop_icon = wibox.widget{
    halign = "center",
    valign = "center",
    markup = "剕",
    font = beautiful.icon,
    widget = wibox.widget.textbox
}
local loop_button = wibox.widget{
    loop_icon,
    widget = wibox.container.background
}
local prev_button = wibox.widget{
    {
        halign = "center",
        valign = "center",
        markup = "劭",
        font = beautiful.icon,
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
local play_icon = wibox.widget{
    halign = "center",
    valign = "center",
    markup = "",
    font = beautiful.icon_large,
    widget = wibox.widget.textbox
}
local play_button = wibox.widget{
    {
        valign = "top",
        play_icon,
        widget = wibox.container.place
    },
    forced_height = dpi(37),
    widget = wibox.container.background
}
local next_button = wibox.widget{
    {
        halign = "center",
        valign = "center",
        markup = "劬",
        font = beautiful.icon,
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
local random_icon = wibox.widget{
    halign = "center",
    valign = "center",
    markup = "劜",
    font = beautiful.icon,
    widget = wibox.widget.textbox
}
local random_button = wibox.widget{
    random_icon,
    widget = wibox.container.background
}
helpers.add_hover_cursor(loop_button, "hand1")
loop_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc repeat")
    end)
})
helpers.add_hover_cursor(play_button, "hand1")
play_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc toggle")
    end)
})
helpers.add_hover_cursor(prev_button, "hand1")
prev_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc prev")
    end)
})
helpers.add_hover_cursor(next_button, "hand1")
next_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc next")
    end)
})
helpers.add_hover_cursor(random_button, "hand1")
random_button:buttons({
    awful.button({}, 1, function()
        awful.spawn.with_shell("mpc random")
    end)
})

local album_art = wibox.widget{
    -- forced_width = 120,
    -- forced_height = 120,
    widget = wibox.widget.imagebox
}
local mpd_title = wibox.widget{
    markup = "---------",
    halign = "center",
    valign = "center",
    font = beautiful.font,
    -- forced_width = dpi(350),
    forced_height = dpi(25),
    widget = wibox.widget.textbox
}
local mpd_artist = wibox.widget{
    markup = helpers.colorize_foreground("---------", x.color8),
    halign = "center",
    valign = "center",
    forced_height = dpi(15),
    font = beautiful.font_small,
    widget = wibox.widget.textbox
}

local mpd_widget = wibox.widget{
    {
        {
            {
                {
                    {
                        album_art,
                        forced_width = dpi(90),
                        forced_height = dpi(90),
                        border_width = beautiful.ui_border_width,
                        border_color = beautiful.ui_border_color,
                        shape = helpers.rrect(beautiful.ui_radius),
                        -- shape = helpers.rrect(dpi(3)),
                        widget = wibox.container.background
                    },
                    widget = wibox.container.place
                },
                {
                    {
                        {
                            {
                                mpd_title,
                                mpd_artist,
                                -- forced_width = dpi(100),
                                layout = wibox.layout.fixed.vertical
                            },
                            widget = wibox.container.place
                        },
                        {
                            {
                                loop_button,
                                prev_button,
                                play_button,
                                next_button,
                                random_button,
                                spacing = dpi(10),
                                layout = wibox.layout.fixed.horizontal
                            },
                            widget = wibox.container.place,
                        },
                        forced_width = 175,
                        layout = wibox.layout.fixed.vertical
                    },
                    widget = wibox.container.place
                },
                layout = wibox.layout.align.horizontal
            },
            margins = beautiful.useless_gap,
            widget = wibox.container.margin
        },
        bg = beautiful.ui_accent_bg,
        shape = helpers.rrect(beautiful.ui_radius),
        forced_height = 150,
        widget = wibox.container.background
    },
    margins = beautiful.useless_gap,
    widget = wibox.container.margin
}

awesome.connect_signal("meow::mpd", function(artist, title, status, albumart)
    print(artist, title, status, albumart)
    if status == true then
        print("changing status")
        play_icon.markup = "刉"
        play_icon:emit_signal("widget::redraw_needed")
    else
        play_icon.markup = "凣"
    end

    -- escape & in title and artist
    title = string.gsub(title, "&", "&amp;")
    artist = string.gsub(artist, "&", "&amp;")

    mpd_title.markup = title
    mpd_artist.markup = helpers.colorize_foreground(artist, x.foreground)

    album_art.image = albumart
    mpd_widget:emit_signal("widget::redraw_needed")
end)

awesome.connect_signal("meow::mpd_options", function(loop, random)
    if loop == true then
        loop_button.fg = "#ffffff"
    else
        loop_button.fg = x.color0
    end
    if random == true then
        random_button.fg = "#ffffff"
    else
        random_button.fg = x.color0
    end
    mpd_widget:emit_signal("widget::redraw_needed")
end)

month_offset = 0

local styles = {}
styles.month = {
    padding = 10,
    fg_color = x.color8,
    bg_color = x.background.."00",
    border_width = 0
}
styles.normal = {
    
}
styles.focus = {
    fg_color = x.color3,
    bg_color = x.color5.."00",
    markup = function(t) return '<b>' .. t .. '</b>' end
}
styles.header = {
    fg_color = x.foreground,
    bg_color = x.color1.."a0",
    markup = function(t) return '<span font_desc="' .. beautiful.font_large .. '"><b>' .. t .. '</b></span>' end
}
styles.weekday = {
    fg_color = x.foreground,
    bg_color = x.color1.."00",
    padding = 2,
    markup = function(t) return '<b>' .. t .. '</b>' end
}

local function decorate_cell(widget, flag, date)
    if flag == 'monthheader' and not styles.monthheader then
        flag = 'header'
    end
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end
    -- color change weekends
    local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
    local weekday = tonumber(os.date('%w', os.time(d)))
    local default_fg = x.foreground
    local default_bg = x.color0.."00"
    -- local default_bg = (weekday==0 or weekday==6) and x.color6 or x.color14
    local ret = wibox.widget{
        {
            widget,
            margins = (props.padding or 2) + (props.border_width or 0),
            widget = wibox.container.margin
        },
        shape = props.shape,
        shape_border_color = props.border_color or x.background,
        shape_border_width = props.border_width or 0,
        fg = props.fg_color or default_fg,
        bg = props.bg_color or default_bg,
        widget = wibox.container.background
    }
    return ret
end

local calendar = wibox.widget{
    date = os.date("*t"),
    font = beautiful.font,
    spacing = 3,
    fn_embed = decorate_cell,
    forced_height = dpi(300),
    widget = wibox.widget.calendar.month
}

local prev_month = wibox.widget{
    {
        halign = "right",
        markup = "佀",
        font = beautiful.icon_large,
        forced_width = dpi(30),
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
local current_month = wibox.widget{
    widget = wibox.container.background
}
local next_month = wibox.widget{
    {
        halign = "left",
        markup = "佁",
        font = beautiful.icon_large,
        forced_width = dpi(30),
        widget = wibox.widget.textbox
    },
    widget = wibox.container.background
}
local calendar_widget = wibox.widget{
    {
        {
            {
                {
                    calendar,
                    forced_height = dpi(320),
                    valign = "middle",
                    widget = wibox.container.place
                },
                {
                    helpers.vertical_pad(18),
                    {
                        prev_month,
                        current_month,
                        next_month,
                        layout = wibox.layout.align.horizontal
                    },
                    layout = wibox.layout.fixed.vertical
                },
                forced_height = dpi(320),
                layout = wibox.layout.stack
            },
            widget = wibox.container.place,
        },
        shape = helpers.rrect(beautiful.ui_radius),
        bg = beautiful.ui_accent_bg,
        widget = wibox.container.background
    },
    margins = {top = 0, left = beautiful.useless_gap, right = beautiful.useless_gap, bottom = beautiful.useless_gap},
    widget = wibox.container.margin
}

local function update_calendar()
    local d = os.date("*t")
    d.month = d.month+month_offset
    while d.month <= 0 do
        d.month = d.month+12
        d.year = d.year-1
    end
    while d.month > 12 do
        d.month = d.month-12
        d.year = d.year+1
    end
    -- disable day showing if showing a different month
    if month_offset ~= 0 then
        d.day = -1
    end
    calendar.date = d
end
helpers.add_hover_cursor(prev_month, "hand1")
prev_month:buttons({
    awful.button({}, 1, function()
        month_offset = month_offset-1
        update_calendar()
    end)
})
helpers.add_hover_cursor(current_month, "hand1")
current_month:buttons({
    awful.button({}, 1, function()
        month_offset = 0
        update_calendar()
    end)
})
helpers.add_hover_cursor(next_month, "hand1")
next_month:buttons({
    awful.button({}, 1, function()
        month_offset = month_offset+1
        update_calendar()
    end)
})

local battery_display = wibox.widget{
    max_value = 100,
    value = 50,
    forced_height = dpi(30),
    forced_width = dpi(80),
    shape = helpers.rrect(beautiful.ui_radius),
    background_color = beautiful.battery_bar_active_background_color,
    color = beautiful.battery_bar_active_color,
    widget = wibox.widget.progressbar
}
local battery_hover_text_value = wibox.widget{
    halign = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local battery_hover_text_wrapper = wibox.widget{
    fg = x.foreground,
    battery_hover_text_value,
    widget = wibox.container.background
}

local battery_hover_text = wibox.widget{
    battery_hover_text_wrapper,
    spacing = dpi(2),
    visible = true,
    layout = wibox.layout.fixed.vertical
}

awesome.connect_signal("meow::battery", function(value)
    battery_display.value = value
    battery_hover_text_value.markup = tostring(value).."%"
end)

local battery_icon = wibox.widget{
    halign = "center",
    valign = "center",
    font = beautiful.icon_extra_large,
    markup = helpers.colorize_foreground("戊", x.foreground),
    widget = wibox.widget.textbox
}

awesome.connect_signal("meow::battery_charging", function(plugged)
    if plugged then
        battery_display.background_color = beautiful.battery_bar_charging_background_color
        battery_display.color = beautiful.battery_bar_charging_color
        -- battery_hover_text_wrapper.fg = beautiful.battery_bar_charging_color
    else
        battery_display.background_color = beautiful.battery_bar_active_background_color
        battery_display.color = beautiful.battery_bar_active_color
        -- battery_hover_text_wrapper.fg = x.foreground
    end
end)

local battery_widget = wibox.widget{
    {
        {
            battery_display,
            height = 20,
            width = 100,
            widget = wibox.container.constraint
        },
        {
            nil,
            battery_hover_text,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        -- battery_icon,
        top_only = false,
        layout = wibox.layout.stack
    },
    margins = {top = 10, bottom = 10},
    widget = wibox.container.margin
}

awful.screen.connect_for_each_screen(function(s)
    s.taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        widget_template = {
            widget = wibox.widget.textbox,
            create_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
            update_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
        }
    }

    s.bar = awful.wibar{
        type = "dock",
        screen = s,
        ontop = true,
        restrict_workarea = true,
        position = beautiful.bar_position,
        height = beautiful.bar_height,
        bg = beautiful.bar_bg,
        border_color = beautiful.border_color_active,
        border_width = beautiful.border_width,
        margins = {left = -beautiful.border_width, top = -beautiful.border_width, right = -beautiful.border_width, bottom = 0}
    }

    s.bar:setup{
        {
            {
                {
                    {
                        forced_width = dpi(40),
                        clip_shape = gears.shape.circle,
                        image = user.profile,
                        widget = wibox.widget.imagebox
                    },
                    widget = wibox.container.place
                },
                left = dpi(20),
                right = dpi(10),
                widget = wibox.container.margin
            },
            s.taglist,
            layout = wibox.layout.fixed.horizontal
        },
        {
            -- s.taglist,
            widget = wibox.container.place
        },
        {
            battery_widget,
            time,
            recording_cont,
            half_spacer,
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }

    s.start = wibox{
        border_color = beautiful.ui_border_color,
        border_width = beautiful.ui_border_width,
        bg = beautiful.ui_bg,
        width = start_width,
        height = 680,
        visible = false,
        ontop = true,
        screen = s
    }
    
    awful.placement.top_left(s.start, {honor_workarea=true})
    s.start.x = s.start.x + beautiful.useless_gap/2
    s.start.y = s.start.y + beautiful.useless_gap/2

    s.start:setup{
        user_widget,
        mpd_widget,
        calendar_widget,
        layout = wibox.layout.fixed.vertical,
    }
end)

local function ensure_fullscreen_above_bar(c)
    local s = awful.screen.focused()
    if c.fullscreen then
        s.bar.ontop = false
    else
        s.bar.ontop = true
    end
end

client.connect_signal("focus", ensure_fullscreen_above_bar)
client.connect_signal("unfocus", ensure_fullscreen_above_bar)
client.connect_signal("property::fullscreen", ensure_fullscreen_above_bar)

function start_toggle()
    for s in screen do
        s.start.visible = not s.start.visible
    end
    update_calendar()
end

bar.start_grabber = awful.keygrabber{
    stop_key = {"Escape", "q", "F1"},
    stop_event = "press",
    start_callback = start_toggle,
    stop_callback = start_toggle,
}

return bar