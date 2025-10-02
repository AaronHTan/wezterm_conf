local wezterm = require("wezterm")

local M = {}

-- List of wallpapers
M.wallpapers = {
	"/Users/aarontan/wallpapers/眼镜美女.png",
	"/Users/aarontan/wallpapers/柯南.png",
	"/Users/aarontan/wallpapers/国风山水.png",
	"/Users/aarontan/wallpapers/wallpaper_terminal.png",
	"/Users/aarontan/wallpapers/wallpaper_anime.png",
}

-- Manual wallpaper override index (nil means use time-based)
M.manual_wallpaper_index = nil

-- Detect system appearance (light or dark mode)
function M.get_appearance()
	-- Try wezterm.gui first (preferred method)
	if wezterm.gui then
		local appearance = wezterm.gui.get_appearance()
		if appearance then
			return appearance
		end
	end

	-- Fallback: check macOS system settings directly
	local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		if result and result:match("Dark") then
			return "Dark"
		end
	end

	return "Light"
end

function M.is_dark_mode()
	local appearance = M.get_appearance()
	return appearance and appearance:find("Dark") ~= nil
end

-- Get wallpaper based on time (changes every 5 minutes) or manual override
function M.get_wallpaper()
	local wallpaper_index
	if M.manual_wallpaper_index then
		wallpaper_index = M.manual_wallpaper_index
	else
		wallpaper_index = (math.floor(os.time() / 360) % #M.wallpapers) + 1
	end
	return M.wallpapers[wallpaper_index]
end

-- Cycle to next wallpaper manually
function M.cycle_wallpaper()
	if M.manual_wallpaper_index == nil then
		-- Start from current time-based index
		M.manual_wallpaper_index = (math.floor(os.time() / 360) % #M.wallpapers) + 1
	end
	M.manual_wallpaper_index = (M.manual_wallpaper_index % #M.wallpapers) + 1
end

-- Reset to automatic time-based cycling
function M.reset_wallpaper_auto()
	M.manual_wallpaper_index = nil
end

-- Get overlay color based on system appearance
function M.get_overlay_color()
	return M.is_dark_mode() and "rgba(0, 0, 0, 0.6)" or "rgba(255, 255, 255, 0.6)"
end

-- Get color scheme based on system appearance
function M.get_color_scheme()
	return M.is_dark_mode() and "Dracula" or "Gruvbox Light"
end

-- Generate background configuration
function M.get_background()
	return {
		-- Layer 1: Background image
		{
			source = {
				File = M.get_wallpaper(),
			},
			width = "Cover",
			height = "Cover",
			vertical_align = "Middle",
			horizontal_align = "Center",
			repeat_x = "NoRepeat",
			repeat_y = "NoRepeat",
		},
		-- Layer 2: Semi-transparent overlay
		{
			source = {
				Color = M.get_overlay_color(),
			},
			width = "100%",
			height = "100%",
		},
	}
end

-- Get tab bar colors based on system appearance
function M.get_tab_bar_colors()
	if M.is_dark_mode() then
		return {
			background = "rgba(0, 0, 0, 0.6)",
			active_tab = {
				bg_color = "rgba(0, 0, 0, 0.8)",
				fg_color = "#ffffff",
			},
			inactive_tab = {
				bg_color = "rgba(0, 0, 0, 0.4)",
				fg_color = "#999999",
			},
			inactive_tab_hover = {
				bg_color = "rgba(0, 0, 0, 0.6)",
				fg_color = "#cccccc",
			},
			new_tab = {
				bg_color = "rgba(0, 0, 0, 0.4)",
				fg_color = "#999999",
			},
			new_tab_hover = {
				bg_color = "rgba(0, 0, 0, 0.6)",
				fg_color = "#cccccc",
			},
		}
	else
		return {
			background = "rgba(255, 255, 255, 0.6)",
			active_tab = {
				bg_color = "rgba(255, 255, 255, 0.8)",
				fg_color = "#000000",
			},
			inactive_tab = {
				bg_color = "rgba(255, 255, 255, 0.4)",
				fg_color = "#666666",
			},
			inactive_tab_hover = {
				bg_color = "rgba(255, 255, 255, 0.6)",
				fg_color = "#333333",
			},
			new_tab = {
				bg_color = "rgba(255, 255, 255, 0.4)",
				fg_color = "#666666",
			},
			new_tab_hover = {
				bg_color = "rgba(255, 255, 255, 0.6)",
				fg_color = "#333333",
			},
		}
	end
end

return M
