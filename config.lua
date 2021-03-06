local gears      = require("gears")
timer = gears.timer
local awful      = require("awful")
local gears      = require("gears")
awful.rules      = require("awful.rules")
local common 	 = require("awful.widget.common")
local fixed 	 = require("wibox.layout.fixed")
require("awful.autofocus")
-- | Theme | --

local theme = "pro-dark"
HOME = os.getenv("HOME")
local beautiful  = require("beautiful")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")
--                   require("sharetags")
--local hintsetter  = require("hintsetter")
--hintsetter.init()
--local hints 	 = require("hints")
--hints.init()
--local tyrannical = require("tyrannical")
--local apw 	 = require("apw/widget")
hst = io.popen("uname -n")
hostname = hst:read()
hst:close()
local host = require(hostname) or {}
local wibox      = require("wibox")
local vicious    = require("vicious")
local naughty    = require("naughty") --"notifybar")
local hidetray	 = require("hidetray")
--local systray	 = require("systray")
local lain       = require("lain")
local read_pipe    = require("lain.helpers").read_pipe
local net_widgets = require("net_widgets")
--local cyclefocus = require('cyclefocus')
local rork = require("rork")      
local run_or_raise = rork.run_or_raise
local run_or_kill = rork.run_or_kill
local modal_sc = require("modal_sc")      

local widgets = require("widgets")
widgets.text_size = host.widgets_text_size or widgets.text_size
widgets.taskwidget = require("widgets.task")
--local json = require('cjson')

--local timew = require("client_timew")
--timew()

