-- launcher app, lifted heavily from https://github.com/nwdamgaard/

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local menubar = require("menubar")
local wibox = require("wibox")

local helpers = require("helpers")
local schema_helpers = require("schema.schema_helpers")

local MAX_DISPLAYED = 8
local PROGRAM_HEIGHT = 60
local TOTAL_HEIGHT = MAX_DISPLAYED*PROGRAM_HEIGHT

launcher = wibox{
    bg = beautiful.ui_cover_bg,
    visible = false,
    ontop = true,
    type = "dock",
    screen = screen.primary
}
awful.placement.maximize(launcher, {honor_workarea=true})

awful.screen.connect_for_each_screen(function(s)
    if s == screen.primary then 
        s.launcher = launcher
    else
        s.launcher = wibox{
            bg = beautiful.ui_cover_bg,
            visible = false,
            ontop = true,
            type = "splash",
            screen = s
        }
        awful.placement.maximize(s.launcher, {honor_workarea=true})
    end
end)

local programs = {}
local programs_widget = wibox.widget{
    -- fill_space = true,
    layout = wibox.layout.fixed.vertical
}
local programs_name_list = {}
local programs_desc_list = {}
local programs_box = helpers.package(programs_widget, dpi(400), dpi(TOTAL_HEIGHT), beautiful.ui_bg, 0)
programs_box.children[1].shape = helpers.prrect(beautiful.ui_radius, false, false, true, true)
programs_box.margins = {top=dpi(-beautiful.ui_border_width), left=0, right=0, down=0}
awful.spawn.with_line_callback([[ bash -c "find ]]..user.dirs.desktop..[[ -type f -name '*.desktop'"]], {
-- awful.spawn.with_line_callback([[ bash -c "find /usr/share/applications -type f -name '*.desktop'"]], {
    stdout = function(line)
        local program = menubar.utils.parse_desktop_file(line)
        if not program.Comment then
            program.Comment = "An application that hasn't included a description"
        end
        program.Name = string.gsub(program.Name, "&", "&amp;")
        program.Comment = string.gsub(program.Comment, "&", "&amp;")
        if not program.Keywords then
            program.Keywords = ""
        else
            local kws = ""
            for _, kw in pairs(program.Keywords) do
                kws = kws..kw
            end
            program.Keywords = kws
        end
        table.insert(programs, program)
    end,
    output_done = function()
        table.sort(programs, function(x, y)
            return y.Name > x.Name
        end)
        programs_box.children[1].forced_height = dpi(TOTAL_HEIGHT)
        for _, program in pairs(programs) do
            local name_text = wibox.widget{
                markup = program.Name,
                widget = wibox.widget.textbox,
            }
            local desc_text = wibox.widget{
                markup = program.Comment,
                font = beautiful.font_small,
                widget = wibox.widget.textbox
            }
            local program_widget = wibox.widget{
                {
                    helpers.horizontal_pad(10),
                    {
                        {
                            halign = "center",
                            valign = "center",
                            image = program.icon_path,
                            forced_width = dpi(24),
                            forced_height = dpi(24),
                            widget = wibox.widget.imagebox
                        },
                        forced_height = dpi(PROGRAM_HEIGHT),
                        widget = wibox.container.background
                    },
                    helpers.horizontal_pad(10),
                    {
                        {
                            name_text,
                            {
                                desc_text,
                                fg = x.foreground,
                                layout = wibox.container.background
                            },
                            layout = wibox.layout.fixed.vertical
                        },
                        valign = "center",
                        widget = wibox.container.place
                    },
                    forced_height = dpi(PROGRAM_HEIGHT),
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.ui_bg,
                forced_width = dpi(400),
                name = program.Name,
                exec = program.cmdline or "",
                widget = wibox.container.background
            }
            table.insert(programs_name_list, name_text)
            table.insert(programs_desc_list, desc_text)
            programs_widget:add(program_widget)
        end
    end
})

local scroll = 0
local hovered = 1
local hovered_position = 0
local visible_count = 0
local search_results = {}
local last_hovered = ""

function scroll_programs(direction)
    if #search_results == 0 then
        return
    end
    
    if direction == "Up" and hovered > 1 then
        hovered = hovered - 1
    elseif direction == "Down" and hovered < #search_results then
        hovered = hovered + 1
    end
    if hovered > #search_results then
        hovered = #search_results
    end

    if scroll+MAX_DISPLAYED > #search_results then
        scroll = #search_results - MAX_DISPLAYED
    end
    if hovered > scroll+MAX_DISPLAYED then
        scroll = hovered - MAX_DISPLAYED
    end
    if hovered <= scroll then
        scroll = hovered - 1
    end

    for i, program_widget in pairs(search_results) do
        program_widget.visible = true
        program_widget.bg = beautiful.ui_bg
        if i <= scroll then
            program_widget.visible = false
        end
        if i == hovered then
            program_widget.bg = beautiful.ui_light_bg
            last_hovered = program_widget.name
        end
    end
end

function search_programs(search)
    search = string.gsub(search:lower(), "&", "&amp;")
    
    visible_count = 0
    hovered_position = 0
    search_results = {}
    -- enable or disable description and tag searching by commenting/uncommenting relevant lines
    for i, program in pairs(programs) do
        local ind = program.Name:lower():find(search)
        programs_widget.children[i].bg = beautiful.ui_bg
        programs_widget.children[i].visible = false
        programs_name_list[i].markup = program.Name
        -- comment here
        -- local cind = program.Comment:lower():find(search)
        local kind = program.Keywords:lower():find(search)
        programs_desc_list[i].markup = program.Comment
        if ind or cind or kind then
            visible_count = visible_count+1
            programs_widget.children[i].visible = true
            table.insert(search_results, programs_widget.children[i])
            if ind then
                programs_name_list[i].markup = string.sub(program.Name, 0, ind-1)..helpers.colorize_foreground(string.sub(program.Name, ind, ind+search:wlen()-1), x.color1)..string.sub(program.Name, ind+search:wlen(), program.Name:wlen())
            end
            if program.Name == last_hovered then
                hovered = visible_count
            end
            -- comment here
            -- if cind then
            --     programs_desc_list[i].markup = string.sub(program.Comment, 0, cind-1)..helpers.colorize_foreground(string.sub(program.Comment, cind, cind+search:wlen()-1), x.color1)..string.sub(program.Comment, cind+search:wlen(), program.Comment:wlen())
            -- end
        end
    end
    programs_box.children[1].forced_height = dpi(math.min(visible_count, MAX_DISPLAYED)*PROGRAM_HEIGHT)
    if visible_count == 0 then
        programs_box.visible = false
    else
        programs_box.visible = true
    end
    scroll_programs()
end

local search_text = wibox.widget{
    text = "",
    font = beautiful.font,
    widget = wibox.widget.textbox
}
blinker = wibox.widget{
    text = "埝",
    font = beautiful.icon_small,
    widget = wibox.widget.textbox
}
local blinker_timer = gears.timer{
    timeout = 1,
    autostart = true,
    callback = function()
        blinker.visible = not blinker.visible
    end
}
local search_widget = wibox.widget{
    {
        search_text,
        fg = x.foreground,
        widget = wibox.container.background
    },
    {
        blinker,
        fg = x.foreground,
        forced_height = dpi(15),
        forced_width = dpi(15),
        widget = wibox.container.background
    },
    forced_width = dpi(380),
    layout = wibox.layout.fixed.horizontal
}

local search_box = schema_helpers.package(search_widget, dpi(400), dpi(80), beautiful.ui_bg, 0, "launcher")
search_box.children[1].shape = helpers.prrect(beautiful.ui_radius, true, true, false, false)

launcher:setup{
    {
        search_box,
        {
            valign = "top",
            programs_box,
            forced_height = dpi(TOTAL_HEIGHT),
            widget = wibox.container.place
        },
        layout = wibox.layout.fixed.vertical
    },
    halign = "center",
    valign = "center",
    widget = wibox.container.place
}

function launcher_show()
    search_text.text = ""
    scroll = 0
    hovered = 1
    last_hovered = ""
    search_programs("")
    for s in screen do
        s.launcher.visible = true
    end
end

function launcher_hide()
    for s in screen do
        s.launcher.visible = false
    end
end

function execute_hovered()
    awful.spawn(search_results[hovered].exec)
end

launcher.launcher_grabber = awful.keygrabber{
    stop_key = "Escape",
    stop_event = "press",
    start_callback = launcher_show,
    stop_callback = launcher_hide,
    keypressed_callback = function(self, modifiers, key, _)
        if key == "BackSpace" then
            search_text.text = string.sub(search_text.text, 0, search_text.text:wlen()-1)
            search_programs(search_text.text)
        elseif key == "Up" or key == "Down" then
            scroll_programs(key)
        elseif key == "Return" then
            execute_hovered()
            self:stop()
        elseif key:wlen() == 1 then
            search_text.text = search_text.text..key
            search_programs(search_text.text)
        end
        blinker.visible = true
        blinker_timer:stop()
        blinker_timer:start()
    end
}

return launcher