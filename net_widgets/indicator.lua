local wibox         = require("wibox")
local awful         = require("awful")
local shell        = require("awful.util").shell
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local module_path = (...):match ("(.+/)[^/]+$") or ""
local timer = require("gears").timer
local lain = require("lain")
local helpers = require("lain.helpers")

local indicator = {}
local function worker(args)
    local args = args or {}
    local widget = wibox.widget.imagebox()

    -- Settings
    local interfaces    = args.interfaces or {"enp2s0"}
    local ICON_DIR      = awful.util.getdir("config").."/"..module_path.."/net_widgets/icons/"
    local timeout       = args.timeout or 5
    local font          = args.font or beautiful.font
    local onclick       = args.onclick 
    local settings	= args.settings

    local connected = false
    local function text_grabber()
        local msg = ""
        if connected then
            for _, i in pairs(interfaces) do
                
                local map  = "N/A"
                local inet = "N/A"
                f = io.popen("ip addr show "..i)
                for line in f:lines() do
                    -- inet 192.168.1.190/24 brd 192.168.1.255 scope global enp3s0
                    inet = string.match(line, "inet (%d+%.%d+%.%d+%.%d+)") or inet
                    -- link/ether 1c:6f:65:3f:48:9a brd ff:ff:ff:ff:ff:ff
                    mac  = string.match(line, "link/ether (%x?%x?:%x?%x?:%x?%x?:%x?%x?:%x?%x?:%x?%x?)") or mac
                end
                f:close()
                
                msg =   "<span font_desc=\""..font.."\">"..
                        "┌["..i.."]\n"..
                        "├IP:\t"..inet.."\n"..
                        "└MAC:\t"..mac.."</span>"
            end
        else
            msg = "<span font_desc=\""..font.."\">Wired network is disconnected</span>"
        end
	if settings then
		settings({
			signal_level = signal_level,
			connected = connected,
			ICON_DIR      = ICON_DIR,
			interface     = interface,
			timeout       = timeout,   
			font          = font,
			popup_signal  = popup_signal,
			onclick       = onclick, 
			widget 	  = widget,
			indent 	  = indent,	  
		})
	end

        return msg
    end

    widget:set_image(ICON_DIR.."wired_na.png")
    --local function net_update()
	    --print("wired_update",10)
        --connected = false
        --for _, i in pairs(interfaces) do
		--print(connected,10)
		--helpers.async({ shell, "-c", "ip link show "..i.." | awk 'NR==1 {printf \"%s\", $9}'" }, function(f)
			--state = f
			----print("async update wired "..state,10)
			--print(widget)
			--if (state == "UP") then
				--connected = true
			--end
			--if connected then
				--widget:set_image(ICON_DIR.."wired.png")
			--else
				--widget:set_image(ICON_DIR.."wired_na.png")
			--end
		--end)
        --end
    --end

    --net_update()
    local watch = lain.widget.watch({
	    timeout = timeout,
	    stoppable = true,
	    watch = {widget = widget},
	    --cmd = { awful.util.shell, "-c", string.format("ls -1dr %s/INBOX/new/*", mailpath) },
	    cmd = { awful.util.shell, "-c", "ip link show "..interfaces[1].." | awk 'NR==1 {printf \"%s\", $9}'" },
	    settings = function()
		    widget.connected = false
		    if string.match(output, "UP") then
			    widget.connected = true
		    end
		    if widget.connected then
			    widget:set_image(ICON_DIR.."wired.png")
		    else
			    widget:set_image(ICON_DIR.."wired_na.png")
		    end
	    end
    })

    --local net_timer = timer({ timeout = timeout })
    --net_timer:connect_signal("timeout", net_update)
    --net_timer:start()

    local notification = nil
    function widget:hide()
        if notification ~= nil then
            naughty.destroy(notification)
            notification = nil
        end
    end

    function widget:show(t_out)
        widget:hide()

        notification = naughty.notify({
            preset = fs_notification_preset,
            text = text_grabber(),
            timeout = t_out,
	    screen = mouse.screen,
        })
    end

    -- Bind onclick event function
    if onclick then
        widget:buttons(awful.util.table.join(
            awful.button({}, 1, function() awful.util.spawn(onclick) end)
        ))
    end
    
    widget:connect_signal('mouse::enter', function () widget:show(0) end)
    widget:connect_signal('mouse::leave', function () widget:hide() end)
    return widget
end
return setmetatable(indicator, {__call = function(_,...) return worker(...) end})