-- freedesktop.org
local freedesktop = {}
freedesktop.menu = require('freedesktop.menu')
freedesktop.utils = require('freedesktop.utils')
local revelation = require("revelation")      
revelation.init()
local newtag	 = require("newtag")      
newtag.init()
--local quake 	 = require("quake")
local scratch	 = require("scratch")
local scratchpad = require("utils.scratchpad")
--local utf8 	 = require("utf8_simple")
lain.helpers     = require("lain.helpers")
local menubar = require("menubar")
menubar.terminal = "termite"
--menubar.menu_gen.all_menu_dirs = {"~/.local/share/applications" }
menubar.menu_gen.all_categories = gears.table.join(menubar.menu_gen.all_categories,{
	other = { app_type = "", name = "wine",
	icon_name = "applications-accessories", use = true },
	wine = { app_type = "wine", name = "wine",
	icon_name = "wine", use = true },
})
--{ "/usr/share/applications/", "/usr/local/share/applications", 
local cheeky 	 = require("cheeky")
--local appsuspender = require("appsuspender")
--local im = require("im")
--local task = require("task")
local capi = {
	mouse = mouse,
	client = client,
	screen = screen
}

local function exec(...)
	--os.execute(...)
	awful.spawn(...)
end



local config = {}
config.im_width = host.im_width
local dropdownterm  = "termite -r DROPDOWN -e 'tmux attach -t dropdown '"
local dropdownterm = scratchpad({
	command = dropdownterm,
	opacity = 0.8,
})
config.panel = {}
config.panel.left = {
	widgets.spr5px,
	--widgets.taglist(),
}
config.panel.middle = {
	--widgets.tasklist()
	widgets.title_widget({
			started = host.started_title
		})
}
config.panel.right = {
	widgets.kbdd(),
	widgets.mpd(),
	widgets.taskwidget(),
	widgets.weather(),
	widgets.net({
		wired_interface = host.wired_interface,
		wireless_interface = host.wired_interface,
	}),
	widgets.pulse(),
	awful.widget.only_on_screen (
	widgets.cpu_tmp({
		tempfile = host.cpu_tmpfile,
	}),"primary"),
	awful.widget.only_on_screen (
	widgets.mem(),"primary"),
	host.widgets.mail,
	widgets.fs({
		disk_type=host.disk_type,
		automount = host.automount
		--watch = true,
	}),
	host.widgets.battery,
	widgets.calendar(),
	widgets.time(),
	widgets.spr
}
function run_once(cmd)
	findme = cmd
	firstspace = cmd:find(" ")
	if firstspace then
		findme = cmd:sub(0, firstspace-1)
	end
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end
local locker = '/home/ivn/scripts/run_slimlock_onstart.sh'
local xautolock     = "xautolock -detectsleep -locker '"..locker.."' -nowlocker '"..locker.."' -time 1 &"
local locknow       = "xautolock -locknow &"
config.autostart = {}
config.autostart.execute = gears.table.join(host.autostart.execute,{

	--"pkill xautolock ;"..xautolock,
	--"pkill compton",
	--"pkill pidgin; pidgin &",
	--"pkill kbdd; kbdd &",
	"setxkbmap 'my(dvp),my(rus)' &",
	--"setxkbmap 'my(dvp),my(rus)' setxkbmap -option grp:caps_toggle,grp_led:caps -print | xkbcomp - $DISPLAY; xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY &",
	--"xkbcomp $HOME/.config/xkb/my $DISPLAY &",
	"/home/ivn/scripts/trackpoint/trackpointkeys.sh normalmode &",
	"xset m 1/2 4",
	"xrdb -merge ~/.Xresources &",
	'pkill xcape; xcape -t 1000 -e "Control_L=Tab;ISO_Level3_Shift=Multi_key"',
	"xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY"}
	)
	local xkbtimer = gears.timer({ timeout = 2000 })
	xkbtimer:connect_signal("timeout", function ()
		awful.util.spawn_with_shell("xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY")
	end)
	local browser       = "firefox"
	config.autostart.run_once = gears.table.join(host.autostart.run_once,{

		--"linconnect-server &",
		--"kbdd",
		"mpd /home/ivn/.config/mpd/mpd.conf",
		--"mpdscribble",
		"env QT_IM_MODULE=xim telegram-desktop",
		--"telegram-desktop",
		"compton --config /home/ivn/.config/compton.conf -b &",
		--"pactl load-module module-loopback source=2 sink=0",
		--xautolock,
		"perl /usr/share/cantata/scripts/cantata-dynamic start",
		xkbtimer
		--"evolution",
		--"goldendict --style gtk+",
	})


	config.mpdwidget = widgets.mpd.mpdwidget



	modkey        = "Mod4"
	altgr        = "Mod5"
	altkey        = "Mod1"

	config.globalkeys = gears.table.join(
	awful.key({ modkey }, "l",
	function ()
		awful.prompt.run({ prompt = "Run Lua code: " },
		mouse.screen.mypromptbox.widget,
		awful.util.eval, nil,
		awful.util.getdir("cache") .. "/history_eval")
	end),
	awful.key({ modkey,       }, "q",   function (c) if client.focus then client.focus:kill() end end),
	awful.key({ modkey,	          }, "u",      function () 
		awful.spawn.with_shell("tmux new -d -s dropdown") 
		--scratch.drop(dropdownterm)
		dropdownterm:toggle()
	end), 
	--awful.key({ modkey,	          }, "u",      function () 
	----awful.spawn.with_shell("tmux new -d -s dropdown") 
	----scratch.drop(dropdownterm)
	--im:toggle()
	--end), 
	awful.key({ modkey, "Control"  }, "x",      function () exec("/home/ivn/scripts/trackpoint/trackpointkeys.sh switch &") end),
	awful.key({ modkey            }, "p",      function () run_or_raise("pcmanfm-qt", { class = "pcmanfm-qt" }) end),
	awful.key({ modkey            }, "g",      function () run_or_raise("gvim", { class = "Gvim" }) end),
	awful.key({ modkey            }, "Print",  function () exec("screengrab") end),
	awful.key({ modkey, "Control" }, "p",      function () exec("screengrab --region") end),
	awful.key({ modkey, "Shift"   }, "Print",  function () exec("screengrab --active") end),
	awful.key({ modkey            }, "f",      function () run_or_raise(browser, { class = "Firefox" }) end),
	awful.key({ modkey, "Shift"   }, "f",      function () run_or_raise(browser.." -new-window", { class = "fox" }) end),
	awful.key({ modkey, "Control" }, "f",      function () awful.util.spawn_with_shell('firefox --new-tab "$(xclip -out)"') end),
	--awful.key({ modkey            }, "c",      function () run_or_raise(browser, { class = "Vivaldi-snapshot" }) end),
	awful.key({ modkey            }, "8",      function () exec("chromium") end),
	awful.key({ modkey            }, "9",      function () exec("dwb") end),
	awful.key({ modkey            }, "0",      function () exec("thunderbird") end),
	--awful.key({ modkey            }, "'",      function () exec("leafpad") end),
	--awful.key({ modkey            }, "\\",     function () exec("sublime_text") end),
	awful.key({ modkey            }, "$",      function () exec("gcolor2") end),
	awful.key({ modkey            }, "`",      function () exec("xwinmosaic") end),
	awful.key({ }, "XF86AudioRaiseVolume",  widgets.pulse.up),
	awful.key({ }, "XF86AudioLowerVolume",  widgets.pulse.down),
	awful.key({ }, "XF86AudioMute",         widgets.pulse.togglemute),
	awful.key({ }, "XF86Sleep",         function () exec("systemctl suspend") end),
	awful.key({ }, "XF86Explorer",      function () exec("systemctl suspend") end),
	awful.key({ }, "XF86PowerOff",      
	function ()
		os.execute("systemctl suspend")
		--exec(locknow)
		--bomicontrol("pause")
	end),
	awful.key({modkey		  }, "F12",      function () exec("systemctl suspend") end),
	awful.key({ modkey, "Shift"   }, "w",  function()
		widgets.fs.mounts_menu({
		})
	end
	),
	awful.key({ modkey, "Control"   }, "w",  function()
		widgets.fs.media_files_menu({
			launcher = "/home/ivn/Downloads/umpv"
		})
	end
	),
	awful.key({ modkey, "Control"   }, "b",  
	function () 
		local cl = client.focus
		local actions = {}
		if cl and cl.class == "Firefox" then
			--local title = strings.split(cl.names," ")
			--print(cl.name:gmatch("http%S+"))
			local url
			--string.gmatch(example, "%S+")
			for k in string.gmatch(cl.name,"%S+") do
				if k:find("http") then
					url = k
				end
			end
			if url then
				table.insert(actions,{
					hint = "b",
					desc = "Open in player",
					func = function()
						os.execute(HOME..'/Downloads/umpv "'..url..'" &')
					end,
				})
			end
		end
		modal_sc({
			actions = actions,
			name = "Options with "..cl.class
		})()
	end),
	awful.key({ modkey, "Control",  }, "d",    function ()
		scripts="/home/ivn/.screenlayout/"
		modal_sc({
			actions = {
				{
					modal = true,
					hint = "o",
					desc = "DVI OFF",
					actions={
						{
							hint = "f",
							func = function()
								os.execute("xrandr --output DVI-D-0 --off")
							end,
							desc = "DVI-off"
						},
						{
							hint = "o",
							func = function()
								os.execute(scripts.."HDMI-normal-DVI-off.sh")
							end,
							desc = "HDMI-normal-DVI-off"
						},
						{
							hint = "l",
							func = function()
								os.execute(scripts.."HDMI-left-DVI-off.sh")
							end,
							desc = "HDMI-left-DVI-off"
						},
						{
							hint = "Enter",
							func = function()
								os.execute("xrandr --output DVI-D-0 --off")
							end,
							desc = ""
						},
					},
				},
				{
					modal = true,
					hint = "a",
					desc = "DVI ON",
					actions={
						{
							hint = "r",
							func = function()
								os.execute(scripts.."HDMI-right-DVI-right.sh")
							end,
							desc = "HDMI-right-DVI-right"
						},
						{
							hint = "l",
							func = function()
								os.execute(scripts.."HDMI-left-DVI-right.sh")
							end,
							desc = "HDMI-left-DVI-right"
						},
						{
							hint = "n",
							func = function()
								os.execute(scripts.."HDMI-normal-DVI-right.sh")
							end,
							desc = "HDMI-normal-DVI-right"
						},
					},
					func=function()
						--print("A")
					end,
				},
			},

		})()
	end),
	awful.key({ modkey, "Shift",  }, "r",    function ()
		menubar.show()
		--awful.prompt.run({ prompt = "Rename tab: ", text = awful.tag.selected().name, },
		--mypromptbox[mouse.screen].widget,
		--function (s)
		--awful.tag.selected().name = s
		--end)
	end),
	awful.key({ modkey,    }, "a",  
	function () 
		revelation({
			rule={class="Pidgin"}, 
			is_excluded=true
		}) 
	end),
	awful.key({ modkey,    }, "o",  function()
		widgets.taskwidget.modal_menu()
	end
	),
	awful.key({ modkey, "Shift" }, "o",  function()
		widgets.taskwidget.modal_menu({
			filter = function(task)
				if task:is_waiting() then
					return true
				end
				return false
			end
		})
	end
	),
	awful.key({ modkey,    }, "e",
	modal_sc({
		name = "Ассистент Дуся",
		actions={
			{
				hint = "e",
				desc = "вопрос",
				func = function()
					awful.util.spawn("/home/ivn/scripts/dusi_zenity.sh reply")
					local rutimer = timer({ timeout = 0.5 })
					rutimer:connect_signal("timeout", function ()
						kbddwidget.set_ru()
						rutimer:stop()
					end)
					rutimer:start()
				end
			},
			{
				hint = "u",
				desc = "команда",
				func = function()
					awful.util.spawn("/home/ivn/scripts/dusi_zenity.sh")
					local rutimer = timer({ timeout = 0.5 })
					rutimer:connect_signal("timeout", function ()
						kbddwidget.set_ru()
						rutimer:stop()
					end)
					rutimer:start()
				end
			}
		}
	})
	),
	awful.key({ modkey }, ":", function () 
		cheeky.util.switcher()
		--hints.focus() 
	end),
	awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1) end),
	awful.key({ modkey, "Control" }, "Delete",      awesome.restart),
	awful.key({ modkey, "Shift"   }, "q",      awesome.quit),
	awful.key({ modkey }, "t",
	function()
		widgets.taglist.global_bydirection("down")
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey }, "n",
	function()
		widgets.taglist.global_bydirection("up")
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey }, "h",
	function()
		widgets.taglist.global_bydirection("left")
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey}, "s",
	function()
		widgets.taglist.global_bydirection("right")
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey, "Shift" }, "h",
	function()
		widgets.taglist.global_bydirection("left",client.focus,true)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey, "Shift" }, "s",
	function()
		widgets.taglist.global_bydirection("right",client.focus,true)
		if client.focus then client.focus:raise() end
	end),

	awful.key({ modkey,           }, "Tab",
	function ()
		local cl = capi.client.focus
		local scr = cl and cl.screen or 1
		local last = awful.client.focus.history.get(scr,2)
		local list = awful.client.focus.history.list
		if list and #list > 1 then
			--awful.client.focus.history.previous()
			local last =list[2] 
			if last then
				capi.client.focus = last
				last:raise()
				if #last:tags() > 0 then
					if last.last_tag then
						last.last_tag:view_only()
					else
						last:tags()[1]:view_only()
					end
				end
				capi.client.focus = last
			end
		end
	end),
	awful.key({ modkey }, "Escape", awful.tag.history.restore),
	awful.key({ modkey }, "j", function () widgets.taglist.prevtag({}) end),
	awful.key({ modkey }, "k", function () widgets.taglist.nexttag({}) end),

	awful.key({ modkey, "Shift" }, "j",   awful.tag.viewprev       ),
	awful.key({ modkey, "Shift" }, "k",  awful.tag.viewnext       ),
	awful.key({ modkey, altgr }, "t",
	function ()
		awful.util.spawn("/home/ivn/scripts/translate_zenity.sh")
	end),
	awful.key({ modkey,           }, "z",      function () widgets.task:toggle() end),
	awful.key({ modkey,           }, "w",      function () mainmenu:show() end),
	awful.key({ modkey, "Control" }, "n",  widgets.pulse.up),
	awful.key({ modkey, "Control" }, "t",  widgets.pulse.down),
	awful.key({ modkey, "Control" }, "m",  widgets.pulse.menu),
	awful.key({ modkey,           }, "m",
	modal_sc({
		name="MAIL",
		actions = {
			{
				hint = "m",
				func = function()
					local cm = mutt.." /home/ivn/.mutt/Personal'"
					run_or_raise(cm, { class = "UXTerm" },widgets.mail.update)
				end,
				desc = "Personal"
			},
			{
				hint = "t",
				func = function()
					local cm = mutt.." /home/ivn/.mutt/FateGmail'"
					run_or_raise(cm, { class = "UXTerm" },widgets.mail.update)
				end,
				desc = "Gmail"
			},
		},
	})
	),
	awful.key({ modkey,   "Shift"        }, "t",
	modal_sc({
		name="MQTT",
		actions = {
			{
				hint = "t",
				func = function()
					os.execute("mosquitto_pub -h 192.168.1.187 -p 1883 -t cmnd/sonoff/POWER -m TOGGLE")
				end,
				desc = "lights toggle"
			},
			{
				hint = "h",
				func = function()
					os.execute("mosquitto_pub -h 192.168.1.187 -p 1883 -t cmnd/sonoff/POWER -m ON")
				end,
				desc = "lights on"
			},
			{
				hint = "n",
				func = function()
					os.execute("mosquitto_pub -h 192.168.1.187 -p 1883 -t cmnd/sonoff/POWER -m OFF")
				end,
				desc = "lights off"
			},
		},
	})
	),
	awful.key({ modkey, "Control" }, "c", 
	function ()
		run_or_raise("cantata",{class="cantata"})
		--if mpdwidget.state == "play" then
		--mpd_stop()
		--else
		--bomicontrol("stop")
		--end
	end)
	)
	config.clientkeys = gears.table.join()
	config.clientbuttons = gears.table.join()


	tag.connect_signal("property::selected",function(t)
		if t.selected then
			for _,c in pairs(t:clients()) do
				c.last_tag = t
			end
		end

	end)

	config.rules = {
		--{ rule = { class = "Pidgin", role = "buddy_list"},
		--properties = { tag = awful.tag.gettags(1)[2], switchtotag = false, no_autofocus = true }},
		--{ rule = { class = "Pidgin", role = "conversation"},
		--properties = { tag = awful.tag.gettags(1)[2], switchtotag = false, no_autofocus = true },
		--callback = awful.client.setslave },
		--{ rule = { class = "Pavucontrol" },
		--properties = { floating = true, intrusive = true } },

		--{ rule = { class = "veromix" },
		--properties = { floating = true, intrusive = true } },

		--{ rule = { name = "Громкость" },
		--properties = { floating = true, intrusive = true } },

		--{ rule = { class = "Vlc" },
		--properties = { floating = true } },
		--{ rule = { role = "HTOP_CPU" },
		--properties = { floating = true, intrusive = true} },
		--{ rule = { role = "HTOP_MEM" },
		--properties = { floating = true, intrusive = true } },

		{ rule = { class = "Exe"}, properties = {floating = true} },
		{ rule = { class = "Plugin-container" },
		properties = { floating = true, focus = true} },

	}


	config.client_specific = {enabled = host.client_specific}


	return config
