---@diagnostic disable: undefined-global
---cSpell:dictionaries vim,cpp

-- Bootstrap `lazy.nvim`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading `lazy.nvim` so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- General text options
vim.o.wrap = false
vim.o.textwidth = 80
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Always show line numbers
vim.o.number = true

-- Don't use swap file
vim.o.swapfile = false

-- Persist undo history
vim.o.undofile = true

-- Smart case search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Read custom configurations in `.vimrc` per folder
vim.o.exrc = true
vim.o.secure = true

-- Live substitution preview
vim.o.inccommand = "split"

-- Do not use :Man for K
vim.o.keywordprg = nil

-- UI
vim.o.fillchars = "fold:—,vert:│"
vim.opt.shortmess:append("a")
vim.opt.shortmess:append("T")
vim.opt.shortmess:append("W")
vim.o.signcolumn = "number"
vim.o.winborder = "single" -- border for floating windows

-- invisible characters
vim.opt.listchars = "tab:▶ ,space:·,nbsp:␣,eol:¬"

-- Highlight yanked region
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup="Visual", timeout=300 })
  end
})

-- Highlight trailing whitespace, but only in Normal mode   
vim.fn.matchadd("TrailingWhitespace", [[\s\+$]])
vim.api.nvim_create_autocmd("ModeChanged", {
  callback = function()
    -- prr adds trailing whitespaces but we don't want to highlight them
    if vim.bo.filetype ~= "prr" then
      vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })
    end
  end,
  pattern = "*:n"
})
vim.api.nvim_create_autocmd("ModeChanged", {
  callback = function()
    vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = nil })
  end,
  pattern = "n:*"
})

-- Global keymappings
vim.cmd([[cnoremap <expr> %% expand('%:h').'/']])
vim.keymap.set("n", "<leader>w", "<cmd>silent w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true })
vim.keymap.set("n", "<leader>Q", "<cmd>tabclose<cr>", { silent = true })

-- Things 3 integration: show and complete current task
-- Commands:
-- :Todo
-- :Todo complete
vim.api.nvim_create_user_command("Todo", function(opts)
  local complete = opts.fargs[1] == "complete"

  local show_todo_script = [=[
tell application "Things3"
  repeat with todo in to dos of list "Today"
    if status of todo is open then
      return name of todo
    end if
  end repeat
end tell
]=]

  local complete_todo_script = [=[
tell application "Things3"
  repeat with todo in to dos of list "Today"
    if status of todo is open then
      set status of todo to completed
      return name of todo
    end if
  end repeat
end tell
]=]

  local icon = "□"
  local script = show_todo_script

  if complete then
    icon = "☑︎"
    script = complete_todo_script
  end


  local output = vim.fn.trim(vim.fn.system("osascript -e '" .. script .. "'"))

  print(icon .. " " .. output)
end, { nargs = "?" })

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Don't use LSP syntax highlighting (use Tree-sitter instead)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

-- Don't show signs for diagnostics
vim.diagnostic.config({
  signs = false,
})

-- Don't update diagnostics as I type
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = false,
  }
)

