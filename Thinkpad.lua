local widgets = require("widgets")

local config = {}
config.widgets = {}
config.widgets.battery = widgets.battery()
config.cpu_tmpfile = "/sys/class/hwmon/hwmon2/device/temp3_input"
config.wired_interface = "enp2s0"
config.wireless_interface = "wlp0s18f2u3"
config.autostart = {}
config.disk_type = "HDD"
config.automount = true
config.im_width = 0.3
config.widgets_text_size = 8
config.autostart.execute = {
	"xset s on",
	"xset +dpms",
	"xinput disable 'SynPS/2 Synaptics TouchPad'",
}
config.autostart.run_once = {

}
return config
