hst = io.popen("uname -n")
hostname = hst:read()
hst:close()
--local config = require(hostname)
local gears      = require("gears")
local awful      = require("awful")
awful.rules      = require("awful.rules")
local common 	 = require("awful.widget.common")
local fixed 	 = require("wibox.layout.fixed")
                   require("awful.autofocus")
-- | Theme | --

local theme = "pro-dark"
local beautiful  = require("beautiful")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")
--                   require("sharetags")
local hintsetter  = require("hintsetter")
hintsetter.init()
local hints 	 = require("hints")
hints.init()
local tyrannical = require("tyrannical")
local apw 	 = require("apw/widget")
local wibox      = require("wibox")
local vicious    = require("vicious")
local naughty    = require("naughty") --"notifybar")
local hidetray	 = require("hidetray")
local systray	 = require("systray")
local lain       = require("lain")
local read_pipe    = require("lain.helpers").read_pipe
local net_widgets = require("net_widgets")
--local cyclefocus = require('cyclefocus')
local rork = require("rork")      
local run_or_raise = rork.run_or_raise
local run_or_kill = rork.run_or_kill
local modal_sc = require("modal_sc")      

local json = require('cjson')

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
local quake 	 = require("quake")
local scratch	 = require("scratch")
local utf8 	 = require("utf8_simple")
lain.helpers     = require("lain.helpers")
local menubar = require("menubar")
menubar.terminal = "termite"
menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "/usr/local/share/applications", "~/.local/share/applications" }
local cheeky 	 = require("cheeky")
local appsuspender = require("appsuspender")
local im = require("im")
local task = require("task")
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
    }

oldprint = print
function print(s,t)
	if not s then
		s = "nill"
	end
		if type(s) == "table" then
			s = table.concat(s,"\n")
		end
		naughty.notify({
			preset = naughty.config.presets.critical,
			title = s,
			bg = beautiful.bg_normal,
			text = awesome.startup_errors,
			timeout=t,
			position = "top_left"
		}) 
end
os.execute('/home/ivn/scripts/run_slimlock_onstart.sh startup &')





-- | Error handling | --

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
	if err == "attempt to concatenate a userdata value" then return end

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- | Fix's | --

   --apwTimer = timer({ timeout = 1 }) -- set update interval in s
   --apwTimer:connect_signal("timeout", apw.Update)
  -- apwTimer:start()

-- Disable cursor animation:

local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end

-- change notify defaults

--naughty.config.defaults({
  --                      screen = client.focus and client.focus.screen or 1
    --                })


-- Java GUI's fix:

awful.util.spawn_with_shell("wmname Sawfish") --LG3D")

-- | Variable definitions | --

local home   = os.getenv("HOME")
local exec   = function (s) oldspawn(s, false) end
local shexec = awful.util.spawn_with_shell


modkey        = "Mod4"
altgr        = "Mod5"
altkey        = "Mod1"

-- table of apps and they classes
apps = {}
terminal      = "termite"
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "/usr/local/share/applications", "~/.local/share/applications" }
dropdownterm  = "termite -r DROPDOWN -e 'tmux attach -t dropdown '"
tmux          = "termite -e tmux"
termax        = "termite --geometry 1680x1034+0+22"
htop_cpu      = "termite -e 'htop -s PERCENT_CPU' -r HTOP_CPU"
htop_mem      = "termite -e 'htop -s PERCENT_MEM' -r HTOP_MEM"
mutt	      = "uxterm -fs 12 -e 'mutt -F" -- -class MAIL 
--wifi_menu     = "termite -e 'sudo wifi-menu' -r WIFI_MENU"
rootterm      = "sudo -i termite"
ncmpcpp       = "urxvt -geometry 254x60+80+60 -e ncmpcpp"
newsbeuter    = "urxvt -g 210x50+50+50 -e newsbeuter"
browser       = "firefox"
filemanager   = "spacefm"
locker = '/home/ivn/scripts/run_slimlock_onstart.sh'
xautolock     = "xautolock -locker '"..locker.."' -nowlocker '"..locker.."' -time 10 &"
locknow       = "xautolock -locknow &"
configuration = termax .. ' -e "vim -O $HOME/.config/awesome/rc.lua $HOME/.config/awesome/themes/' ..theme.. '/theme.lua"'
lastpidgin = nil

-- | Table of layouts | --

local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    awful.layout.suit.max
}

-- | Wallpaper | --

if beautiful.wallpaper then
    for s = 1, screen.count() do
        -- gears.wallpaper.tiled(beautiful.wallpaper, s)
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- | Tags | --
tagnames = { "Others", "IM", "IDEA"}
tyrannical.tags = {
    {
	name        = tagnames[1], --"Others",                 -- Call the tag "Term"
	init        = true,                   -- Load the tag on startup
	exclusive   = true,                   -- Refuse any other type of clients (by classes)
	screen      = {1,2},                  -- Create this tag on screen 1 and screen 2
	fallback    = true,
	layout      = awful.layout.suit.max,
	--hide 	    = true,
	--instance    = {"dev", "ops"},         -- Accept the following instances. This takes precedence over 'class'
	class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
	    "xterm" , "urxvt" , "aterm","URxvt","XTerm","konsole","terminator","gnome-terminal", "Termite", "Firefox", "Gvim"
	}
    } ,
    {
	name        = tagnames[2],
	init        = true, 	
	exclusive   = true,               
	screen	    = 1,                    
	hide	    = true,
	ncol	    = 3,
	mwfact      = 0.15,
	exclusive   = true,
	layout      = awful.layout.suit.tile,
	no_focus_stealing_in = true,
	
	class = {
		"Psi", "psi", "skype", "xchat", "choqok", "hotot", "qwit", "Pidgin","telegram-desktop","TelegramDesktop"
	}
    } ,
    ----{
        ----name        = "Internet",
        ----init        = true,
        ----exclusive   = true,
      ------icon        = "~net.png",                 -- Use this icon for the tag (uncomment with a real path)
        ----screen      = screen.count()>1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
        ----layout      = awful.layout.suit.max,      -- Use the max layout
        ----class = {
            ----"Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            ----"Chromium"      , "nightly"        , "minefield"     }
    ----} ,
    --{
	--name = tagnames[3],
	--init        = false,
	--exclusive   = true,
	--screen      = 1,
	--layout      = awful.layout.suit.floating,
	--exec_once   = {"dolphin"}, --When the tag is accessed for the first time, execute this command
	--class  = {
	    --"Idea", "jetbrains-idea-ce", "sun-awt-X11-XFramePeer"
	--}
    --} ,
    --{
	--name = tagnames[3],
	--init        = false,
	--exclusive   = true,
	--screen      = {1,2},
	--layout      = awful.layout.suit.tile                          ,
	--class ={ 
	    --"Firefox", "gvim", "Gvim"
	    --}
    --},
    --{
        --name        = "Doc",
        --init        = false, -- This tag wont be created at startup, but will be when one of the
                             ---- client in the "class" section will start. It will be created on
                             ---- the client startup screen
        ----exclusive   = true,
	--fallback = true,
        --layout      = awful.layout.suit.tile,
        --class       = {
            --"Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
            --"Xpdf"          ,                                        }
    --} ,
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"               ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color"    ,
    "kcolorchooser" , "plasmoidviewer" , "Xephyr"    , "kruler"       , "plasmaengineexplorer", "veromix"
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
    "kcalc"
}

--tyrannical.settings.block_children_focus_stealing = true --Block popups ()
tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client

    --{ rule = { class = "Plugin-container" },
                    --properties = { floating = true} },
    --{ rule = { class = "gcolor2" },
      --properties = { floating = true } },
    --{ rule = { class = "xmag" },
      --properties = { floating = true } },

    --{ rule = { class = "veromix" },
      --properties = { floating = true } },

    --{ rule = { name = "Громкость" },
      --properties = { floating = true } },

    --{ rule = { class = "Vlc" },
      --properties = { floating = true } },
    --{ rule = { role = "HTOP_CPU" },
      --properties = { floating = true } },
    --{ rule = { role = "HTOP_MEM" },
      --properties = { floating = true } },

    --{ rule = { class = "gvim" },
      --properties = { tag = tags[1][2], switchtotag = true}},
    --{ rule = { class = "Thunderbird" },
      --properties = { tag = tags[4] } }, 
    --{ rule = { class = "Gvim"},
         --properties = { tag = tags[1][2], switchtotag = true}},
    --{ rule = { class = "Firefox"},
         --properties = { tag = tags[1][5], switchtotag = true}},
    --{ rule = { class = "Pidgin", role = "buddy_list"},
         --properties = { tag = tags[1][3] } },
    --{ rule = { class = "Pidgin", role = "conversation"},
         --properties = { tag = tags[1][3]}, callback = awful.client.setslave },
--tags = {}
--for s = 1, screen.count() do
    --tags[s] = awful.tag({ "TERM", "CODE", "IM", "MAIL", "WEB" }, s, layouts[1])
--end

--for s = 1, screen.count() do 
----  tags[s] = awful.tag(tags.names, s, tags.layout)
  --awful.tag.setncol(3, tags[s][3]) 			   -- эта и следующая строчка нужна для Pidgin
  --awful.tag.setproperty(tags[s][3], "mwfact", 0.15)        -- здесь мы устанавливаем ширину списка контактов в 20% от ширины экрана
