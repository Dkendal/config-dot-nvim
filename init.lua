require("user.package").init()
local packadd = require("user.package").packadd
local ensure_rock = require("user.package").ensure_rock
local safe_require = require("user.package").safe_require
local protected = require("user.package").protected
local util = require("user.util")
local map = util.map

ensure_rock("penlight", "pl")

local L = require("pl.utils").string_lambda

packadd("impatient.nvim")
require("impatient")

-- Globals
do
	local a = require("user.async")
	local vim = vim

	local ex = vim.cmd
	local api = vim.api
	local fn = vim.fn

	local function scratch_buf(name)
		local buf = nil

		if fn.bufexists(name) == 0 then
			buf = api.nvim_create_buf(true, true)
			api.nvim_buf_set_name(buf, name)
			api.nvim_buf_set_option(buf, "swapfile", false)
			api.nvim_buf_set_option(buf, "buftype", "nofile")
			api.nvim_buf_set_option(buf, "buflisted", true)
			api.nvim_buf_set_option(buf, "bufhidden", "")
		else
			buf = fn.bufnr(name)
		end

		if buf == -1 then
			error("couldn't create buffer")
		end

		return buf
	end

	-- The function is called `t` for `termcodes`.
	-- You don't have to call it that, but I find the terseness convenient
	function _G.t(str)
		-- Adjust boolean arguments as needed
		return vim.api.nvim_replace_termcodes(str, true, true, true)
	end

	function _G.unload(mod)
		if package.loaded[mod] == nil then
			return
		end

		package.loaded[mod] = nil

		collectgarbage("collect")
	end

	function _G.reload(mod)
		if not mod then
			mod = vim.fn.expand("%:p")
			mod = mod:gsub(".*/lua/(.*).lua", "%1")
			mod = mod:gsub("/", ".")
		end
		unload(mod)
		local m = require(mod)
		if m.setup then
			m.setup()
		end
		return m
	end

	_G.r = _G.reload
end

-- Options
do
	vim.cmd.filetype("plugin", "indent", "on")
	vim.cmd.syntax("on")

	vim.o.shell = "bash"
	vim.o.cedit = "<C-O>"
	vim.o.cinoptions = "1s,(0,W2,m1"
	vim.o.makeef = "errors.err"
	vim.o.clipboard = "unnamedplus,unnamed"
	vim.o.grepprg = "rg --vimgrep"
	vim.o.includeexpr = "asubstitute(v:fname,'[ab]/','./','g')"
	vim.o.hidden = true
	vim.o.timeoutlen = 400
	vim.o.showbreak = "\226\134\179"
	vim.o.wrap = false
	vim.o.breakindent = true
	vim.o.colorcolumn = "80"
	vim.o.list = true
	vim.o.mouse = "a"
	vim.o.synmaxcol = 3000
	vim.o.undofile = true
	vim.o.wildignorecase = true
	vim.o.wildmenu = true
	vim.o.wildmode = "longest:full,full"
	vim.o.expandtab = true
	vim.o.lazyredraw = true
	vim.o.hlsearch = true
	vim.o.ignorecase = true
	vim.o.inccommand = "split"
	vim.o.incsearch = true
	vim.o.magic = true
	vim.o.smartcase = true
	vim.o.shiftwidth = 2
	vim.o.tabstop = 2
	vim.o.termguicolors = true
	vim.o.completeopt = "menu,menuone,noselect"
	vim.o.signcolumn = "yes:1"
	vim.o.cp = false
	vim.o.cmdheight = 0
	vim.o.laststatus = 3

	-- Folding
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.foldcolumn = "1"
	vim.o.foldenable = true
	-- vim.o.foldmethod = "expr"
	vim.o.foldexpr = "nvim_treesitter#foldexpr()"

	vim.wo.number = true
	vim.g.vimsyn_embed = "lmpPr"
	vim.g.mapleader = " "
	vim.g.maplocalleader = ","
	vim.g.netrw_banner = 0
end

-- Color scheme
packadd("gruvbox", function()
	vim.g.gruvbox_contrast_dark = "hard"
	vim.cmd.colorscheme("gruvbox")
	safe_require("user/colors")
end)

-- Built-in
packadd("cfilter")
packadd("matchit")

