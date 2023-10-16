local M = {}

local hi = require("user.hi")
local set_hl = vim.api.nvim_set_hl
local get_hl = vim.api.nvim_get_hl_by_name

local autocmd = vim.api.nvim_create_autocmd

local group = vim.api.nvim_create_augroup("UserColorscheme", { clear = true })

local function tocolor(color)
	return hi.hsluv(color)
end

function M.callback()
	local Normal = get_hl("Normal", true)
	local StatusLine = get_hl("StatusLine", true)
	local SignColumn = get_hl("SignColumn", true)

	local Normal__bg = tocolor(Normal.background)

	local bg = Normal__bg
	local fg = get_hl("GruvboxBg4", true).foreground

	local cm = vim.api.nvim_get_color_map()
	local Red = tocolor(cm.Red)
	local Orange = tocolor(cm.Orange)
	local LightBlue = tocolor(cm.LightBlue)
	local LightGrey = tocolor(cm.LightGrey)

	vim.cmd([[hi Comment gui=italic cterm=italic]])

	if vim.o.background == "dark" then
		set_hl(0, "Visual", { background = bg.lighten(15).desaturate(10).hex })
	else
		set_hl(0, "Visual", { background = bg.darken(15).desaturate(10).hex })
	end

	set_hl(0, "NormalFloat", { background = bg.hex })
	set_hl(0, "FloatBorder", { background = bg.hex, foreground = fg })
	set_hl(0, "LspDiagnosticsDefaultHint", { link = "GruvboxBg4" })

	for _, name in ipairs({ "Error", "Info", "Warn", "Other", "Hint" }) do
		set_hl(0, "DiagnosticSign" .. name, { background = SignColumn.background })
	end

	local function set_diff_hl(from, color_hex, dark, light)
		dark = 80 + (dark or 0)
		light = 20 + (light or 0)

		local col = hi.hsluv(color_hex).mix(tocolor(Normal.background), 30)

		if vim.o.background == "dark" then
			col = col.darken(dark)
		else
			col = col.lighten(light)
		end

		set_hl(0, "Diff" .. from, {
			background = tostring(col),
		})
	end

	set_diff_hl("Add", "#00FF00")
	set_diff_hl("Change", "#FFFF00")
	set_diff_hl("Text", "#FFFF00", -5, -10)
	set_diff_hl("Delete", "#FF0000")

	-- StatusLine
	for _, conf in pairs(require("nvim-web-devicons").get_icons()) do
		set_hl(0, string.format("StatusLineDevIcon%s", conf.name), {
			foreground = conf.color,
			background = StatusLine.foreground,
		})
	end

	for _, name in ipairs({
		"Hint",
		"Error",
		"Warn",
		"Info",
	}) do
		local foreground = get_hl("Diagnostic" .. name, true).foreground

		set_hl(0, string.format("StatusLineDiagnostic%s", name), {
			foreground = foreground,
			background = StatusLine.foreground,
		})

		set_hl(0, string.format("DiagnosticSign%s", name), {
			foreground = foreground,
			background = SignColumn.background,
		})
	end

	for _, value in ipairs({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }) do
		set_hl(0, string.format("StatusLine%s", value), {
			foreground = tocolor(StatusLine.background).darken(value * 10).hex,
			background = tocolor(StatusLine.foreground).darken(value * 10).hex,
		})
	end
end

M.callback()

autocmd("Colorscheme", {
	group = group,
	pattern = { "*" },
	callback = M.callback,
})

return M