--end
-- {{{ Menu
--freedesktop.utils.terminal = terminal
--menu_items = freedesktop.menu.new()
--myawesomemenu = {
--{ "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
--{ "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
--{ "quit", "oblogout", freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
--}
--table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
--table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
--mymainmenu = awful.menu({ items = menu_items, theme = { width = 150 } })
--mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
---- }}}

-- | Menu | --

menu_main = {
  { "lock",    locknow       },
  { "turn screen off",   "xset dpms force suspend"},
  { "suspend", "systemctl suspend" },
  { "poweroff",  "systemctl poweroff"},
  { "restart",   awesome.restart     },
  { "reboot",    "reboot"       },
  { "quit",      awesome.quit        }}


  mainmenu = awful.menu({ items = {
	  { " awesome",       menu_main   },
	  { " file manager",  filemanager },
	  { " root terminal", rootterm    },
	  --{ " launcher", 	menu_items    },
	  { " user terminal", terminal    }}})

	  -- | Markup | --

	  markup = lain.util.markup

	  space3 = markup.font("Terminus 3", " ")
	  space2 = markup.font("Terminus 2", " ")
	  vspace1 = '<span font="Terminus 3"> </span>'
	  vspace2 = '<span font="Terminus 3">  </span>'
	  clockgf = beautiful.clockgf

	  -- | Widgets | --

	  spr = wibox.widget.imagebox()
	  spr:set_image(beautiful.spr)
	  spr4px = wibox.widget.imagebox()
	  spr4px:set_image(beautiful.spr4px)
	  spr5px = wibox.widget.imagebox()
	  spr5px:set_image(beautiful.spr5px)

	  widget_display = wibox.widget.imagebox()
	  widget_display:set_image(beautiful.widget_display)
	  widget_display_r = wibox.widget.imagebox()
	  widget_display_r:set_image(beautiful.widget_display_r)
	  widget_display_l = wibox.widget.imagebox()
	  widget_display_l:set_image(beautiful.widget_display_l)
	  widget_display_c = wibox.widget.imagebox()
	  widget_display_c:set_image(beautiful.widget_display_c)

	  local function widgetcreator(args)
		  local layout = args.layout or wibox.layout.fixed.horizontal()
		  local spr = args.spr or spr
		  layout:add(spr)
		  if args.image then
			  local widget_image = wibox.widget.imagebox()
			  widget_image:set_image(args.image)
			  layout:add(widget_image)
		  end
		  if args.text then
			  local widget_text = wibox.widget.textbox()
			  widget_text:set_markup(markup.font("Terminus 4", " ")..'<span font="Terminus 10" weight="bold">'..args.text..'</span>'..markup.font("Terminus 4", " "))
			  layout:add(widget_text)
		  end
		  if args.widgets then
			  for i,k in pairs(args.widgets) do
				  layout:add(k)
			  end
		  end

		  if args.textboxes then

			  layout:add(widget_display_l)
			  for i,k in pairs(args.textboxes) do
				  if i > 1 then 
					  layout:add(widget_display_c)
				  end
				  local background = wibox.widget.background()
				  background:set_widget(k)
				  background:set_bgimage(beautiful.widget_display)
				  layout:add(background)
			  end
			  layout:add(widget_display_r)
		  end
		  layout:add(spr5px)
		  return layout
	  end

	  -- | MPD | --

	  --prev_icon = wibox.widget.imagebox()
	  --prev_icon:set_image(beautiful.mpd_prev)
	  --next_icon = wibox.widget.imagebox()
	  --next_icon:set_image(beautiful.mpd_nex)
	  --stop_icon = wibox.widget.imagebox()
	  --stop_icon:set_image(beautiful.mpd_stop)
	  --pause_icon = wibox.widget.imagebox()
	  --pause_icon:set_image(beautiful.mpd_pause)
	  --play_pause_icon = wibox.widget.imagebox()
	  --play_pause_icon:set_image(beautiful.mpd_play)
	  mpd_sepl = wibox.widget.imagebox()
	  mpd_sepl:set_image(beautiful.mpd_sepl)
	  mpd_sepr = wibox.widget.imagebox()
	  mpd_sepr:set_image(beautiful.mpd_sepr)
	  mpd_skip_timer = timer({timeout=0.5})
	  mpd_skip_timer:connect_signal("timeout", function ()
				  local cur_rate = read_pipe('python3 /home/ivn/scripts/rate_current_mpd_song.py get rating')
				  if tonumber(cur_rate) then
					  cur_rate = math.floor(cur_rate)
				  else
					  cur_rate = nil
				  end
				  if cur_rate then
					  if cur_rate > 1 and cur_rate < 6 then
						  mpd_next()
					  elseif cur_rate == 1 and skip_unrated then
						  mpd_next()
					  end
				  elseif skip_unrated then
					  --os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 1")
					  mpd_next()
				  end
	  end)
	  --mpd_skip_timer:start()

	  mpdwidget = lain.widgets.mpd({
		  --notify = "off",
		  settings = function ()
			  mpdwidget.state = mpd_now.state
			  if mpd_now.state == "play" then
				  --print(mpd_now.title)
				  mpd_skip_timer:emit_signal("timeout")
				  widget:set_markup(" Title loading ")
				  mpd_now.artist = string.gsub(mpd_now.artist,"&quot;","'")
				  mpd_now.title = string.gsub(mpd_now.title,"&quot;","'")
				  mpd_now.artist = string.gsub(mpd_now.artist,"&amp;","and")
				  mpd_now.title = string.gsub(mpd_now.title,"&amp;","and")
				  mpd_now.artist = string.gsub(mpd_now.artist,"&apos;","'")
				  mpd_now.title = string.gsub(mpd_now.title,"&apos;","'")
				  mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
				  mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
				  artistsub = utf8.sub(mpd_now.artist:upper():gsub("&.-;", string.lower), 0, 7)
				  titlesub = utf8.sub(mpd_now.title:upper():gsub("&.-;", string.lower), 0, 12)
				  nowplayingtext = mpd_now.artist .. "-" .. mpd_now.title .. " "
				  mpdwidget.nowplaying = nowplayingtext
				  nowtext = markup.font("Tamsyn 3", " ")
				  .. markup.font("tamsyn 7",
				  artistsub
				  .. "—" ..
				  titlesub)
				  .. markup.font("Tamsyn 2", " ")

				  --nowplayingtext = mpd_now.artist.." "..mpd_now.title
				  --nowplayingtext = utf8.sub(nowplayingtext, 0, 35)
				  --nowplayingtext = string.reverse(nowplayingtext)
				  --print(nowplayingtext)
				  widget:set_markup(nowtext)

				  --play_pause_icon:set_image(beautiful.mpd_pause)
				  mpd_sepl:set_image(beautiful.mpd_sepl)
				  mpd_sepr:set_image(beautiful.mpd_sepr)
			  elseif mpd_now.state == "pause" then
				  widget:set_markup(markup.font("Tamsyn 4", "") ..
				  markup.font("Tamsyn 7", "MPD PAUSED") ..
				  markup.font("Tamsyn 10", ""))
				  --play_pause_icon:set_image(beautiful.mpd_play)
				  mpd_sepl:set_image(beautiful.mpd_sepl)
				  mpd_sepr:set_image(beautiful.mpd_sepr)
			  else
				  widget:set_markup("")
				  --play_pause_icon:set_image(beautiful.mpd_play)
				  mpd_sepl:set_image(nil)
				  mpd_sepr:set_image(nil)
			  end
		  end
	  })
mpdwidget.nextchar = function()
        if mpd_now.state == "play" then
		--mpdwidget.nowplaying = "123456789abcdefghijklmnoprst"
		text = mpdwidget.nowplaying.."|"
		--text = string.gsub(mpdwidget.nowplaying,"&apos;","'")
		mpdlength = utf8.len(text)
		startpos = math.fmod(mpdwidget.startpos, mpdlength)
		if startpos == 0 then startpos = mpdlength end
		length   = mpdwidget.length or 20
		--print("start:"..startpos)
		--print("length:"..length)
		--print("mpdlength:"..mpdlength)
		nowtext = text
		--print(mpdlength)
		--print(length)
		if not (mpdlength < length) then
			if ((startpos + length - 1) > mpdlength) then
				--print("problem")
				nowtext = utf8.sub(text, startpos) .. utf8.sub(text,1, math.abs(mpdlength-startpos+1-length))
			else
				nowtext = utf8.sub(text, startpos, startpos+length-1)
			end
		end
		--for k,v in pairs(mpdwidget) do
			--print(k)
		--end
		mpdwidget.startpos = startpos + 1
                mpdwidget.widget:set_markup(markup.font("Tamsyn 7", nowtext))
		--print(nowtext)
        end
end

function mpd_prev()
    awful.util.spawn_with_shell("mpc prev & ")
    mpdwidget.update()
end
function mpd_next()
    awful.util.spawn_with_shell("mpc next & ")
    mpdwidget.update()
end
function mpd_stop()
    --play_pause_icon:set_image(beautiful.play)
    awful.util.spawn_with_shell("mpc stop & ")
    mpdwidget.update()
end
function mpd_play_pause()
    awful.util.spawn_with_shell("mpc toggle & ")
    mpdwidget.update()
end
function mpd_play()
    awful.util.spawn_with_shell("mpc play & ")
    mpdwidget.update()
end
function mpd_pause()
    awful.util.spawn_with_shell("mpc pause & ")
    mpdwidget.update()
end
function mpd_seek_forward()
    awful.util.spawn_with_shell("mpc seek +00:00:10 &")
    mpdwidget.update()
end
function mpd_seek_backward()
    awful.util.spawn_with_shell("mpc seek -00:00:10 &")
    mpdwidget.update()
end


musicwidget = widgetcreator(
{
	textboxes = {mpdwidget}
})
musicwidget:buttons(awful.util.table.join(
awful.button({ }, 12, function () run_once("cantata") end),
awful.button({ }, 2, function () run_once("cantata") end),
awful.button({ }, 3, function () mpd_seek_forward()  end),
awful.button({ }, 1, function () mpd_seek_backward() end),
awful.button({"Ctrl" }, 1, function () mpd_prev() end),
awful.button({"Ctrl" }, 3, function () mpd_play_pause() end),
awful.button({"Ctrl" }, 2, function () mpd_next() end)
))
runinglinetimer = timer({ timeout = 0.2 })
runinglinetimer:connect_signal("timeout", function ()
	mpdwidget.nextchar()
end)

musicwidget:connect_signal("mouse::enter", function () 
	if lain.helpers.timer_table["mpd"] then
		lain.helpers.timer_table["mpd"]:stop()
	end
	mpdwidget.length = 20
	mpdwidget.startpos = 1
	runinglinetimer:start()  end)
musicwidget:connect_signal("mouse::leave", function () 
	runinglinetimer:stop()
	mpdwidget.update()
	if lain.helpers.timer_table["mpd"] then
		lain.helpers.timer_table["mpd"]:start()
	end
end)

--prev_icon:buttons(awful.util.table.join(
--awful.button({}, 1, function () mpd_prev() end),
--awful.button({ }, 4, function () mpd_seek_forward()  end),
--awful.button({ }, 5, function () mpd_seek_backward() end),
--awful.button({ }, 3, function () mpd_seek_backward() end)

--))
--next_icon:buttons(awful.util.table.join(
--awful.button({}, 1, function () mpd_next() end),
--awful.button({ }, 3, function () mpd_seek_forward()  end),
--awful.button({ }, 4, function () mpd_seek_forward()  end),
--awful.button({ }, 5, function () mpd_seek_backward() end)

--))
--stop_icon:buttons(awful.util.table.join(
--awful.button({}, 1, function () mpd_stop() end),
--awful.button({ }, 4, function () mpd_seek_forward()  end),
--awful.button({ }, 5, function () mpd_seek_backward() end)

--))
--play_pause_icon:buttons(awful.util.table.join(
--awful.button({}, 1, function () mpd_play_pause() end),
--awful.button({ }, 4, function () mpd_seek_forward()  end),
--awful.button({ }, 5, function () mpd_seek_backward() end)

--))

-- Pusleaudio controll --

pulse_widgets = apw({
	container = false,
	mixer1 = function () 
		run_or_kill("veromix", { class = "veromix" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.update, screen=mouse.screen}) 
	end,
	mixer2 =  function () 
		run_or_kill("pavucontrol", { class = "Pavucontrol" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.update, screen=mouse.screen}) 
	end
})
pulsewidget = widgetcreator(
{
	widgets = {pulse_widgets["progressbar"]},
	textboxes = {pulse_widgets["textbox"]}
})
--volumetext = lain.widgets.pulseaudio({
	----settings = {
	----widget:set_text(volume_now.left)
	----},
	--settings = function()
		--if volume_now.left == volume_now.right then
			--vlevel = volume_now.left .. "%"
		--else
			--vlevel = volume_now.left .. "-" .. volume_now.right .. "%"
		--end
		----if volume_now.muted == "yes" then
			----vlevel = vlevel .. " M"
		----end

		--widget:set_markup(vlevel) --markup("#7493d2", vlevel))
	--end,
--})
--volumebar = lain.widgets.pulsebar({
	--vertical = true,
	--height = 18,
	--width = 5,
	--settings = function()
		--vlevel = ((volume_now.left+volume_now.right)/2)/150
		----if volume_now.muted == "yes" then
			----vlevel = vlevel .. " M"
		----end
		----widget:set_value(vlevel)
		----pulsebar.bar(vlevel)
		----pulsebar.bar:set_value(pulsebar._current_level / 100)

		----widget:set_markup(vlevel) --markup("#7493d2", vlevel))
	--end,

--})
--pulsewidget = widgetcreator(
--{
	--widgets = {volumebar.bar},
	--textboxes = {volumetext}
--})

--pulseBar:buttons(awful.util.table.join(pulseBar.buttonsTable, awful.button({ }, 1, function () run_or_kill("veromix", { class = "veromix" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.Update, screen=mouse.screen}) end),
--awful.button({ }, 3, function () run_or_kill("pavucontrol", { class = "Pavucontrol" }, {x = mouse.coords().x, y = mouse.coords().y, funcafter = apw.Update, screen=mouse.screen}) end)))
apw:setbuttons(pulsewidget)
--apw:attach(pulsewidget)

-- Battery widget

if hostname == "Thinkpad" then
	baticon = wibox.widget.imagebox(beautiful.widget_battery)
	batwidget = lain.widgets.bat({
		battery = "BAT1",
		settings = function()
			if bat_now.status == "Charging" then
				baticon:set_image(beautiful.widget_ac)
			elseif bat_now.perc == "N/A" then
				widget:set_markup("AC")
				baticon:set_image(beautiful.widget_ac)
				return
			elseif tonumber(bat_now.perc) <= 5 then
				baticon:set_image(beautiful.widget_battery_empty)
			elseif tonumber(bat_now.perc) <= 15 then
				baticon:set_image(beautiful.widget_battery_low)
			else
				baticon:set_image(beautiful.widget_battery)
			end
			widget:set_markup(" " .. bat_now.perc .. "% ")
		end
	})
	batterywidget = widgetcreator(
	{
		widgets = {baticon},
		textboxes = {batwidget}
	})
	local function battery_time_grabber()
		f = io.popen("acpi -b | awk '{print $5}' | awk -F \":\" '{print $1\":\"$2 }'")
		str = f:read()
		f.close()
		if str then
			return str.." remaining"
		else
			return "no battery"
		end
	end
	local battery_notify = nil
	function batwidget:hide()
		if battery_notify ~= nil then
			naughty.destroy(battery_notify)
			battery_notify = nil
		end
	end
	function batwidget:show(t_out)
		batwidget:hide()
		battery_notify = naughty.notify({
			preset = fs_notification_preset,
			text = battery_time_grabber(),
			timeout = t_out,
			screen = mouse.screen
		})
	end
	batterywidget:connect_signal('mouse::enter', function () batwidget:show(0) end)
	batterywidget:connect_signal('mouse::leave', function () batwidget:hide()  end)
end



-- Keyboard map indicator and changer
kbddnotify = nil
kbdstrings = 
{
	[0] = "EN",
	[1] = "RU" 
}
kbdtext = wibox.widget.textbox(kbdstrings[0])
dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
	local data = {...}
	local layout = data[2]
	kbdtext:set_markup(kbdstrings[layout])
	local text ='<span font="Cantarel 50">'..kbdstrings[layout].."</span>"
	naughty.destroy(kbddnotify)
	kbddnotify = naughty.notify({
		text = text,
		--icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
		timeout = 2,
		screen = mouse.screen or 2,
		position = "bottom_right",
	})
end
)
local switch_kbd_layout ="dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.prev_layout"

