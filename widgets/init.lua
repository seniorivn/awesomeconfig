local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")
local wrequire     = require("lain.helpers").wrequire
local setmetatable = setmetatable
local widgets = { _NAME = "widgets" }
widgets.spr = wibox.widget.imagebox()
widgets.spr:set_image(beautiful.spr)
widgets.spr4px = wibox.widget.imagebox()
widgets.spr4px:set_image(beautiful.spr4px)
widgets.spr5px = wibox.widget.imagebox()
widgets.spr5px:set_image(beautiful.spr5px)
widgets.bg = beautiful.bg_normal
widgets.fg = beautiful.fg_normal
widgets.text_size = 9
--widgets.font = "Tamsyn"
widgets.font = "Termsyn"
widgets.critical = "#bd6873"
widgets.task_waiting = "#A57F83"
widgets.green = "#24B224"
--widgets.font = "Terminus 10"


widgets.space3 = lain.util.markup.font("Terminus 3", " ")
widgets.space2 = lain.util.markup.font("Terminus 2", " ")
widgets.vspace1 = '<span font="Terminus 3"> </span>'
widgets.vspace2 = '<span font="Terminus 3">  </span>'
widgets.clockgf = beautiful.clockgf

function widgets.set_markup(widget,text,args)
	local args = args or {}
	local font = args.font or widgets.font 
	local text_size = args.text_size or widgets.text_size
	local bold = args.bold or "normal"
	local text = lain.util.markup.font(font.." "..math.floor(text_size/2.5), " ")..'<span font="'..font.." "..text_size..'" weight="'..bold..'">'..text..'</span>'.. lain.util.markup.font(font.." "..math.floor(text_size/2.5), " ")
	if widget then
		widget:set_markup(text)
	else
		return text
	end
end

widgets.display = wibox.widget.imagebox()
widgets.display:set_image(beautiful.widget_display)
widgets.display_r = wibox.widget.imagebox()
widgets.display_r:set_image(beautiful.widget_display_r)
widgets.display_l = wibox.widget.imagebox()
widgets.display_l:set_image(beautiful.widget_display_l)
widgets.display_c = wibox.widget.imagebox()
widgets.display_c:set_image(beautiful.widget_display_c)
local function worker(args)
	local layout = args.layout or wibox.layout.fixed.horizontal()
	local spr = args.spr or widgets.spr
	layout:add(spr)
	if args.image then
		local widget_image = wibox.widget.imagebox()
		widget_image:set_image(args.image)
		layout:add(widget_image)
	end
	if args.text then
		local widget_text = wibox.widget.textbox()
		--widget_text:set_markup( lain.util.markup.font("Terminus 4", " ")..'<span font="Terminus 10" weight="bold">'..args.text..'</span>'.. lain.util.markup.font("Terminus 4", " "))
		widgets.set_markup(widget_text,args.text,{font="Terminus",text_size=10,bold="bold"})
		layout:add(widget_text)
	end
	if args.widgets then
		for i,k in pairs(args.widgets) do
			layout:add(k)
		end
	end

	if args.textboxes then

		layout:add(widgets.display_l)
		for i,k in pairs(args.textboxes) do
			if i > 1 then 
				layout:add(widgets.display_c)
			end
			local background = wibox.container.background()
			background:set_widget(k)
			background:set_bgimage(beautiful.widget_display)
			layout:add(background)
		end
		layout:add(widgets.display_r)
	end
	layout:add(widgets.spr5px)
	return layout
end


return setmetatable(widgets, {__index = wrequire, __call = function(_,...) return worker(...) end})
