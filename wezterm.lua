-- Pull in the wezterm API
local wezterm = require("wezterm")
local background = require("background")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Your personal settings
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 10
config.font = wezterm.font("JetBrains Mono")

-- Set color scheme based on system appearance
config.color_scheme = background.get_color_scheme()

-- Background configuration
config.background = background.get_background()

-- Optional opacity for better text readability
config.text_background_opacity = 1

-- Window decorations and titlebar settings
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_style = "Windows"
config.integrated_title_button_color = "Auto"
config.integrated_title_button_alignment = "Right"

-- Tab bar configuration to match background
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

-- Tab styling to blend with background (adapts to system appearance)
config.colors = {
	tab_bar = background.get_tab_bar_colors(),
}

-- Window background opacity to ensure background shows through titlebar
config.window_background_opacity = 1.0

-- Key bindings
config.keys = {
	-- CMD+J to cycle wallpaper manually
	{
		key = "j",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			background.cycle_wallpaper()
			-- Force immediate update
			local overrides = window:get_config_overrides() or {}
			overrides.background = background.get_background()
			window:set_config_overrides(overrides)
		end),
	},
	-- CMD+SHIFT+J to reset to automatic wallpaper cycling
	{
		key = "J",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			background.reset_wallpaper_auto()
			-- Force immediate update
			local overrides = window:get_config_overrides() or {}
			overrides.background = background.get_background()
			window:set_config_overrides(overrides)
		end),
	},
}

-- Auto-reload configuration when appearance changes or wallpaper cycles
-- The update-status event fires automatically ~1x per second by Wezterm
-- This checks current time to determine wallpaper and system appearance
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}

	-- Update color scheme based on current appearance
	local new_scheme = background.get_color_scheme()
	if overrides.color_scheme ~= new_scheme then
		overrides.color_scheme = new_scheme
	end

	-- Update background (wallpaper changes every 5 minutes based on os.time())
	overrides.background = background.get_background()

	-- Update tab bar colors
	overrides.colors = {
		tab_bar = background.get_tab_bar_colors(),
	}

	window:set_config_overrides(overrides)
end)

-- Finally, return the configuration to wezterm:
return config