kbdwidget = widgetcreator(
{
	textboxes = {kbdtext}
})
kbdwidget:buttons(awful.util.table.join(
--awful.button({ }, 12, function () run_once("cantata --style gtk+") end),
--awful.button({ }, 2, function () run_once("cantata --style gtk+") end),
--awful.button({ }, 3, function () mpd_seek_forward()  end),
awful.button({ }, 1, function () os.execute(switch_kbd_layout) end)
--awful.button({"Ctrl" }, 1, function () mpd_prev() end),
--awful.button({"Ctrl" }, 3, function () mpd_play_pause() end),
--awful.button({"Ctrl" }, 2, function () mpd_next() end)
))

-- -- {{{ Menu
-- freedesktop.utils.terminal = terminal
-- menu_items = freedesktop.menu.new()
-- myawesomemenu = {
--    { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
--    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
--    { "edit theme", editor_cmd .. " " .. awful.util.getdir("config") .. "/themes/cesious/theme.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
--    { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
--    { "quit", "oblogout", freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
-- }
-- table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
-- table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })
-- mymainmenu = awful.menu({ items = menu_items, theme = { width = 150 } })
-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- | Mail | --

local ignoremail = {
	"[Gmail].Trash",
	"[Gmail].Spam",
	"[Gmail].All Mail",
	"[Gmail].Drafts",
	"[Gmail].Important",
	"[Gmail].Sent Mail",
	"[Gmail].Starred",
	"[Gmail].Junk",
	"[Gmail].Starred",
	"Drafts",
	"Junk",
	"Notes",
	"Trash",
	"Личные",
	"Путешествие",
	"Работа",
	"Счета",
	"Спам",
	"[Mailbox]",
	"[Mailbox].Later",
	"[Mailbox].To buy",
	"[Mailbox].To Read",
	"[Mailbox].To Watch",
}
local function mailnotif(args)
			return naughty.notify({
				title = args.title,
				text = args.text,
				icon = args.icon or "/home/ivn/Загрузки/KFaenzafordark/status/32/mail-queued.png",
				timeout = args.timeout,
				screen = mouse.screen or 1,
				run = args.run,
			})
end

local function getmailwidget(args)
	local args = args or {}
	args.total = 0
	args.newmail = ""
	args.mailbox = args.mailbox or ""
	local function run() 
		local cm = mutt.." /home/ivn/.mutt/"..args.mailbox.."'"
		run_or_raise(cm, { class = "UXTerm" }) 
	end
	args.textbox = lain.widgets.maildir({
		mailpath = "/home/ivn/Mail/"..args.mailbox,
		settings = function()
			args.textbox:set_text(total) --newmail)
			args.total = total
			args.newmail = newmail
			if total > 0 then
				args.textbox:show(args.notiftimeout or 10)
				--mailnotif({
					--title = args.mailbox,
					--text = newmail,
					--timeout = args.notiftimeout or 10,
				--})
			end
		end,
		ignore_boxes = ignoremail,
		timeout = args.timertimeout or 30,
	})
	local mail_notify = nil
	function args.textbox:hide()
		if mail_notify ~= nil then
			naughty.destroy(mail_notify)
			mail_notify = nil
		end
	end
	function args.textbox:show(t_out)
		args.textbox:hide()
		mail_notify = mailnotif({
			title = args.mailbox,
			text = args.newmail ~= "" and args.newmail or args.total,
			icon = "/home/ivn/Mail/"..args.mailbox..".png",
			timeout = t_out,
			run = run,
		})
	end
	function args.textbox:attach(widget)
		widget:connect_signal('mouse::enter', function () args.textbox:show(0) end)
		widget:connect_signal('mouse::leave', function () args.textbox:hide()  end)
	end
	local mailbuttons = awful.util.table.join(awful.button({ }, 1,
	run
	))
	args.textbox:buttons(mailbuttons)
	args.textbox:set_text("0")
	local timer = timer({ timeout = 1 })
	timer:connect_signal("timeout", function ()
		if lain.helpers and lain.helpers.timer_table and lain.helpers.timer_table["/home/ivn/Mail/"..args.mailbox] then
			lain.helpers.timer_table["/home/ivn/Mail/"..args.mailbox]:emit_signal("timeout")
			timer:stop()
		end
	end)
	timer:start()
	return args.textbox
end

mail_widget3 = getmailwidget({mailbox = "FateGmail", textbox = mail_widget3})
--mail_widget2 = getmailwidget({mailbox = "FateYandex", textbox = mail_widget2 }) 
mail_widget1 = getmailwidget({mailbox = "Personal", textbox = mail_widget1})
mailwidget = widgetcreator({
	text = "MAIL",
	textboxes = {mail_widget1, mail_widget3 }, --2, mail_widget3},
})
mail_widget3:attach(mailwidget)
--mail_widget2:attach(mailwidget)
mail_widget1:attach(mailwidget)
mailwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function ()
	local timer = timer({ timeout = 1 })
	timer:connect_signal("timeout", function ()
		local cm = mutt.." /home/ivn/.mutt/Personal'"
		run_or_raise(cm, { class = "UXTerm" }) 
		timer:stop()
	end)
	timer:start()
end),
awful.button({ }, 2,
function ()
	local timer = timer({ timeout = 1 })
	timer:connect_signal("timeout", function ()
		local cm = mutt.." /home/ivn/.mutt/FateYandex'"
		run_or_raise(cm, { class = "UXTerm" }) 
		timer:stop()
	end)
	timer:start()
end),
awful.button({ }, 3,
function ()
	local timer = timer({ timeout = 1 })
	timer:connect_signal("timeout", function ()
		local cm = mutt.." /home/ivn/.mutt/FateGmail'"
		run_or_raise(cm, { class = "UXTerm" }) 
		timer:stop()
	end)
	timer:start()
end)
))
--wibox.widget.textbox()
--vicious.register(mail_widget, vicious.widgets.gmail, vspace1 .. "${count}" .. vspace1, 1200)

--widget_mail = wibox.widget.imagebox()
--widget_mail:set_image(beautiful.widget_mail)
--mailwidget = wibox.widget.background()
--mailwidget:set_widget(mail_widget)
--mailwidget:set_bgimage(beautiful.widget_display)

-- | CPU / TMP | --

cpu_widget = lain.widgets.cpu({
	settings = function()
		widget:set_markup(space3 .. cpu_now.usage .. "%" .. markup.font("Tamsyn 4", " "))
	end
})

cpubuttons = awful.util.table.join(awful.button({ }, 1,
function () run_or_kill(htop_cpu, { role = "HTOP_CPU" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))

tmp_widget = lain.widgets.temp({
	tempfile = "/sys/class/hwmon/hwmon2/temp2_input",
	settings = function()
		widget:set_markup(space3 .. coretemp_now .. "°C" .. markup.font("Tamsyn 4", " "))
	end
})

cpuwidget = widgetcreator(
{
	--image = beautiful.widget_mem,
	text = "CPU",
	textboxes = {cpu_widget, tmp_widget}
})

cpuwidget:buttons(cpubuttons)

-- | MEM | --


membuttons = awful.util.table.join(awful.button({ }, 1,
function () run_or_kill(htop_mem, { role = "HTOP_MEM" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))


memp_widget = wibox.widget.textbox()
mem_widget = lain.widgets.mem({
	timeout = 15,
    settings = function()
	    local perc = math.ceil(mem_now.used/mem_now.total*100, 0, 3)
	    memp_widget:set_markup(space3 .. perc .. "%" .. markup.font("Tamsyn 4", " "))
        widget:set_markup(space3 .. mem_now.used .. "MB" .. markup.font("Tamsyn 4", " "))
    end
})
memwidget = wibox.widget.background()
memwidget:set_widget(mem_widget)
memwidget:set_bgimage(beautiful.widget_display)
memwidget = widgetcreator(
{
	--image = beautiful.widget_mem,
	text = "RAM",
	textboxes = {mem_widget, memp_widget}
})
 memwidget:buttons(membuttons)

-- | FS | --

fs_widget = wibox.widget.textbox()
vicious.register(fs_widget, vicious.widgets.fs, vspace1 .. "${/ avail_gb}GB" .. vspace1, 2)
fswidget = widgetcreator(
{
	--image = beautiful.widget_fs,
	text = "SSD",
	textboxes = {fs_widget}
})
    local fsnotification = nil
    function fswidget:hide()
        if fsnotification ~= nil then
            naughty.destroy(fsnotification)
            fsnotification = nil
        end
    end

    function fswidget:show(t_out)
        fswidget:hide()

	fsnotification = naughty.notify({
		preset = fs_notification_preset,
		text = text_grabber(),
		timeout = t_out,
		screen = mouse.screen,
	})
    end
    function text_grabber()
                f = io.popen("df -H")
		text = f:read()
		f:close()
                f = io.popen("df -H | grep -i '^/dev/' ")
                for line in f:lines() do
			text = text.."\n"..line
		end
		f:close()
		return text
    end
fswidget:connect_signal('mouse::enter', function () fswidget:show(0) end)
fswidget:connect_signal('mouse::leave', function () fswidget:hide()  end)
-- | TASK | --

task({
	due="overdue",
	timeout=1000,
})
taskwidget = widgetcreator(
{
	--image = "/home/ivn/.config/awesome/task/tasksmall.png"
	widgets = {task.imagebox},
	--text = "TASK",
	textboxes = {task.textbox}
})
duetask_notification=nil
due_notif_destroy= function ()
	if duetask_notification then
		naughty.destroy(duetask_notification)
		duetask_notification = nil
		--taskwidget:disconnect_signal('mouse::leave',due_notif_destroy)
	end
end
due_notif_show = function()
	duetask_notification = naughty.notify({
		--preset = fs_notification_preset,
		text = task.get_duetask(),
		timeout = 0,
		screen = mouse.screen,
	})
end
task:attach(taskwidget,
{
    onclick1=function()
	if duetask_notification == nil then
		due_notif_show()
	else
		due_notif_destroy()
	end
	taskwidget:connect_signal('mouse::leave',
	function ()
		local timer = timer({ timeout = 5 })
		timer:connect_signal("timeout", function ()
			due_notif_destroy()
			timer:stop()
		end)
		timer:start()
	end)
    end,
    onclick2=function()
	    task.prev_duetask()
	    due_notif_destroy()
	    due_notif_show()
    end,
    onclick3=function()
	    task.next_duetask()
	    due_notif_destroy()
	    due_notif_show()
    end,
})


-- | NET | --
--
--
wifitextlayout = wibox.layout.fixed.horizontal()
backtext = wibox.layout.constraint()
net_wireless = net_widgets.wireless({
	interface="wlp0s18f2u3", 
	widget = false, 
	indent = 0, 
	timeout = 10,
	settings = function(args)
		if args.connected then
			backtext:set_widget(wifitextlayout)
		else
			backtext:reset()
		end
	end
}) --, widget=wibox.layout.fixed.horizontal()})
if hostname == "jarvis" then
	interface = "enp5s0"
else -- hostname == "Thinkpad" then
	interface = "enp2s0"
end
net_wired = net_widgets.indicator({
	interfaces  = {interface},
    timeout     = 25,
})
wifitextlayout:add(widget_display_l)
local background = wibox.widget.background()
background:set_widget(net_wireless.textbox)
background:set_bgimage(beautiful.widget_display)
wifitextlayout:add(background)
wifitextlayout:add(widget_display_r)

netwidget = widgetcreator(
{
	widgets = {net_wired,net_wireless.imagebox,backtext},
	--text = "RAM",
	--textboxes = {net_wireless.textbox}
})
net_widgets.wireless:attach(netwidget)  --,{
--onclick = run_or_kill(wifi_menu, { role = "WIFI_MENU" }, {x = mouse.coords().x, y = mouse.coords().y+2})})
--net_widgetdl = wibox.widget.textbox()
--net_widgetul = lain.widgets.net({
    --settings = function()
        --widget:set_markup(markup.font("Tamsyn 1", "  ") .. net_now.sent)
        --net_widgetdl:set_markup(markup.font("Tamsyn 1", " ") .. net_now.received .. markup.font("Tamsyn 1", " "))
    --end
--})

--widget_netdl = wibox.widget.imagebox()
--widget_netdl:set_image(beautiful.widget_netdl)
--netwidgetdl = wibox.widget.background()
--netwidgetdl:set_widget(net_widgetdl)
--netwidgetdl:set_bgimage(beautiful.widget_display)

--widget_netul = wibox.widget.imagebox()
--widget_netul:set_image(beautiful.widget_netul)
--netwidgetul = wibox.widget.background()
--netwidgetul:set_widget(net_widgetul)
--netwidgetul:set_bgimage(beautiful.widget_display)


-- | Weather | --

local read_pipe = require("lain.helpers").read_pipe
weather_widget = lain.widgets.weather({
	APPID = "9a42072650caa7c0145df83667e701f5",
	city_id = "519690",
	settings = function()
		--for i,k in pairs(weather_now["main"])do
			--print(i)
			----print(k)
			----f = function(s)
				----if not (type(s) == "table") then
					----print(s)
				----else
					----for a,b in pairs(s)do
						----print(a)
						----f(b)
					----end
				----end
			----end
			----f(k)
		--end
		----print(weather_now["main"]["temp_max"])
		----print(weather_now["main"]["temp_min"])
		--print(weather_now["main"]["temp"])
		local wn = weather_now["main"]
		--local tmin =wn["temp_min"]--math.floor()
		--local tmax =wn["temp_max"]--math.floor()
		local temp =math.floor(wn["temp"])
		weather_widget.widget:set_markup(temp.."°C")
	end,
	notification_text_fun = function(wn)
		--local day = string.gsub(read_pipe(string.format(date_cmd, wn["dt"])), "\n", "")
		local day = string.gsub(read_pipe(string.format("date -u -d @%d +'%%A %%d'", -- customize date cmd here
		wn["dt"])), "\n", "")

		local tmin = math.floor(wn["temp"]["min"])
		local tmax = math.floor(wn["temp"]["max"])
		local desc = wn["weather"][1]["description"]
		return string.format("<span font='Terminus bold 18'><b>%s</b>: %s, %d°C - %d°C </span>", day, desc, tmin, tmax)
	end,
})

--weatherbuttons = awful.util.table.join(awful.button({ }, 1,
--function () run_or_kill(htop_weather, { role = "HTOP_CPU" }, {x = mouse.coords().x, y = mouse.coords().y+2}) end))

--tmp_widget = lain.widgets.temp({
	--tempfile = "/sys/class/hwmon/hwmon2/temp2_input",
	--settings = function()
		--widget:set_markup(space3 .. coretemp_now .. "°C" .. markup.font("Tamsyn 4", " "))
	--end
--})

weatherwidget = widgetcreator(
{
	--image = weather_widget.icon,
	--text = "CPU",
	textboxes = {weather_widget.widget},
	widgets = {weather_widget.icon},
})

--weatherwidget:buttons(weatherbuttons)
weather_widget.attach(weatherwidget)




-- | Clock / Calendar | --
dbus.request_name("session", "org.naquadah.awesome.time")
dbus.add_match("session", "interface='org.naquadah.awesome.time',member='saytime'")
dbus.connect_signal("org.naquadah.awesome.time",
function(...)
	local args = {...}
	--local method_name = args[2]
	--if method_name == "show_task" then
		--task:show_task(args[3],args[4])
	--end
	saytime()
end
)
timenotify = nil
function saytime()
	awful.util.spawn_with_shell("/home/ivn/scripts/say_time.sh")
	time = os.date("%H:%M")
	time ='<span font="Cantarel 50">'..time.."</span>"
	naughty.destroy(timenotify)
	timenotify = naughty.notify({
		text = time,
		--icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
		timeout = 2,
		screen = mouse.screen or 1
	})

end
dbus.request_name("session", "org.naquadah.awesome.say")
dbus.add_match("session", "interface='org.naquadah.awesome.say',member='say'")
dbus.connect_signal("org.naquadah.awesome.say",
function(...)
	local args = {...}
	local method_name = args[2]
	if method_name == "say" then
		say(args[3])
	end
end
)
function say(text)
		local lang ="ru"
		if string.match(text,"[a-zA-Z0-9,.!? ]*") ==text then
			lang ="en"
		end
	awful.util.spawn_with_shell("/home/ivn/scripts/saytext.sh  '"..lang.."' '"..text.."' fast >>/dev/null &")
end

mytextclockbuttons = awful.util.table.join(
awful.button({ }, 2,
function () saytime() end),
awful.button({ }, 12,
function () 
	saytime() end))

mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font("Tamsyn 3", " ")), 15)
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