require("lazy").setup({
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "man",
        "netrwPlugin",
        "osc52",
        "rplugin",
        "spellplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    }
  },
  spec = {
    {
      dir = "~/Projects/terminal16.vim",
      dependencies = {
        "rktjmp/lush.nvim",
        "rktjmp/shipwright.nvim",
      },
      config = function()
        vim.cmd.colorscheme("terminal16")

        -- Color theme development commands
        vim.api.nvim_create_user_command("ThemeEdit", "vsp ~/Projects/terminal16.vim/lua/lush_theme/terminal16.lua | Lushify", {})
        vim.api.nvim_create_user_command("ThemeCheck", "so $VIMRUNTIME/tools/check_colors.vim", {})
        vim.api.nvim_create_user_command("ThemeTest", "so $VIMRUNTIME/syntax/hitest.vim", {})

        -- :filter GroupName hi
      end
    },
    -- {
    --   "alex-kononovich/terminal16.vim",
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     -- vim.o.termguicolors = false -- Needs to be set for Neovim >= 0.10
    --     vim.cmd.colorscheme "terminal16"
    --   end,
    -- },
    {
      "famiu/bufdelete.nvim",
      keys = {
        { "<leader>d", "<cmd>Bdelete<cr>" }
      }
    },
    {
      "srithon/nvim-tmux-navigation",
      event = "VeryLazy",
      opts = {
        disable_when_zoomed = true,
        keybindings = {
          left = "<C-Left>",
          down = "<C-Down>",
          up = "<C-Up>",
          right = "<C-Right>"
        }
      }
    },
    {
      "dmtrKovalenko/fff.nvim",
      build = "cargo build --release",
      opts = {
        prompt = "> ",
        width = 0.5,
        height = 0.4,
        preview = { enabled = false }
      },
      keys = {
        {
          "<leader>o",
          function()
            require("fff").find_files()
          end,
          desc = "Open file finder",
        },
      },
    },
    {
      "mileszs/ack.vim",
      cmd = "Ack",
      keys = {
        { "<leader>f", ":Ack<space>", desc = "Search in files" },
        { "<leader>F", "<cmd>Ack<cword><cr>", desc = "Search for current word" },
      },
      init = function()
        vim.g.ackprg = "ag --vimgrep --literal"
      end
    },
    {
      "tpope/vim-surround",
      dependencies = { "tpope/vim-repeat" },
      event = "VeryLazy"
    },
    {
      "tpope/vim-fugitive",
      dependencies = { "tpope/vim-rhubarb" },
      lazy = false,
      keys = {
        { "<leader>gs", "<cmd>tab Git<cr>", desc = "Git status" },
        { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
        { "<leader>gw", "<cmd>Gwrite<cr>", desc = "Git stage current file" },
        { "<leader>gr", "<cmd>Gread<cr>", desc = "Git reset current file to staged version" },
        { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git diff" },
        { "<leader>gc", "<cmd>tab Git commit --verbose<cr>", desc = "Git commit" },
      },
      config = function()
        vim.g.fugitive_dynamic_colors = 0
        -- TODO git log search command
        vim.api.nvim_create_user_command("Gstash", "Gclog -g stash", {})
      end
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        vim.lsp.enable("lua_ls")
        vim.lsp.enable("ts_ls")

        vim.lsp.config("ruby_lsp", {
          init_options = {
            linters = { "rubocop_internal", "reek" },
          }
        })
        vim.lsp.enable("ruby_lsp")
      end
    },
    {
      "nvimtools/none-ls.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "davidmh/cspell.nvim"
      },
      config = function()
        local cspell = require("cspell")
        require("null-ls").setup({
          sources = {
            cspell.diagnostics,
            cspell.code_actions,
          }
        })
      end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/playground",
      },
      build = ":TSUpdate",
      config = function()
        require'nvim-treesitter.configs'.setup({
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
          text_objects = { enable = true },
          incremental_selection = { enable = true },
        })
      end
    },
    {
      'stevearc/conform.nvim',
      init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
      keys = {
        {
          "<leader>a",
          function()
            require("conform").format()
          end,
          desc = "Format file"
        },
      },
      opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          scss = { "prettier" },
          css = { "prettier" },
          json = { "prettier" },
          sql = { "sleek" }
        }
      },
    },
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      event = "VeryLazy",
      keys = {
        { "-", "<cmd>Oil<cr>", desc = "Open file explorer" }
      },
      opts = {
        keymaps = {
          ["<C-s>"] = false,
          ["<C-v>"] = { "actions.select", opts = { vertical = true, split = "belowright" }, desc = "Open the entry in a vertical split" },
        },
        columns = { { "icon", directory = "", add_padding = false } },
        skip_confirm_for_simple_edits = true,
      },
    },
    {
      "cuducos/yaml.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
      },
      ft = "yaml",
      keys = {
        {
          "K",
          function()
            require("yaml_nvim").view()
          end,
          ft = "yaml",
          desc = "View current Yaml key path"
        },
      },
    },
    {
      "slim-template/vim-slim",
      ft = "slim",
    },
    {
      "danobi/prr",
      ft = "prr",
      init = function()
        -- Manually set up filetype because `ftplugin` can't load automatically (see rtp adjustments below)
        vim.filetype.add({ extension = { prr = "prr" } })
      end,
      config = function(plugin)
        vim.opt.rtp:append(plugin.dir .. "/vim")
      end
    },
  },
  install = { colorscheme = { "terminal16" } },
  checker = { enabled = false },
})