-- User packs
packadd("nvim-gh")
packadd("nvim-treeclimber", function()
	local mod = require("nvim-treeclimber")

	mod.setup({})

	vim.keymap.set({ "n", "x", "o" }, "<M-n>", mod.select_grow_forward, { desc = "Add the next node to the selection" })

	vim.keymap.set(
		{ "n", "x", "o" },
		"<M-p>",
		mod.select_grow_backward,
		{ desc = "Add the previous node to the selection" }
	)
end)

packadd("dkendal/nvim-kitty", function()
	require("nvim-kitty")
	map("n", "<leader>pq", require("nvim-kitty.telescope").finder)
end)

-- 3rd party packs

packadd("FixCursorHold.nvim")

packadd("L3MON4D3/LuaSnip", function()
	safe_require("user/snippets")
	map("n", "<leader>lsu", "<cmd>:LuaSnipUnlinkCurrent<cr>")
	map("n", "<leader>lsl", "<cmd>:LuaSnipListAvailable<cr>")
end)

packadd("NrrwRgn")

packadd("nvim-web-devicons")

packadd("mason.nvim", function()
	require("mason").setup({})
end)

packadd("mason-lspconfig.nvim", function()
	require("mason-lspconfig").setup({})
end)

packadd("lspkind-nvim")
packadd("lsp-inlayhints.nvim")
packadd("nvim-lspconfig")

packadd("hrsh7th/nvim-cmp", function()
	packadd("hrsh7th/cmp-buffer")
	packadd("hrsh7th/cmp-calc")
	packadd("hrsh7th/cmp-emoji")
	packadd("hrsh7th/cmp-nvim-lsp")
	packadd("hrsh7th/cmp-nvim-lsp-document-symbol")
	packadd("hrsh7th/cmp-nvim-lua")
	packadd("hrsh7th/cmp-path")
	packadd("saadparwaiz1/cmp_luasnip")

	local cmp = require("cmp")
	local lspkind = require("lspkind")

	cmp.setup({
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = {
			["<C-y>"] = cmp.mapping.confirm({ select = true }),
			["<C-return>"] = cmp.mapping.confirm({ select = true }),
			["<C-g>"] = cmp.mapping.abort(),
			["<C-c>"] = cmp.mapping.abort(),
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
			["<C-Space>"] = cmp.mapping.complete({}),
			["<C-d>"] = cmp.mapping.scroll_docs(-4),
			["<C-u>"] = cmp.mapping.scroll_docs(4),
			-- ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
		},
		formatting = {
			format = lspkind.cmp_format(),
		},
		sources = {
			{ name = "nvim_lsp" },
			{ name = "nvim_lua" },
			{ name = "luasnip" },
			{ name = "nvim_lsp_signature_help" },
			{ name = "path" },
			{ name = "emoji" },
		},
	})

	local group = vim.api.nvim_create_augroup("user-cmp-colorscheme", { clear = true })

	vim.api.nvim_create_autocmd({ "Colorscheme" }, {
		group = group,
		pattern = "*",
		callback = function()
			-- gray
			vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
			-- blue
			vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
			vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
			-- light blue
			vim.api.nvim_set_hl(0, "CmpItemKindVariable", { link = "GruvboxAqua" })
			vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
			vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
			-- pink
			vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
			vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
			-- front
			vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
			vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
			vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
		end,
	})
end)

packadd("copilot.vim", function()
	vim.fn.jobstart({ "rtx", "where", "nodejs@16" }, {
		stdout_buffered = true,
		on_stdout = function(j, d, e)
			local path = vim.trim(table.concat(d, ""))
			if type(path) == "string" and path ~= "" then
				vim.g.copilot_node_command = path
			end
		end,
	})

	vim.g.copilot_filetypes = {
		Prompt = false,
		TelescopePrompt = false,
	}
end)

packadd("earthly.vim")
packadd("file-line")
packadd("fzf")
packadd("fzf.vim")

packadd("gitsigns.nvim", function()
	require("gitsigns").setup({
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
		numhl = false,   -- Toggle with `:Gitsigns toggle_numhl`
		linehl = false,  -- Toggle with `:Gitsigns toggle_linehl`
		word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
		watch_gitdir = {
			follow_files = true,
		},
		attach_to_untracked = true,
		current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 1000,
			ignore_whitespace = false,
			virt_text_priority = 100,
		},
		current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
		sign_priority = 6,
		update_debounce = 100,
		status_formatter = nil, -- Use default
		max_file_length = 40000, -- Disable if file is longer than this (in lines)
		preview_config = {
			-- Options passed to nvim_open_win
			border = "single",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		yadm = {
			enable = false,
		},
	})
end)