clockwidget = widgetcreator(
{
	image = beautiful.widget_clock,
	textboxes = {mytextclock}
})


calendarwidget = widgetcreator(
{ 
	image = beautiful.widget_cal,
	textboxes = {mytextcalendar}
})

lain.widgets.calendar:attach(clockwidget, 
{ 
	font_size = 10,
	cal       = "/usr/bin/cal -m "
    }
)
lain.widgets.calendar:attach(calendarwidget, 
{ 
	font_size = 13,
	cal       = "/usr/bin/cal -m "
    }
)
--calendarwidget:buttons(mytextclockbuttons)
clockwidget:buttons(mytextclockbuttons)


-- | Taglist | --

local function taglist_update(w, buttons, label, data, objects)
	local function matchrules(tag)
		return function(c, screen)
			--if c.sticky then return true end
			--local ctags = c:tags()
			--for _, v in ipairs(ctags) do
				--if v == tag then
					--return true
				--end
			--end
			return false
		end
	end
	local function get_tasklist_update(tag)
		return function (w, buttons, label, data, objects)
			-- update the widgets, creating them if needed
			w:reset()
			for i, o in ipairs(tag:clients()) do
				local cache = data[o]
				local ib, tb, bgb, m, l, munf, mfoc, background
				if cache then
					ib = cache.ib
					bgb = cache.bgb
					m =  cache.m
					tb = cache.tb
					munf = cache.munf
					mfoc = cache.mfoc
					l = cache.l
					tl = cache.tl
					el = cache.el
					tbl = cache.tbl
				else
					ib = wibox.widget.imagebox()
					bgb = wibox.widget.background()
					tb = wibox.widget.textbox()
					m = wibox.layout.margin(tb, 0, 0)
					--munf = wibox.layout.margin(ib, 0, 0, 0, 5)
					--mfoc = wibox.layout.margin(ib, 0, 0, 0, 0)
					l = wibox.layout.fixed.horizontal()
					tl = wibox.layout.fixed.horizontal()
					tbl = wibox.layout.constraint()
					munf = wibox.layout.margin(l, 0, 0, 0, 5)
					mfoc = wibox.layout.margin(l, 0, 0, 0, 0)
					l:add(widget_display_l)
					local background = wibox.widget.background()
					background:set_widget(m)
					background:set_bgimage(beautiful.widget_display)
					-- All of this is added in a fixed widget
					l:fill_space(true)
					tl:add(background)
					tbl:set_widget(tl)
					l:add(tbl)
					l:add(ib)
					--l:add(munf)


					-- And all of this gets a background
					bgb:set_widget(l)

					bgb:buttons(common.create_buttons(buttons, o))

					data[o] = {
						ib = ib,
						bgb = bgb,
						m = m,
						tb = tb,
						munf   = munf,
						mfoc = mfoc,
						l = l,
						tl = tl,
						el = el,
						tbl = tbl,
					}
				end
				if tag.selected then
					if (o == capi.client.focus) then
						bgb:set_widget(mfoc)
					else
						bgb:set_widget(munf)
					end
				else
					bgb:set_widget(munf)
				end

				local text, bg, bg_image, icon = label(o)
				-- The text might be invalid, so use pcall
				--if not pcall(tb.set_markup, tb, text) then
				local textlabel = ""

				if hintsetter.windows[o.window] then
					--tb:set_markup('<span font="Terminus 10" weight="bold">'..hintsetter.windows[o.window]..'</span>')
					textlabel = hintsetter.windows[o.window]
				else
					--tb:set_markup(markup.font("Terminus 4", " ")..'<span font="Terminus 10" weight="bold">'.."_"..'</span>'..markup.font("Terminus 4", " "))
					textlabel ="_"
				end
				--end
				if o.minimized then
					--background = wibox.widget.background()
					--tbl:set_widget(el)
					--print(o.class.." minimized")
					textlabel = "^"..textlabel
				--else
					--tbl:set_widget(tl)
				end
				tb:set_markup('<span font="Terminus 10" weight="bold">'..textlabel..'</span>')
				if icon == nil then
					icon = os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/icons/konsole.png"
				end
				--bgb:set_bg(bg)
				if type(bg_image) == "function" then
					bg_image = bg_image(tb,o,m,objects,i)
				end
				bgb:set_bgimage(bg_image)
				ib:set_image(icon)
				w:add(bgb)
			end
		end
	end
	-- update the widgets, creating them if needed
	w:reset()
	local number = -1
	for i, o in ipairs(objects) do
		number = number + 1
		local cache = data[o]
		local ib, tb, bgb, m, l
		if cache then
			ib = cache.ib
			tb = cache.tb
			bgb = cache.bgb
			m   = cache.m
		else
			ib = wibox.widget.imagebox()
			tb = wibox.widget.textbox()
			textwidget = wibox.widget.background()
			textwidget:set_bgimage(beautiful.widget_display)
			textwidget:set_widget(tb)
			bgb = wibox.widget.background()
			m = wibox.layout.margin(tb, 4, 4)
			l = wibox.layout.fixed.horizontal()

			-- All of this is added in a fixed widget
			l:fill_space(true)
			--l:add(m)
			l:add(spr)
			l:add(spr)
			if number > 0 then
				l:add(widget_display_l)
				l:add(textwidget)
				l:add(widget_display_r)
			end
			l:add(awful.widget.tasklist(s, matchrules(o) ,  myiconlist.buttons, {tasklist_only_icon=true}, get_tasklist_update(o), fixed.horizontal()))
			--awful.widget.taglist.filter.all
			l:add(spr)
			l:add(spr)
			-- And all of this gets a background
			--title = wibox({fg=beautiful.fg_normal, bg=beautiful.bg_focus, border_color=beautiful.border_focus, border_width=beautiful.border_width})
			--title:set_widget(tb)
			bgb:set_widget(l)
			--w:connect_signal("mouse::enter", function ()
			--title.visible = true
			--title.x = mouse.coords().x 
			--title.y = mouse.coords().y 
			--title.screen = capi.mouse.screen
			--end)
			--w:connect_signal("mouse::leave", function () title.visible = false end)
			bgb:buttons(common.create_buttons(buttons, o))

			data[o] = {
				ib = ib,
				tb = tb,
				bgb = bgb,
				m   = m
			}
		end
		--tb:set_markup("<i>&lt;"..number..":&gt;</i>")

		local text, bg, bg_image, icon = label(o)
		-- The text might be invalid, so use pcall
		--text = number..":"
		text = hintsetter.charorder:sub(i,i):upper()
		if not pcall(tb.set_markup, tb, text) then
			tb:set_markup("<i>&lt;Invalid text&gt;</i>")
		end
		--bgb:set_bg(bg)
		if type(bg_image) == "function" then
			bg_image = bg_image(tb,o,m,objects,i)
		end
		bgb:set_bgimage(bg_image)
		ib:set_image(icon)
		w:add(bgb)
	end
end


mytaglist         = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    --awful.button({ }, 3, awful.tag.viewtoggle),
                    --awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext() end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev() end)
                    )

-- | Tasklist | --

