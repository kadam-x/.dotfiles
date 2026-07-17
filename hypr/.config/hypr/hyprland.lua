local mainMod = "SUPER"
local terminal = "foot"

------------------
---- MONITORS ----
------------------
hl.monitor({
	output = "DP-1",
	mode = "2560x1440@240",
	position = "0x0",
	scale = "auto",
})

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = "auto",
})

hl.config({
	animations = {
		enabled = false,
	},
})

---------------
---- INPUT ----
---------------
hl.config({
	input = {
		kb_layout = "us,hu",
		kb_options = "grp:win_space_toggle",

		repeat_rate = 35,
		repeat_delay = 200,

		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
		},
	},
})

hl.config({
	input = {
		accel_profile = "flat",
	},
})

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 0,

		col = {
			active_border = "rgba(ffffffff)",
			inactive_border = "rgba(595959aa)",
		},
	},
	decoration = {
		active_opacity = 1.0,
		dim_inactive = true,
		dim_strength = 0.35,
	},
	dwindle = {
		force_split = 2,
		preserve_split = true,
	},
})

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)

hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("qs ipc call emojipicker toggle"))

-- Audio
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))

-- Apps
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("foot --app-id yazi -e yazi"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("bash ~/.local/bin/scripts/sessionizer.sh"))
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd(
		"sh -c 'grim -g \"$(slurp)\" - | tee ~/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png | wl-copy'"
	)
)
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs ipc call wallpapers toggle"))

-- Window management
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "right" }))

-- Hyprland's relative resize on the active window covers this directly.
hl.bind(mainMod .. " + H", hl.dsp.window.resize({ x = -350, y = 0, relative = true }))
hl.bind(mainMod .. " + L", hl.dsp.window.resize({ x = 350, y = 0, relative = true }))

hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "right" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + CTRL + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + CTRL + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + CTRL + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + CTRL + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + CTRL + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + CTRL + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = 10 }))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	name = "float-wiremix",
	match = { class = "wiremix" },
	float = true,
	size = "800 600",
	center = true,
})

hl.window_rule({
	name = "float-yazi",
	match = { class = "yazi" },
	float = true,
	size = "1200 1000",
	center = true,
})

hl.window_rule({
	name = "float-qbittorrent",
	match = { class = "org.qbittorrent.qBittorrent" },
	float = true,
	size = "800 600",
	center = true,
})

hl.window_rule({
	name = "float-swayimg",
	match = { class = "swayimg" },
	float = true,
})

hl.window_rule({
	match = { class = "obsidian" },
	workspace = "current",
})

hl.window_rule({
	match = { class = "anki" },
	workspace = "current",
})
-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("qbittorrent --no-splash")
	hl.exec_cmd("qs")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("hypridle")
end)