packadd("NeogitOrg/neogit", function()
	packadd("sindrets/diffview.nvim")

	local neogit = require("neogit")

	neogit.setup({
		-- Hides the hints at the top of the status buffer
		disable_hint = false,
		-- Disables changing the buffer highlights based on where the cursor is.
		disable_context_highlighting = false,
		-- Disables signs for sections/items/hunks
		disable_signs = false,
		-- Do not ask to confirm the commit - just do it when the buffer is closed.
		disable_commit_confirmation = false,
		-- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
		-- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
		-- normal mode.
		disable_insert_on_commit = true,
		-- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
		-- events.
		filewatcher = {
			interval = 1000,
			enabled = true,
		},
		-- Used to generate URL's for branch popup action "pull request".
		git_services = {
			["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
			["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
			["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
		},
		-- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
		-- sorter instead. By default, this function returns `nil`.
		telescope_sorter = function()
			return require("telescope").extensions.fzf.native_fzf_sorter()
		end,
		-- Persist the values of switches/options within and across sessions
		remember_settings = true,
		-- Scope persisted settings on a per-project basis
		use_per_project_settings = true,
		-- Table of settings to never persist. Uses format "Filetype--cli-value"
		ignored_settings = {
			"NeogitPushPopup--force-with-lease",
			"NeogitPushPopup--force",
			"NeogitPullPopup--rebase",
			"NeogitCommitPopup--allow-empty",
			"NeogitRevertPopup--no-edit",
		},
		-- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
		-- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
		auto_refresh = true,
		-- Value used for `--sort` option for `git branch` command
		-- By default, branches will be sorted by commit date descending
		-- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
		-- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
		sort_branches = "-committerdate",
		-- Change the default way of opening neogit
		kind = "tab",
		-- Disable line numbers and relative line numbers
		disable_line_numbers = true,
		-- The time after which an output console is shown for slow running commands
		console_timeout = 2000,
		-- Automatically show console if a command takes more than console_timeout milliseconds
		auto_show_console = true,
		status = {
			recent_commit_count = 10,
		},
		commit_editor = {
			kind = "split",
		},
		commit_select_view = {
			kind = "tab",
		},
		commit_view = {
			kind = "vsplit",
			verify_commit = os.execute("which gpg") == 0, -- Can be set to true or false, otherwise we try to find the binary
		},
		log_view = {
			kind = "tab",
		},
		rebase_editor = {
			kind = "split",
		},
		reflog_view = {
			kind = "tab",
		},
		merge_editor = {
			kind = "split",
		},
		tag_editor = {
			kind = "split",
		},
		preview_buffer = {
			kind = "split",
		},
		popup = {
			kind = "split",
		},
		signs = {
			-- { CLOSED, OPENED }
			hunk = { "", "" },
			item = { "⮞", "⮟" },
			section = { "⮞", "⮟" },
		},
		-- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
		integrations = {
			-- If enabled, use telescope for menu selection rather than vim.ui.select.
			-- Allows multi-select and some things that vim.ui.select doesn't.
			telescope = true,
			-- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
			-- The diffview integration enables the diff popup.
			--
			-- Requires you to have `sindrets/diffview.nvim` installed.
			diffview = true,

			-- If enabled, uses fzf-lua for menu selection. If the telescope integration
			-- is also selected then telescope is used instead
			-- Requires you to have `ibhagwan/fzf-lua` installed.
			fzf_lua = nil,
		},
		sections = {
			-- Reverting/Cherry Picking
			sequencer = {
				folded = false,
				hidden = false,
			},
			untracked = {
				folded = false,
				hidden = false,
			},
			unstaged = {
				folded = false,
				hidden = false,
			},
			staged = {
				folded = false,
				hidden = false,
			},
			stashes = {
				folded = true,
				hidden = false,
			},
			unpulled_upstream = {
				folded = true,
				hidden = false,
			},
			unmerged_upstream = {
				folded = false,
				hidden = false,
			},
			unpulled_pushRemote = {
				folded = true,
				hidden = false,
			},
			unmerged_pushRemote = {
				folded = false,
				hidden = false,
			},
			recent = {
				folded = true,
				hidden = false,
			},
			rebase = {
				folded = true,
				hidden = false,
			},
		},
		mappings = {
			finder = {
				["<cr>"] = "Select",
				["<c-c>"] = "Close",
				["<esc>"] = "Close",
				["<c-n>"] = "Next",
				["<c-p>"] = "Previous",
				["<down>"] = "Next",
				["<up>"] = "Previous",
				["<tab>"] = "MultiselectToggleNext",
				["<s-tab>"] = "MultiselectTogglePrevious",
				["<c-j>"] = "NOP",
			},
			-- Setting any of these to `false` will disable the mapping.
			status = {
				["q"] = "Close",
				["I"] = "InitRepo",
				["1"] = "Depth1",
				["2"] = "Depth2",
				["3"] = "Depth3",
				["4"] = "Depth4",
				["<tab>"] = "Toggle",
				["x"] = "Discard",
				["s"] = "Stage",
				["S"] = "StageUnstaged",
				["<c-s>"] = "StageAll",
				["u"] = "Unstage",
				["U"] = "UnstageStaged",
				["d"] = "DiffAtFile",
				["$"] = "CommandHistory",
				["#"] = "Console",
				["<c-r>"] = "RefreshBuffer",
				["<enter>"] = "GoToFile",
				["<c-v>"] = "VSplitOpen",
				["<c-x>"] = "SplitOpen",
				["<c-t>"] = "TabOpen",
				["?"] = "HelpPopup",
				["D"] = "DiffPopup",
				["p"] = "PullPopup",
				["r"] = "RebasePopup",
				["m"] = "MergePopup",
				["P"] = "PushPopup",
				["c"] = "CommitPopup",
				["l"] = "LogPopup",
				["v"] = "RevertPopup",
				["Z"] = "StashPopup",
				["A"] = "CherryPickPopup",
				["b"] = "BranchPopup",
				["f"] = "FetchPopup",
				["X"] = "ResetPopup",
				["M"] = "RemotePopup",
				["{"] = "GoToPreviousHunkHeader",
				["}"] = "GoToNextHunkHeader",
			},
		},
	})
end)

packadd("hydra.nvim")
packadd("indent-blankline.nvim")

packadd("lush.nvim")

packadd("jfpedroza/neotest-elixir")
packadd("nvim-neotest/neotest-plenary")
packadd("rouge8/neotest-rust")
packadd("rcarriga/neotest")

packadd("null-ls.nvim")
packadd("nvim")
packadd("nvim-dap")

packadd("nvim-notify", function()
	vim.api.nvim_set_hl(0, "NotifyBackground", { link = "Normal" })

	local notify = require("notify")

	notify.setup({
		stages = "fade",
		render = "default",
		timeout = 1000,
	})

	vim.notify = notify
end)

packadd("nvim-treesitter")
packadd("nvim-treesitter-textobjects")
packadd("nvim-treesitter-textsubjects")
packadd("nvim-ts-rainbow")

packadd("kevinhwang91/nvim-ufo", function()
	packadd("kevinhwang91/promise-async")

	local ufo_handler = function(virtText, lnum, endLnum, width, truncate)
		local newVirtText = {}
		local suffix = ("  %d "):format(endLnum - lnum)
		local sufWidth = vim.fn.strdisplaywidth(suffix)
		local targetWidth = width - sufWidth
		local curWidth = 0
		for _, chunk in ipairs(virtText) do
			local chunkText = chunk[1]
			local chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if targetWidth > curWidth + chunkWidth then
				table.insert(newVirtText, chunk)
			else
				chunkText = truncate(chunkText, targetWidth - curWidth)
				local hlGroup = chunk[2]
				table.insert(newVirtText, { chunkText, hlGroup })
				chunkWidth = vim.fn.strdisplaywidth(chunkText)
				-- str width returned from truncate() may less than 2nd argument, need padding
				if curWidth + chunkWidth < targetWidth then
					suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
				end
				break
			end
			curWidth = curWidth + chunkWidth
		end
		table.insert(newVirtText, { suffix, "MoreMsg" })
		return newVirtText
	end

	require("ufo").setup({
		fold_virt_text_handler = ufo_handler,

		provider_selector = function(bufnr, filetype, buftype)
			return { "treesitter", "indent" }
		end,
	})
end)

packadd("octo.nvim")
packadd("playground")
packadd("plenary.nvim")
packadd("promise-async")
packadd("splitjoin.vim")
packadd("ssr.nvim")
packadd("stabilize.nvim")
packadd("startuptime.vim")
packadd("symbols-outline.nvim")
packadd("tabular")

packadd("telescope.nvim", function()
	packadd("telescope-fzf-native.nvim")
	local telescope = require("telescope")
	local themes = require("telescope.themes")

	telescope.setup({ extensions = { fzf = {} }, defaults = themes.get_ivy({}) })
	telescope.load_extension("fzf")
end)

packadd("folke/trouble.nvim", function()
	require("trouble").setup()
end)

packadd("twilight.nvim")
packadd("typescript.nvim")
packadd("vCoolor.vim")
packadd("vim-abolish")

packadd("numToStr/Comment.nvim", function()
	require("Comment").setup({
		toggler = {
			---Line-comment toggle keymap
			line = "<leader>;",
			---Block-comment toggle keymap
			block = "<leader>:",
		},
		opleader = {
			---Line-comment keymap
			line = "<leader>;",
			---Block-comment keymap
			block = "<leader>:",
		},
	})
end)

packadd("vim-devicons")
packadd("vim-elixir")
packadd("vim-eunuch")
packadd("vim-fish")
packadd("vim-fugitive")
packadd("vim-gnupg")
packadd("vim-jsonnet")
packadd("pest-parser/pest.vim")
packadd("vim-racket")
packadd("vim-repeat")

packadd("vim-rhubarb")
packadd("vim-rsi")

packadd("vim-sandwich", function()
	vim.cmd([[runtime macros/sandwich/keymap/surround.vim]])

	local t = vim.deepcopy(vim.g["sandwich#default_recipes"])

	table.insert(t, {
		buns = { "<%=", "%>" },
		input = { "=" },
	})

	table.insert(t, {
		buns = { "<%", "%>" },
		input = { "-" },
	})

	vim.g["sandwich#recipes"] = t
end)

packadd("vim-scriptease")
packadd("vim-sleuth")
packadd("vim-speeddating")
packadd("vim-syntax-vcl")
packadd("vim-unimpaired")
packadd("vim-varnish")
packadd("vim-vinegar")

packadd("vim-visual-multi", function()
	map("n", "<C-LeftMouse>", "<Plug>(VM-Mouse-Cursor)")
	map("n", "<C-RightMouse>", "<Plug>(VM-Mouse-Word)")
	map("n", "<M-C-RightMouse>", "<Plug>(VM-Mouse-Column)")
	map("n", "<c-s-j>", "<Plug>(VM-Add-Cursor-Down)")
	map("n", "<c-s-k>", "<Plug>(VM-Add-Cursor-Up)")
end)

packadd("vim-wipeout")
packadd("which-key.nvim")
packadd("zen-mode.nvim")
packadd("folke/neodev.nvim")

packadd("kosayoda/nvim-lightbulb", function()
	require("nvim-lightbulb").setup({
		autocmd = { enabled = true },
	})
end)

packadd("colortils.nvim", function()
	require("colortils").setup({
		-- Register in which color codes will be copied
		register = "+",
		-- Preview for colors, if it contains `%s` this will be replaced with a hex color code of the color
		color_preview = "█ %s",
		-- The default in which colors should be saved
		-- This can be hex, hsl or rgb
		default_format = "hex",
		-- Border for the float
		border = "rounded",
		-- Some mappings which are used inside the tools
		mappings = {
			-- increment values
			increment = "l",
			-- decrement values
			decrement = "h",
			-- increment values with bigger steps
			increment_big = "L",
			-- decrement values with bigger steps
			decrement_big = "H",
			-- set values to the minimum
			min_value = "0",
			-- set values to the maximum
			max_value = "$",
			-- save the current color in the register specified above with the format specified above
			set_register_default_format = "<cr>",
			-- save the current color in the register specified above with a format you can choose
			set_register_cjoose_format = "g<cr>",
			-- replace the color under the cursor with the current color in the format specified above
			replace_default_format = "<m-cr>",
			-- replace the color under the cursor with the current color in a format you can choose
			replace_choose_format = "g<m-cr>",
			-- export the current color to a different tool
			export = "E",
			-- set the value to a certain number (done by just entering numbers)
			set_value = "c",
			-- toggle transparency
			transparency = "T",
			-- choose the background (for transparent colors)
			choose_background = "B",
		},
	})
end)

safe_require("neotest", function(m)
	m.setup({
		adapters = {
			require("neotest-plenary"),
			require("neotest-elixir"),
		},
		icons = {
			child_indent = "│",
			child_prefix = "├",
			collapsed = "─",
			expanded = "╮",
			failed = "✖",
			final_child_indent = " ",
			final_child_prefix = "╰",
			non_collapsible = "─",
			passed = "✔",
			running = "◯",
			skipped = "ﰸ",
			unknown = "?",
		},
		highlights = {
			adapter_name = "NeotestAdapterName",
			border = "NeotestBorder",
			dir = "NeotestDir",
			expand_marker = "NeotestExpandMarker",
			failed = "NeotestFailed",
			file = "NeotestFile",
			focused = "NeotestFocused",
			indent = "NeotestIndent",
			marked = "NeotestMarked",
			namespace = "NeotestNamespace",
			passed = "NeotestPassed",
			running = "NeotestRunning",
			select_win = "NeotestWinSelect",
			skipped = "NeotestSkipped",
			target = "NeotestTarget",
			test = "NeotestTest",
			unknown = "NeotestUnknown",
		},
	})
end)

-- simrat39/symbols-outline.nvim
safe_require("symbols-outline", L("|m| m.setup()"))

-- folke/zen-mode.nvim
-- folke/twighlight.nvim
do
	local zen_mode = require("zen-mode")
	local twilight = require("twilight")
	local opts = { dimming = { alpha = 0.4 } }
	zen_mode.setup(opts)
	twilight.setup(opts)
end

-- Treesitter
do
	local config = require("nvim-treesitter.configs")

	local setup = config["setup"]

	setup({
		ensure_installed = {},
		query_linter = { enable = true, use_virtual_text = true, lint_events = { "BufWrite", "CursorHold" } },
		textsubjects = {
			enable = true,
			prev_selection = ",", -- (Optional) keymap to select the previous selection
			keymaps = {
				["."] = "textsubjects-smart",
				[";"] = "textsubjects-container-outer",
				["i;"] = "textsubjects-container-inner",
			},
		},
		playground = {
			enable = true,
			disable = {},
			updatetime = 25,
			persist_queries = false,
			keybindings = {
				toggle_query_editor = "o",
				toggle_hl_groups = "i",
				toggle_injected_languages = "t",
				toggle_anonymous_nodes = "a",
				toggle_language_display = "I",
				focus_language = "f",
				unfocus_language = "F",
				update = "R",
				goto_node = "<cr>",
				show_help = "?",
			},
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = t("<leader>v"),
				node_incremental = "<M-n>",
				scope_incremental = "<M-N>",
				node_decremental = "<M-p>",
			},
		},
		indent = { enable = true },
		-- refactor = {
		-- 	highlight_definitions = { enable = true },
		-- 	highlight_current_scope = { enable = false },
		-- 	smart_rename = { enable = true, keymaps = { smart_rename = "<leader>rr" } },
		-- },
		highlight = {
			enable = true,
			custom_captures = {},
		},
		rainbow = { enable = true, extended_mode = true, max_file_lines = nil },
	})
end

-- mg979/vim-visual-multi
vim.g.vm_theme = "paper"

-- lukas-reineke/indent-blankline.nvim
vim.g.indent_blankline_use_treesitter = true
vim.g.indent_blankline_show_current_context = true
vim.g.indent_blankline_char_list = { "\226\148\131" }
vim.g.indent_blankline_filetype_exclude = { "help" }
vim.g.indent_blankline_char_list = { "|", "¦", "┆", "┊" }

require("indent_blankline").setup({
	show_current_context = true,
	show_current_context_start = false,
})

protected(function()
	require("octo").setup()
end)

protected(function()
	require("stabilize").setup()
end)

protected(function()
	require("ssr").setup({
		min_width = 50,
		min_height = 5,
		keymaps = {
			close = "q",
			next_match = "n",
			prev_match = "N",
			replace_all = "<leader><cr>",
		},
	})
end)

vim.o.rtp = vim.o.rtp .. ",/home/dylan/.config/nvim/pack/plugins/start/vim-fugitive/"

safe_require("user/boxes")
safe_require("user/lsp")
safe_require("user/background", L("|m| m.init()"))
safe_require("user/statusline", L("|m| m.setup()"))
safe_require("user/keymaps", L("|m| m.setup()"))
safe_require("user/boxes")
safe_require("user/filetypes")
safe_require("user/commands")
safe_require("user/projects")
safe_require("user/search_and_replace")
safe_require("user/jest")

vim.o.exrc = true
vim.o.secure = true