myiconlist         = {}
myiconlist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
					      if c == client.focus then
						  c.minimized = true
					      else
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
					      end
                                          end),
                     awful.button({ }, 12, function (c)
			     			c:kill()
                                          end),
                     awful.button({ }, 2, function (c)
			     			c:kill()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- | Tasklist | --

local function matchrules(rules, exclude)
    -- Only print client on the same screen as this widget
    local exclude = exclude or false
    return function(c, screen)
    	if c.screen ~= screen then return false end
    	-- Include sticky client too
    	if c.sticky then return false end
    	local ctags = c:tags()
	for _,rule in pairs(rules) do
		if awful.rules.match(c, rule) then return not exclude end
	end
    	return exclude
    end
end

mytasklist         = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- | PANEL | --

mywibox           = {}
mypromptbox       = {}
mylayoutbox       = {}
mynotifybar = {}
tray = hidetray({revers = true})
text = wibox.widget.textbox("0")
systray:attachtext(text)
--hidetray:show(1)
--hidetray.hidetimer:start()

for s = 1, screen.count() do
	--if s == 1 then
	--end
	awful.tag.viewonly(awful.tag.gettags(s)[1])
   
    mypromptbox[s] = awful.widget.prompt()
    
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    --mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons, {}, taglist_update)

    -- mytaglist[s] = sharedtags.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    mytasklist[s] = awful.widget.tasklist(s, matchrules({{class = "Pidgin"},{class="TelegramDesktop"}}, false), mytasklist.buttons)

    --myiconlist[s] = awful.widget.tasklist(s, matchrules({class = "Pidgin"}, true),  myiconlist.buttons, {tasklist_only_icon=true}, tasklist_update, fixed.horizontal())

    --tasklist.new(screen, filter, buttons, style, update_function, base_widget)
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "22" })
    --if s == 2 then
    --local sidebar = wibox.layout.align.vertical()
    --mynotifybar = awful.wibox({position = "right", screen = s, width = "250"})
    --if naughty.stack then
    --mynotifybar:set_widget(naughty.stack)
    --end
    --end
    local left_layout = wibox.layout.fixed.horizontal()

    --left_layout:add(mylauncher)
    --left_layout:add(spr5px)
    --left_layout:add(myiconlist[s])
    left_layout:add(spr5px)
    left_layout:add(mytaglist[s])
    --left_layout:add(spr5px)

    local centr_layout = wibox.layout.fixed.horizontal()

    centr_layout:add(mytasklist[s])


    local right_layout = wibox.layout.fixed.horizontal()
    hidetray:attach({ wibox = mywibox[s], screen = s})
    local cont = widgetcreator(
    {
	    widgets = {spr5px,mypromptbox[s], text, tray[s]}
    })
    right_layout:add(cont)
    right_layout:add(kbdwidget)
    right_layout:add(musicwidget)
    right_layout:add(taskwidget)
    right_layout:add(weatherwidget)
    right_layout:add(netwidget)
    right_layout:add(pulsewidget) 
    if s == 1 then
	    right_layout:add(cpuwidget)
	    right_layout:add(mailwidget)
	    right_layout:add(memwidget)
	    right_layout:add(fswidget)
	    if hostname == "Thinkpad" then
		    right_layout:add(batterywidget)
	    end
    end
    right_layout:add(calendarwidget)
    right_layout:add(clockwidget)
    right_layout:add(spr)
    right_layout:add(mylayoutbox[s])
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    if s == 1 then
	    layout:set_middle(centr_layout)
    end
    layout:set_right(right_layout)

    mywibox[s]:set_bg(beautiful.panel)

    mywibox[s]:set_widget(layout)
end
task.promptbox=mypromptbox

-- | Mouse bindings | --

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({modkey, }, 4, awful.tag.viewnext),
    awful.button({modkey, }, 5, awful.tag.viewprev)
))

function mybydirection(dir, c, all)
	local sel = c or capi.client.focus
	if sel then
		local tag = awful.tag.selected(sel.screen)
		local id = awful.tag.getidx(tag)
		if id  == 1 then
			local clientlist = tag:clients()
			local clid = nil
			for i,cl in pairs(clientlist) do
				if cl == sel then
					clid = i
					break
				end
			end
			local number = nil
			if dir == "left" then
				number = -1
			elseif dir == "right" then
				number = 1
			end
			if number then
				clid = clid + number
				while clientlist[clid] do
					if not clientlist[clid].minimized or all then
						if (clid > 0) and (clid <= #clientlist) then
							local target = clientlist[clid]
							-- If we found a client to focus, then do it.
							if target then
								capi.client.focus = target
								break
							end
						end
					end
					clid = clid + number
				end
			end
				
		else
			local cltbl = awful.client.visible(sel.screen)
			local geomtbl = {}
			for i,cl in ipairs(cltbl) do
				geomtbl[i] = cl:geometry()
			end

			local target = awful.util.get_rectangle_in_direction(dir, geomtbl, sel:geometry())

			-- If we found a client to focus, then do it.
			if target then
				capi.client.focus = cltbl[target]
			end
		end
	end
end
local function myglobal_bydirection(dir, c, all)
	local screen = awful.screen
	local sel = c or capi.client.focus
	local scr = capi.mouse.screen
	local all = all or false
	--print(type(all))
	--print(tostring(all))
	if sel then
		scr = sel.screen
	end
	-- change focus inside the screen
	mybydirection(dir, sel, all)

	-- if focus not changed, we must change screen
	if sel == capi.client.focus then
		screen.focus_bydirection(dir, scr)
		if scr ~= capi.mouse.screen then
			local tag = awful.tag.selected(capi.mouse.screen)
			local id = awful.tag.getidx(tag)
			if id  ~= 1 then

				local cltbl = awful.client.visible(capi.mouse.screen)
				local geomtbl = {}
				for i,cl in ipairs(cltbl) do
					geomtbl[i] = cl:geometry()
				end
				local target = awful.util.get_rectangle_in_direction(dir, geomtbl, capi.screen[scr].geometry)

				if target then
					capi.client.focus = cltbl[target]
				end
			end
		end
	end
	--print("this")
	--if sel == capi.client.focus then
		----print("freenge")
		--local visibleclients = awful.client.visible(scr)
		----{}
		----for i,t in pairs(awful.tag.selectedlist(scr)) do
		----visibleclients = awful.util.table.join(visibleclients,t:clients())
		----end
		--for i,t in pairs(visibleclients) do
			----print(i.."—"..t.window)
		--end
		----print(visibleclients[k].name.."="..sel.name)
		--if number == nil or visibleclients[k] == sel then
			----print("number="..tostring(number))
			--screen.focus_bydirection(dir, scr)
		--else
			--for i,k in pairs(visibleclients) do
				--if k == sel then
					----print(i.."->"..(i-number))
					--local target = visibleclients[i-number]
					--if target then
						--capi.client.focus = target
					--end
					--return true
				--end
			--end
		--end
	--end
end    	
-- | Key bindings | --
local function bomicontrol(str)
	local command = "dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.bomi /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."
	if str == "play" then
		command = command.."Play"
	elseif str == "pause" then
		command = command.."Pause"
	elseif str == "next" then
		command = command.."Next"
	elseif str == "prev" then
		command = command.."Prev"
	elseif str == "play_pause" then
		command = command.."PlayPause"
	end
	command = command.." &"
	awful.util.spawn_with_shell(command)
end
dbus.request_name("session", "org.naquadah.awesome.dusi")
dbus.add_match("session", "interface='org.naquadah.awesome.dusi',member='dusi'")
dbus.connect_signal("org.naquadah.awesome.dusi",
function(...)
	local args = {...}
	local method_name = args[2]
	print(args[3])
	if method_name == "dusi" then
		print("dusi")
		dusi_notify(args[3],args[4])
	end
end
)
function dusi_notify(text,mode)
	local function tofont(str,size,bold,font,color)
		local bold = bold
		if bold then
			bold = "bold"
		else
			bold = ""
		end
		local size = size or 15
		local font = font or "Cantarel"
		local color = color or "white"
		local text  = "<span font='"..font.." "..bold.." "..size.."' color='"..color.."'>"..str.."</span>"
		return text
	end
	if text then
		if mode == 0 then
			os.execute('curl --data \'{"id":"twxpzl4s","text":"'..text..'"}\' http://api.dusi.mobi/remote')
		else
			local answer = read_pipe('curl --data \'{"id":"twxpzl4s","text":"'..text..'"}\' http://api.dusi.mobi/remote?reply=true')
			--print(answer,35)
			local status, err= pcall(function() answer=json.decode(answer)end)
			--print(err)
			if status then
				if answer.text then
					text = answer.text
				elseif answer.cancel then
					text = "Отмена"
				else
					text = "нет текста"
				end
				awful.util.spawn_with_shell("~/scripts/saytext.sh 'ru' '"..text.."' fast &")
				naughty.notify({
					text = tofont(text,25,true),
					timeout=5,
					icon="/home/ivn/scripts/dusi_small.png"
				})
				if answer.modal then
					awful.util.spawn("/home/ivn/scripts/dusi_zenity.sh reply")
				end
			end
		end
	end
	set_en()
end
function set_ru()
	local command = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:1"
	--print("ALT_L")
	os.execute(command)
end
function set_en()
	local command = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService ru.gentoo.kbdd.set_layout uint32:0"
	--print("ALTGR")
	os.execute(command)
end
function translator(text_tr)
	--print(text_tr)
	--local text_tr = read_pipe('cat /tmp/translate')
	--local text_tr = lain.helpers.first_line("/tmp/translate")
	--print("-"..text_tr.."-"..#text_tr,2)
	if text_tr and #text_tr > 0 then
		--print(text_tr)
		local lang ="ru:en"
		--print(string.match(text,"[a-zA-Z0-9,.!? ]*"))
		if string.match(text_tr,"[a-zA-Z0-9,.!? ]*") ==text_tr then
			lang ="en:ru"
			awful.util.spawn_with_shell("~/scripts/saytext.sh 'en' '"..text_tr.."' fast &")
		end
		local handle = io.popen("trans -no-ansi "..lang.." '"..text_tr.."'")
		local translation = handle:read("*a")
		handle:close()
		local t ='<span font="Cantarel 18">'..translation.."</span>"
		timenotify = naughty.notify({
			text = t,
			--icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
			timeout = 10,
			screen = mouse.screen or 1
		})
		--return true
		--end, nil,
		awful.util.spawn_with_shell("echo '"..text_tr.."' >> "..awful.util.getdir("cache") .. "/history_translate")
	end
end

globalkeys = awful.util.table.join(

    awful.key({ modkey, "Control"  }, "h", 
		function ()
			if mpdwidget.state == "play" then
				mpd_prev()
			else
				bomicontrol("prev")
			end
		end),
    awful.key({ modkey, "Control" }, "c", 
		function ()
			run_or_raise("cantata",{class="cantata"})
			--if mpdwidget.state == "play" then
				--mpd_stop()
			--else
				--bomicontrol("stop")
			--end
		end),
    awful.key({ modkey, "Control" }, "space", 
    function ()
	    bomicontrol("play_pause")
    end),
    awful.key({ modkey, "Control" }, "r", 
    function ()
	    if not mpdwidget.state == "play" then
		    bomicontrol("pause")
	    --else
		    --bomicontrol("play")
	    end
	    mpd_play_pause()
    end),
    awful.key({ modkey }, "F1", 
    function()
	    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 2")
	    --mpd_next()
    end),
    awful.key({ altgr }, "c", 
    function()
	    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 2")
	    --mpd_next()
    end),
    awful.key({ altgr }, "r", 
    function()
	    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 6")
	    mpd_next()
    end),
    awful.key({ modkey, altgr }, "r", 
    function()
	    local cur_rate = read_pipe('python3 /home/ivn/scripts/rate_current_mpd_song.py get rating')
	    if tonumber(cur_rate) then
		    cur_rate = math.floor(cur_rate/2)
	    else
		    cur_rate = 0
	    end
	    local star = '★'
	    local unstar = '☆'
	    local rate = star:rep(cur_rate)..unstar:rep(5-cur_rate)

	    modal_sc({
		    name="Rate current song "..rate,
		    actions ={
			    {
				    hint="0",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 0")
				    end,
				    desc = "☆☆☆☆☆"
			    },
			    {
				    hint="1",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 2")
				    end,
				    desc = "★☆☆☆☆"
			    },
			    {
				    hint="2",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 4")
				    end,
				    desc = "★★☆☆☆"
			    },
			    {
				    hint="3",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 6")
				    end,
				    desc = "★★★☆☆"
			    },
			    {
				    hint="4",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 8")
				    end,
				    desc = "★★★★☆"
			    },
			    {
				    hint="5",
				    func=function()
					    os.execute("python3 /home/ivn/scripts/rate_current_mpd_song.py set rating 10")
				    end,
				    desc = "★★★★★"
			    },

		    }
	    }
	    )()
    end),
    awful.key({ modkey,           }, "m",
    modal_sc({
	    name="MAIL",
	    actions = {
		    {
			    hint = "m",
			    func = function()
				    local cm = mutt.." /home/ivn/.mutt/Personal'"
				    run_or_raise(cm, { class = "UXTerm" }) 
			    end,
			    desc = "Personal"
		    },
		    {
			    hint = "t",
			    func = function()
				    local cm = mutt.." /home/ivn/.mutt/FateGmail'"
				    run_or_raise(cm, { class = "UXTerm" }) 
			    end,
			    desc = "Gmail"
		    },
	    },
    })
    ),
    awful.key({ modkey, "Control", "Shift" }, "h", 
    function ()
	    mpd_seek_backward()
    end),
    awful.key({ modkey, "Control", "Shift" }, "s", 
    function ()
	    mpd_seek_forward()
    end),
    awful.key({ modkey, "Control" }, "s", 
    function ()
	    if mpdwidget.state == "play" then
		    mpd_next()
	    else
		    bomicontrol("next")
	    end
    end),
    awful.key({ modkey, "Control" }, "n",  apw.up),
    awful.key({ modkey, "Control" }, "t",  apw.down),
    awful.key({ modkey, "Control" }, "m",  apw.togglemute),
    awful.key({ modkey,   }, "Home", 
    function ()
	    mpd_prev()
    end),
    awful.key({ modkey,  }, "End", 
    function ()
	    mpd_stop()
    end),
    awful.key({ modkey,  }, "Insert", 
    function ()
	    mpd_play_pause()
    end),
    awful.key({ modkey,  }, "Delete", 
    function ()
	    mpd_next()
    end),


    awful.key({ modkey,           }, "z",      function () task:toggle() end),
    awful.key({ modkey,           }, "w",      function () mainmenu:show() end),
    awful.key({ modkey,           }, "/",      function () 
	    hidetray:show(mouse.screen) 
	    hidetray.hidetimer:start()
    end),
    --awful.key({ modkey,           }, "Escape", function () exec("/usr/local/sbin/zaprat --toggle") end),
    --awful.key({ modkey            }, "r",      function () mypromptbox[mouse.screen]:run() end),
    -- Run or raise applications with dmenu
    --awful.key({ modkey }, "r", function ()
    --local f_reader = io.popen( "dmenu_path | dmenu -b -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'")
    --local command = assert(f_reader:read('*a'))
    --f_reader:close()
    --if command == "" then return end
    ----run_or_raise(command
    --findme = command
    --firstspace = command:find(" ")
    --if firstspace then
    --findme = command:sub(0, firstspace-1)
    --end
    --local command_class = findme:sub(1,1):upper()..findme:sub(2,-1)
    --run_or_raise(command, { class = command_class })
    --print(command)
    --print(command_class)

    ---- Check throught the clients if the class match the command
    ----local lower_command=string.lower(command)
    ----for k, c in pairs(client.get()) do
    ----local class=string.lower(c.class)
    ----if string.match(class, lower_command) then
    ----for i, v in ipairs(c:tags()) do
    ----awful.tag.viewonly(v)
    ----c:raise()
    ----c.minimized = false
    ----return
    ----end
    ----end
    ----end
    ----awful.util.spawn(command)
    --end),
    awful.key({ modkey 		  }, "r",
    function ()
	    awful.prompt.run({ prompt = "Run: ", },
	    mypromptbox[mouse.screen].widget,
	    function (com)
		    local result = awful.util.spawn(com, { new_tag= {
			    name = 1,
			    exclusive = true,
			    locked = true,
			    volatile = true,
			    selected = true,
			    layout = awful.layout.suit.tile,
		    }})
		    if type(result) == "string" then
			    mypromptbox[mouse.screen].widget:set_text(result)
		    end
		    return true
	    end,
	    awful.completion.shell,
	    awful.util.getdir("cache") .. "/history")
    end),
    --awful.key({ altkey,           }, "t",
    --function ()
    --awful.client.focus.byidx( 1)
    --if client.focus then client.focus:raise() end
    --end),
    --awful.key({ altkey,           }, "n",
    --function ()
    --awful.client.focus.byidx(-1)
    --if client.focus then client.focus:raise() end
    --end),

    awful.key({ modkey, altgr           }, "d",   function ()  
	    local s = (capi.mouse.screen + 1) % (#capi.screen + 1)
	    if s == 0 then
		    s = s + 1
	    end
	    local screengeom = capi.screen[s].workarea
	    moveMouse(math.floor(screengeom.x + screengeom.width / 2), math.floor(screengeom.y + screengeom.height / 2))                    
    end),

    awful.key({ modkey, altgr }, "t",
    function ()
	    --awful.util.spawn('command=$(zenity --entry --text="Russian or English" --title="Translate"); if [ ${#command} -ne 0 ]; then; echo "$command" >> /tmp/translate ; fi')
	    --awful.util.spawn('DISPLAY=:0.0; command=$(zenity --entry --text="Russian or English" --title="Translate"); if [ ${#command} -ne 0 ]; then; echo "$command" >> /tmp/translate ; fi')
	    awful.util.spawn("/home/ivn/scripts/translate_zenity.sh")
	    --trtimer = timer({ timeout = 0.1 })
	    --local n = 0
	    --local text_tr = read_pipe('zenity --entry --text_tr="Russian or English" --title="Translate"')
	    --if text_tr then
	    --print("translate")
	    --local lang ="ru:en"
	    ----print(string.match(text,"[a-zA-Z0-9,.!? ]*"))
	    --if string.match(text,"[a-zA-Z0-9,.!? ]*") ==text then
	    --lang ="en:ru"
	    --end
	    --local translation = read_pipe("trans -no-ansi "..lang.." '"..text.."'")
	    --local t ='<span font="Cantarel 18">'..translation.."</span>"
	    --timenotify = naughty.notify({
	    --text = t,
	    ----icon = "/home/ivn/Загрузки/KFaenzafordark/apps/48/time-admin2.png",
	    --timeout = 10,
	    --screen = mouse.screen or 1
	    --})
	    ----return true
	    ----end, nil,
	    --awful.util.spawn_with_shell("echo '"..text.."' >> "..awful.util.getdir("cache") .. "/history_translate")
	    ----awful.util.spawn_with_shell('rm /tmp/translate')
	    --end
    end),


    -- Tag browsing
    --awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    --awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ modkey }, "j", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ modkey }, "k", function () lain.util.tag_view_nonempty(1) end),

    awful.key({ modkey, "Shift" }, "j",   awful.tag.viewprev       ),
    awful.key({ modkey, "Shift" }, "k",  awful.tag.viewnext       ),




    -- By direction client focus
    awful.key({ modkey }, "t",
    function()
	    --local tag = awful.tag.gettags(capi.mouse.screen)[1]
	    --if awful.tag.selected(capi.mouse.screen) == tag then
	    --awful.client.focus.
	    --else
	    --awful.client.focus.
	    myglobal_bydirection("down")
	    --end
	    if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "n",
    function()
	    --awful.client.focus.
	    myglobal_bydirection("up")
	    if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "h",
    function()
	    --awful.client.focus.
	    myglobal_bydirection("left")
	    if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey}, "s",
    function()
	    --awful.client.focus.
	    myglobal_bydirection("right")
	    if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift" }, "h",
    function()
	    --awful.client.focus.
	    myglobal_bydirection("left",client.focus,true)
	    if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift" }, "s",
    function()
	    --awful.client.focus.
	    myglobal_bydirection("right",client.focus,true)
	    if client.focus then client.focus:raise() end
    end),

    awful.key({ modkey,           }, "Tab",
    function ()
	    awful.client.focus.history.previous()
	    if client.focus then
		    client.focus:raise()
	    end
    end),
    --awful.key({ modkey,         }, "Tab", function(c)
	    --cyclefocus.cycle(1, {modifier="Super_L"})
	    --end),
	    --awful.key({ modkey, "Shift" }, "Tab", function(c)
	    --cyclefocus.cycle(-1, {modifier="Super_L"})
	    --end),
	    --awful.key({ modkey,         }, "Tab", 
	    --function ()
	    --awful.client.focus.byidx( 1)
	    --if client.focus then client.focus:raise() end
	    --end),
	    --awful.key({ modkey, "Shift" }, "Tab", 
	    --function ()
	    --awful.client.focus.byidx( -1)
	    --if client.focus then client.focus:raise() end
	    --end),
	    awful.key({ modkey, "Control" }, "Delete",      awesome.restart),
	    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),
	    awful.key({ modkey,           }, "Return", function () exec(terminal) end),
	    awful.key({ modkey, "Control" }, "Return", 
	    function () 
		    os.execute(locknow)
		    bomicontrol("pause")
	    end),
	    --awful.key({ modkey,           }, "t",      function () exec(tmux) end),
	    --awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1) end),
	    awful.key({ modkey,           }, "space",  function () hintsetter:focus({screen = capi.mouse.screen}) end),
	    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1) end),
	    --awful.key({ modkey            }, "a",      function () shexec(configuration) end),
	    awful.key({ modkey }, ":", function () 
		    cheeky.util.switcher()
		    --hints.focus() 
	    end),
	    awful.key({ modkey,    }, "i", im),
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
						    set_ru()
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
						    set_ru()
						    rutimer:stop()
					    end)
					    rutimer:start()
				    end
			    }
		    }
	    })
	    ),
	    awful.key({ modkey, "Control" }, "i", 
	    function ()
		    local tag = awful.tag.gettags(1)[2]
		    awful.tag.viewonly(tag)
		    hints.focus(1)
	    end),
	    awful.key({ modkey,    }, "o",  
	    task.done_modify(modal_sc)
	    ),
	    awful.key({ modkey,    }, "a",  
	    function () 
		    revelation({
			    rule={class="Pidgin"}, 
			    is_excluded=true
		    }) 
	    end),
	    awful.key({ modkey, "Shift" }, "b",  
	    function () 
		    hintsetter:newtag({
			    screen = capi.mouse.screen,
		    })
		    --newtag({
		    --rule={class="Pidgin"}, 
		    --is_excluded=true,
		    --screen = {capi.mouse.screen}
		    --}) 
	    end),
	    awful.key({ modkey,    }, "b",  
	    function () 
		    hintsetter:newtag({
			    screen = capi.mouse.screen,
			    only = true,
		    })
		    --newtag({
		    --rule={class="Pidgin"}, 
		    --is_excluded=true,
		    --screen = {capi.mouse.screen}
		    --}) 
	    end),
	    awful.key({ modkey, "Control"   }, "b",  
	    function () 
		    local cl = client.focus
		    local actions = {}
		    if cl.class == "Firefox" then
			    local title = cl.name:split(" ")
			    --print(cl.name:gmatch("http%S+"))
			    local url
			    for i,k in pairs(title) do
				    if k:find("http") then
					    url = k
				    end
			    end
			    if url then
				    table.insert(actions,{
					    hint = "b",
					    desc = "Open in player",
					    func = function()
						    os.execute('/usr/bin/bomi --wake --open "'..url..'" &')
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


	    awful.key({ modkey            }, "@",      function ()
		    hintsetter:togglefromtag()
	    end),
	    awful.key({ modkey            }, "x",      function ()
		    local tag = awful.tag.selected()
		    local clients = tag:clients()
		    for i,c in pairs(clients) do
			    local tags = c:tags()
			    if #tags==1 then
				    c:tags({awful.tag.gettags(c.screen)[1]})
			    end
		    end
		    awful.tag.delete()--tag,awful.tag.gettags(tag.screen or 1)[1])
	    end),
	    --awful.key({ modkey,           }, "u",      function () exec("urxvt -geometry 254x60+80+60") end),
	    --awful.key({ modkey,           }, "s",      function () exec(filemanager) end),
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
	    awful.key({ }, "XF86AudioRaiseVolume",  apw.up),
	    awful.key({ }, "XF86AudioLowerVolume",  apw.down),
	    awful.key({ }, "XF86AudioMute",         apw.togglemute),
	    awful.key({ }, "XF86Sleep",         function () exec("systemctl suspend") end),
	    awful.key({ }, "XF86Explorer",      function () exec("systemctl suspend") end),
	    awful.key({ }, "XF86PowerOff",      
	    function ()
		    exec("systemctl suspend")
		    --exec(locknow)
		    --bomicontrol("pause")
	    end),
	    awful.key({modkey		  }, "F12",      function () exec("systemctl suspend") end),
	    --awful.key({ modkey, "Control" }, "m",      function () shexec(ncmpcpp) end),
	    --awful.key({ modkey, "Control" }, "f",      function () shexec(newsbeuter) end),
	    -- Dropdown terminal
	    --awful.key({ modkey,	          }, "i",      function () drop(terminal) end), 
	    awful.key({ modkey, "Control" }, "u",      function () 
		    awful.util.spawn_with_shell("tmux new -d -s dropdown") 
		    scratch.drop(dropdownterm) end), 
		    awful.key({ modkey,	          }, "u",      function () 
			    awful.util.spawn_with_shell("tmux new -d -s dropdown") 
			    scratch.drop(dropdownterm) end), 
			    --awful.key({ modkey,	          }, "u",      function () drop(terminal) end), 
			    awful.key({ modkey, "Control"  }, "x",      function () exec("/home/ivn/scripts/trackpoint/trackpointkeys.sh switch &") end),
			    awful.key({ modkey,  }, "Left",     function() brightnessdec() end),
			    awful.key({ modkey,  }, "Right",    function() brightnessinc() end),
			    awful.key({ modkey,altgr  }, "h",   function() brightnessdec() end),
			    awful.key({ modkey,altgr  }, "s",   function() brightnessinc() end),
			    awful.key({ altgr  }, "Alt_L",   set_ru),
			    awful.key({ altkey  }, "ISO_Level3_Shift",   set_en),
			    awful.key({ modkey,       }, "q",   function (c) if client.focus then client.focus:kill() end                        end),

			    --{ awful.key({ modkey, }, "k", function () quake.toggle({ terminal = "termite",
			    --			name = "QuakeTermite",
			    --			height = 0.5,
			    --			skip_taskbar = true,
			    --			ontop = true })
			    --	end)
			    -- awful.key({ modkey            }, "Pause",  function () exec("VirtualBox --startvm 'a8d5ac56-b0d2-4f7f-85be-20666d2f46df'") end)
			    --awful.key({ modkey }, ",",
			    --function ()
				    --awful.util.spawn_with_shell('command=$(zenity --entry --text="Команда для Дуси"); if [ ${#command} -ne 0 ]; then; echo $command >> /home/ivn/Dropbox/phone/dusiacommand ; fi')
			    --end),
			    awful.key({ modkey }, "l",
			    function ()
				    awful.prompt.run({ prompt = "Run Lua code: " },
				    mypromptbox[mouse.screen].widget,
				    awful.util.eval, nil,
				    awful.util.getdir("cache") .. "/history_eval")
			    end)
			    )

			    clientkeys = awful.util.table.join(
			    --awful.key({ modkey            }, "Next",   function () awful.client.moveresize( 20,  20, -40, -40) end),
			    --awful.key({ modkey            }, "Prior",  function () awful.client.moveresize(-20, -20,  40,  40) end),
			    --awful.key({ modkey            }, "Down",   function () awful.client.moveresize(  0,  20,   0,   0) end),
			    --awful.key({ modkey            }, "Up",     function () awful.client.moveresize(  0, -20,   0,   0) end),
			    --awful.key({ modkey            }, "Left",   function () awful.client.moveresize(-20,   0,   0,   0) end),
			    --awful.key({ modkey            }, "Right",  function () awful.client.moveresize( 20,   0,   0,   0) end),
			    awful.key({ modkey,           }, "d",      function (c) 
				    awful.client.movetoscreen(c)
				    client.focus = c
				    c:raise()
			    end),
			    --awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
			    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
			    awful.key({ modkey,           }, "-",
			    function (c)
				    c.minimized = not c.minimized
			    end)
			    --,
			    --awful.key({ modkey,           }, "m",
			    --function (c)
			    --c.maximized_horizontal = not c.maximized_horizontal
			    --c.maximized_vertical   = not c.maximized_vertical
			    --end)
			    )

			    for i = 1, 9 do
				    globalkeys = awful.util.table.join(globalkeys,
				    awful.key({ modkey }, "#" .. i + 9,
				    function ()
					    local screen = mouse.screen
					    local tag = awful.tag.gettags(screen)[i]
					    if tag then
						    awful.tag.viewonly(tag)
					    end
				    end),
				    awful.key({ modkey, "Control" }, "#" .. i + 9,
				    function ()
					    local screen = mouse.screen
					    local tag = awful.tag.gettags(screen)[i]
					    if tag then
						    awful.tag.viewtoggle(tag)
					    end
				    end),
				    awful.key({ modkey, "Shift" }, "#" .. i + 9,
				    function ()
					    if client.focus then
						    local tag = awful.tag.gettags(client.focus.screen)[i]
						    if tag then
							    awful.client.movetotag(tag)
						    end
					    end
				    end),
				    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
				    function ()
					    if client.focus then
						    local tag = awful.tag.gettags(client.focus.screen)[i]
						    if tag then
							    awful.client.toggletag(tag)
						    end
					    end
				    end))
			    end

			    clientbuttons = awful.util.table.join(
			    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
			    awful.button({ modkey }, 1, awful.mouse.client.move),
			    awful.button({ modkey }, 3, awful.mouse.client.resize),
			    awful.button({ modkey, "Control" }, 4, apw.up),
			    awful.button({ modkey, "Control" }, 5, apw.down))

			    awful.menu.menu_keys = {
				    up    = { "n", "Up" },
				    down  = { "t", "Down" },
				    exec  = { "l", "Return", "Space" },
				    enter = { "s", "Right" },
				    back  = { "h", "Left" },
				    close = { "q", "Escape" }
			    }

			    root.keys(globalkeys)

			    -- | Rules | --

			    awful.rules.rules = {
				    { rule = { },
				    properties = { border_width = beautiful.border_width,
				    border_color = beautiful.border_normal,
				    focus = awful.client.focus.filter,
				    size_hints_honor = false,
				    raise = true,
				    keys = clientkeys,
				    buttons = clientbuttons } },

				    { rule = { class = "Exe"}, properties = {floating = true} },
				    { rule = { class = "Plugin-container" },
				    properties = { floating = true, focus = true} },
				    --{ rule = { class = "gcolor2" },
				    --properties = { floating = true } },
				    --{ rule = { class = "xmag" },
				    --properties = { floating = true } },

				    { rule = { class = "Pavucontrol" },
				    properties = { floating = true, intrusive = true } },

				    { rule = { class = "veromix" },
				    properties = { floating = true, intrusive = true } },

				    { rule = { name = "Громкость" },
				    properties = { floating = true, intrusive = true } },

				    { rule = { class = "Vlc" },
				    properties = { floating = true } },
				    { rule = { role = "HTOP_CPU" },
				    properties = { floating = true, intrusive = true} },
				    { rule = { role = "HTOP_MEM" },
				    properties = { floating = true, intrusive = true } },

				    --{ rule = { class = "gvim" },
				    --properties = { tag = tags[1][2], switchtotag = true}},
				    --{ rule = { class = "Thunderbird" },
				    --properties = { tag = tags[4] } }, 
				    --{ rule = { class = "Gvim"},
				    --properties = { tag = tags[1][2], switchtotag = true}},
				    --{ rule = { class = "Firefox"},
				    --properties = { tag = tags[1][5], switchtotag = true}},
				    { rule = { class = "Pidgin", role = "conversation"},
				    callback = function(c)
					    if not (c.name == "Dusi") then
						    c:connect_signal("unfocus",function(c)
							    im.lastpidgin = c
						    end)
					    end
				    end
			    },
				    { rule = { class = "TelegramDesktop"},
				    callback = function(c)
					    im.lastpidgin = c
					    c:connect_signal("unfocus",function(c)
						    im.lastpidgin = c
					    end)
					    awful.client.setslave(c)
					    c:connect_signal("property::name",function(c)
						    if c.name:find("Telegram ") then
							    c.urgent = true
						    else
							    c.urgent = false
						    end
					    end)
				    end
			    },
			    { rule = { class = "Pidgin", role = "buddy_list"},
			    properties = { tag = awful.tag.gettags(1)[2], switchtotag = false, no_autofocus = true }},
			    { rule = { class = "Pidgin", role = "conversation"},
			    properties = { tag = awful.tag.gettags(1)[2], switchtotag = false, no_autofocus = true },
			    callback = awful.client.setslave },
			    {rule = {role = "DROPDOWN"}, 
			    properties = {opacity = 0.8}},
			    --{rule = {class = "bomi"}, 
			    --properties = {opacity = 1, floating = true, ontop = true} }
			    { rule = { class = "c2gQtCon_x"},
			    properties = { floating = true}
		    },
		    { rule = { class = "gui_contactbook.py"},
		    properties = { floating = true}
	    },
	    { rule = { class = "factorio"},
	    --properties = { 
	    --}
	    callback = function(c)
		    --c:connect_signal("manage",function(c)
		    print("closing factorio", 10)
		    closetimer = timer({ timeout = 0.1 })
		    closetimer:connect_signal("timeout", function ()
			    c:kill()
			    os.execute("pkill factorio")
			    closetimer:stop()
		    end)
		    closetimer:start()
		    --end)
	    end
    },
    { rule = { class = "Skype", role = "CallWindow"},
    properties = { opacity = 0.8, switchtotag = false, no_autofocus = true, floating = true, ontop = true, sticky = true  },
    callback = function(c)
	    local scrgeom = capi.screen[capi.mouse.screen].geometry
	    local clgeom  = c:geometry({width = scrgeom.width/10, height = scrgeom.width/10})
	    local clgeom  = c:geometry({x = scrgeom.x + scrgeom.width - clgeom.width, y = scrgeom.y + scrgeom.height - clgeom.height}) 
	    c:connect_signal("property::fullscreen",function(c)
		    if c.fullscreen then
			    c.opacity = 1
			    c.floating = false
			    c.ontop = false
		    else
			    c.opacity = 0.8
			    c.floating = true
			    c.ontop = true
		    end
	    end)
    end
	},
	{ rule = { class = "bomi"},
	properties = { opacity = 0.8, switchtotag = false, no_autofocus = true, floating = true, ontop = true, sticky = true  },
	callback = function(c)

		local scrgeom = capi.screen[capi.mouse.screen].geometry
		local clgeom  = c:geometry({width = scrgeom.width/5, height = scrgeom.height/5})
		local clgeom  = c:geometry({x = scrgeom.x + scrgeom.width - clgeom.width, y = scrgeom.y + scrgeom.height - clgeom.height}) 
		c:connect_signal("property::fullscreen",function(c)
			if c.fullscreen then
				c.opacity = 1
				c.floating = false 
				c.ontop = false
				c.sticky = false
			else
				c.opacity = 0.8
				c.floating = true
				--c.ontop = true
				c.sticky = true
			end
		end)
	end
}

}

-- | Signals | --

local function timemute()
	awful.util.spawn_with_shell("rm /tmp/timemute>/dev/null || touch /tmp/timemute")
end


lastmpdstatus = "N/A"
local function playif()
	if lastmpdstatus and lastmpdstatus == "play" then
		mpd_play()
	end
end
local function pauseif()
	lastmpdstatus = mpdwidget.state
	mpd_pause()
end

client.connect_signal("unmanage",
function(c)
	if c.class then 
		if c.class == "bomi" then
			playif()
		elseif c.class == "Evolution-alarm-notify" then
			local notif = naughty.notify({ 
				title = "ALARM NOTIFY",
				bg = beautiful.bg_normal,
				text = "DO IT!!!",
				timeout = 25})
			end
		end
	end
	)
	dbus.request_name("session", "org.mpris.MediaPlayer2")
	dbus.add_match("session", "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
	dbus.connect_signal("org.freedesktop.DBus.Properties", function(...)
		local data = {...}
		local status = data[3].PlaybackStatus
		if status == "Playing" then
			pauseif()
		elseif status == "Paused" then
			playif()
		end
		--for i,str in pairs(data) do
		--print(i.." "..tostring(str))
		--if type(str) == "table" then
		--for k,n in pairs(str) do
		--print(k.." "..tostring(n))
		--end
		--end
		--end
	end
	)

	local function checkclass(class)
		local table = {"Virtualbox","Bomi"}
		for i,n in pairs(table) do
			if n == class then
				return false
			end
		end
		return true
	end
	local fullscreened_clients = {}

	local function remove_client(tabl, c)
		local index = awful.util.table.hasitem(tabl, c)
		if index then
			table.remove(tabl, index)
			if #tabl == 0 then
				awful.util.spawn("xset s off")
				awful.util.spawn("xset -dpms")
				os.execute("xautolock -enable")

				if checkclass(c.class) then
					timemute()
					playif()
				end
			end             
		end
	end

	client.connect_signal("property::fullscreen",
	function(c)
		if c.fullscreen then
			table.insert(fullscreened_clients, c)
			if #fullscreened_clients == 1 then
				awful.util.spawn("xset s off")
				awful.util.spawn("xset -dpms")
				--naughty.suspend()
				os.execute("xautolock -disable")
				if checkclass(c.class) then
					pauseif()
					timemute()
				end
			end
		else
			remove_client(fullscreened_clients, c)
		end
	end)

	client.connect_signal("untagged",
	function(c,t)
		--for i,t in pairs(c.tags(c)) do
		local del = true
		for _,n in pairs(tagnames) do
			if t.name == n then
				del = false
			end
		end
		if del and #(t:clients()) < 2 then
			awful.tag.delete(t)
		end
		--end

	end)
	client.connect_signal("unmanage",
	function(c)
		if c.fullscreen then
			remove_client(fullscreened_clients, c)
		end
		--print("check tags")
		for i,t in pairs(c.tags(c)) do
			--print(i.." "..t.name)
			del = true
			for _,n in pairs(tagnames) do
				if t.name == n then
					del = false
				end
			end
			--print(del)
			if del and #t:clients() < 2 then
				awful.tag.delete(t)
			end
		end

	end)

	client.connect_signal("manage", function (c, startup)
		c:connect_signal("mouse::enter", function(c)
			if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
				and awful.client.focus.filter(c) then
				client.focus = c
			end
		end)

		if not startup then
			if not c.size_hints.user_position and not c.size_hints.program_position then
				awful.placement.no_overlap(c)
				awful.placement.no_offscreen(c)
			end
		end

		local titlebars_enabled = true
		if titlebars_enabled and (c.type == "dialog") then  --{ c.type == "normal" or 
			local buttons = awful.util.table.join(
			awful.button({ }, 1, function()
				client.focus = c
				c:raise()
				awful.mouse.client.move(c)
			end),
			awful.button({ }, 3, function()
				client.focus = c
				c:raise()
				awful.mouse.client.resize(c)
			end)
			)

			local left_layout = wibox.layout.fixed.horizontal()
			left_layout:add(awful.titlebar.widget.iconwidget(c))
			left_layout:buttons(buttons)

			local right_layout = wibox.layout.fixed.horizontal()
			right_layout:add(awful.titlebar.widget.floatingbutton(c))
			right_layout:add(awful.titlebar.widget.maximizedbutton(c))
			right_layout:add(awful.titlebar.widget.stickybutton(c))
			right_layout:add(awful.titlebar.widget.ontopbutton(c))
			right_layout:add(awful.titlebar.widget.closebutton(c))

			local middle_layout = wibox.layout.flex.horizontal()
			local title = awful.titlebar.widget.titlewidget(c)
			title:set_align("center")
			middle_layout:add(title)
			middle_layout:buttons(buttons)

			local layout = wibox.layout.align.horizontal()
			layout:set_left(left_layout)
			layout:set_right(right_layout)
			layout:set_middle(middle_layout)

			awful.titlebar(c):set_widget(layout)
		end
	end)

	unfocusable = {
		{
			class="com-eteks-sweethome3d-SweetHome3DBootstrap"
		},
		{
			class="x-sweethome3d"
		}, 
		{
			class="sun-awt-X11-XFramePeer"
		},
		{
			class="Firefox",
			type="utility"
		}
	}
	mousetimer = timer({ timeout = 0.1 })
	function moveMouse(x_co, y_co)
		mousetimer:stop()
		mousetimer = timer({ timeout = 0.1 })
		mousetimer:connect_signal("timeout", function ()
			mouse.coords({ x=x_co, y=y_co })
			mousetimer:stop()
		end)
		mousetimer:start()
	end
	client.connect_signal("focus", function(c) 
		local screengeom = capi.screen[mouse.screen].workarea
		for _,s in pairs(unfocusable) do
			local continue=true
			for name,value in pairs(s) do
				if not (c[name] == value) then
					continue=false
					--else
					--print({name,value})
				end
			end
			--if c.class == s then
			if continue then
				return
			end
		end
		if mouse.coords().y > screengeom.y then
			if not (c == mouse.object_under_pointer()) then
				geom=c.geometry(c)
				if c.class=="TelegramDesktop" then
					x=geom.x+math.modf(geom.width/2)--+1
					y=geom.y+math.modf(geom.height/30)--+1
				else
					x=geom.x+math.modf(geom.width/2)--+1
					y=geom.y+math.modf(geom.height/2)--+1
				end

				moveMouse(x,y)
				--client.foucs = c
			end
		end
	end)

	keysmode = "normalmode"
	trackpointnotify = nil
	browserclients = {"Firefox", "Thunderbird", "Vivaldi-snapshot", "Palemoon", "Chromium","Google-chrome","google-chrome"}
	normalclients = {}
	commandclients = {}
	client.connect_signal("manage", function(c) 
		--if  not c.maximized_horizontal then
		--c.border_color = beautiful.border_focus 
		--end
		local mode = "normalmode"
		for _,s in pairs(browserclients) do
			if c.class == s then
				mode = "browsermode"
			end
		end
		for _,s in pairs(normalclients) do
			if c.class == s then
				mode = "normalmode"
			end
		end
		for _,s in pairs(commandclients) do
			if c.class == s then
				mode = "commandmode"
			end
		end
		c:connect_signal("focus", function(cl)
			if mode ~= keysmode then
				keysmode = mode
				os.execute("/home/ivn/scripts/trackpoint/trackpointkeys.sh "..keysmode.." &")
				naughty.destroy(trackpointnotify, true)
				trackpointnotify = naughty.notify({
					title = "TrackPoint Keys",
					text = keysmode,
					icon = "/home/ivn/scripts/trackpoint/"..keysmode..".png",
					timeout = 2,
					screen = mouse.screen or 1
				})
			end
		end)
	end)

	client.connect_signal("manage", function(c) 
		taglist = awful.tag.gettags(c.screen)
		tag = taglist[1]
		for i,t in pairs(c.tags(c)) do
			if t == taglist[2] then
				--print(t.name)
				return true
			end
			if t == tag then
				return true
			end
		end
		awful.client.toggletag(tag,c)
		return true
	end)
	--client.connect_signal("unfocus", function(c) 
	--c.border_color = beautiful.border_normal 
	----	if awful.rules.match(c, {class = "Firefox"}) then  	end
	--end)


	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {class = "veromix"}) then  
	--c:kill()
	--apw.Update()
	--end

	--end)
	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {class = "Pavucontrol"}) then  
	--c:kill()
	--apw.Update()
	--end

	--end)
	--client.connect_signal("manage", function(c) 
	--if awful.rules.match(c, {class = "veromix"}) then  
	--awful.placement.under_mouse(c)
	--c:geometry( {y = 22 } )
	--end

	--end)

	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {role = "HTOP_CPU"}) then  
	--c:kill()
	--end

	--end)
	--client.connect_signal("manage", function(c) 
	--if awful.rules.match(c, {role = "HTOP_CPU"}) then  
	--awful.placement.under_mouse(c)
	--c:geometry( {y = 22 } )
	--end
	--end)
	--client.connect_signal("unfocus", function(c) 
	--if awful.rules.match(c, {role = "HTOP_MEM"}) then  
	--c:kill()
	--end

	--end)
	--client.connect_signal("manage", function(c) 
	--if awful.rules.match(c, {role = "HTOP_MEM"}) then  
	--awful.placement.under_mouse(c)
	--c:geometry( {y = 22 } )
	--end
	--end)
	tag.connect_signal("property::selected", function(t)
		if t.name == tagnames[2] and not t.selected and #awful.tag.selectedlist() == 0 then
			awful.tag.viewonly(awful.tag.gettags(1)[1])
		end
	end)

	function brightnessdec() 
		for i,k in pairs(screen[mouse.screen].outputs) do
			if (i == "HDMI1") or (i == "HDMI-0")  then
				local sh = io.popen("xrandr --verbose | grep -A 5 -i HDMI | grep -i brightness | cut -f2 -d ' '")
				if sh == nil then
					return false
				end
				local br = tonumber(sh:read("*a"))
				sh.close()
				if br < 0 then
					br = 0
				end
				br = br - 0.05
				if br < 0 then
					br = 0
				end
				if br > 1 then
					br = 1
				end
				os.execute("xrandr --output "..i.." --brightness "..br)
				--naughty.notify({title = i})
			elseif (i == "LVDS1") or (i == "LVDS") then
				--naughty.notify({title = i})
				exec("xbacklight -dec 10")
			end
		end
	end
	function brightnessinc() 
		for i,k in pairs(screen[mouse.screen].outputs) do
			if (i == "HDMI1") or (i == "HDMI-0")  then
				local sh = io.popen("xrandr --verbose | grep -A 5 -i HDMI | grep -i brightness | cut -f2 -d ' '")
				if sh == nil then
					return false
				end
				local br = tonumber(sh:read("*a"))
				sh.close()
				if br < 0 then
					br = 0
				end
				br = br + 0.05
				if br < 0 then
					br = 0
				end
				if br > 1 then
					br = 1
				end
				os.execute("xrandr --output "..i.." --brightness "..br)
			elseif (i == "LVDS1") or (i == "LVDS") then
				--naughty.notify({title = i})
				exec("xbacklight -inc 10")
			end
		end
	end
	-- | run_once | --

	function run_once(cmd)
		findme = cmd
		firstspace = cmd:find(" ")
		if firstspace then
			findme = cmd:sub(0, firstspace-1)
		end
		awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
	end

	-- | Autostart | --
	--autostarttimer = timer({ timeout = 2 })
	--autostarttimer:connect_signal("timeout", function ()
	local start_on_thinkpad = {
		"xset s on",
		"xset +dpms",
	}

	local ex = {
		--"pkill compton",
		--"pkill pidgin; pidgin &",
		"pkill kbdd; kbdd &",
		"pkill xcape",
		"setxkbmap 'my(dvp),my(rus)' &",
		--"setxkbmap 'my(dvp),my(rus)' setxkbmap -option grp:caps_toggle,grp_led:caps -print | xkbcomp - $DISPLAY; xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY &",
		--"xkbcomp $HOME/.config/xkb/my $DISPLAY &",
		"/home/ivn/scripts/trackpoint/trackpointkeys.sh normalmode &",
		"xset s off",
		"xset -dpms",
		"xset m 1/2 4",
		"pkill dropbox",
		--"dropbox &",
		"xinput disable 'SynPS/2 Synaptics TouchPad'",
		"xrdb -merge ~/.Xresources &",
		'xcape -t 1000 -e "Control_L=Tab;ISO_Level3_Shift=Multi_key"',
		"xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY"
	}
	local run = {
		"linconnect-server &",
		--"kbdd",
		"mpd /home/ivn/.config/mpd/mpd.conf",
		--"mpdscribble",
		"udiskie --tray &",
		--"nm-applet",
		--"pa-applet",
		"qbittorrent --style=gtk+",
		"redshiftgui",
		--"indicator-kdeconnect",
		"dropbox",
		--"thunderbird",
		--"parcellite",
		"pidgin",
		"env QT_IM_MODULE=xim telegram-desktop",
		--"telegram-desktop",
		"compton --config /home/ivn/.config/compton.conf -b &",
		--"pactl load-module module-loopback source=2 sink=0",
		xautolock,
		browser,
		"perl /usr/share/cantata/scripts/cantata-dynamic start",
		--"evolution",
		--"goldendict --style gtk+",
	}

	for i,k in pairs(ex) do
		os.execute(k)
	end
	for i,k in pairs(run) do
		run_once(k)
	end
	if hostname == "Thinkpad" then
		appsuspender:add({
			timeout = 1,
			minimize = false,
			unfocus = true,
			blacklist = {
				"qBittorrent",
				"Pidgin",
			}
		})
		for i,k in pairs(start_on_thinkpad) do
			os.execute(k)
		end
	end

	--autostarttimer:stop()
	local notif = naughty.notify({ preset = naughty.config.presets.critical,
	title = "Awesme start correct, though...",
	bg = beautiful.bg_normal,
	text = awesome.startup_errors,
	timeout = 2,
	position = "top_left"})
	--end)
	--autostarttimer:start()


	xkbtimer = timer({ timeout = 2000 })
	xkbtimer:connect_signal("timeout", function ()
		awful.util.spawn_with_shell("xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY")
	end)
	xkbtimer:start()


	--print(notif.box)
