---@diagnostic disable: undefined-global

-- Prevent some default plugins from loading
-- TODO: check if it has any effect
vim.g.loaded_2html_plugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_man = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1

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
vim.o.undodir = "~/.vim/undo-dir"
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
local telescope_borderchars = {
  prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
  results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
}

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
    vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "ErrorMsg" })
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
vim.keymap.set("n", "<leader>d", "<cmd>Bdelete<cr>", { silent = true })
vim.keymap.set("n", "<leader>o", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>n", "<cmd>Neotree toggle filesystem<cr>", { silent = true })
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { silent = true })
vim.keymap.set("n", "<leader>f", ":Ack<space>")
vim.keymap.set("n", "<leader>F", "<cmd>Ack<cword><cr>", { silent = true })
vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { silent = true })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { silent = true })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { silent = true })
vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { silent = true })
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<cr>", { silent = true })

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Don't use LSP syntax highlighting (use Tree-sitter instead)
    client.server_capabilities.semanticTokensProvider = nil

    -- Code actions
    if client.supports_method('textDocument/codeAction') then
      vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.code_action({apply=true}) end)
    end

    -- Rename
    if client.supports_method('textDocument/rename') then
      vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)
    end
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

-- Put a border around hover window so I can see it
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "single",
    wrap_at = 80,
  }
)

require("lazy").setup({
  spec = {
    {
      "alex-kononovich/terminal16.vim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.o.termguicolors = false -- Needs to be set for Neovim >= 0.10
        vim.cmd.colorscheme "terminal16"
      end,
    },
    {
      "famiu/bufdelete.nvim",
      cmd = "Bdelete",
    },
    {
      "alexghergh/nvim-tmux-navigation",
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
      "nvim-telescope/telescope.nvim", tag = "0.1.8",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "natecraddock/telescope-zf-native.nvim",
      },
      event = "VeryLazy",
      opts = {
        defaults = {
          preview = false,
          results_title = false,
          mappings = {
            i = {
              ["<esc>"] = "close",
              ["<C-s>"] = "select_horizontal",
              ["<C-x>"] = false,
            }
          },
        },
        pickers = {
          find_files = {
            prompt_title = "Files",
            theme = "dropdown",
            borderchars = telescope_borderchars
          },
          buffers = {
            theme = "dropdown",
            borderchars = telescope_borderchars
          }
        }
      },
      config = function(_,opts)
        require("telescope").load_extension("zf-native")
        require("telescope").setup(opts)
      end
    },
    {
      "tpope/vim-surround",
      dependencies = { "tpope/vim-repeat" },
      event = "VeryLazy"
    },
    {
      "tpope/vim-unimpaired",
      dependencies = { "tpope/vim-repeat" },
      event = "VeryLazy"
    },
    {
      "mileszs/ack.vim",
      cmd = "Ack",
      init = function()
        vim.g.ackprg = "ag --vimgrep --literal"
      end
    },
    {
      "tpope/vim-fugitive",
      dependencies = { "tpope/vim-rhubarb" },
      cmd = { "Git", "Gread", "Gwrite", "Gdiff" }
    },
    {
      "williamboman/mason.nvim",
      cmd = { "Mason", "MasonInstall" },
      opts = { ui = { border = "single" } }
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        local lsp = require("lspconfig")

        lsp.lua_ls.setup{}
        lsp.ruby_lsp.setup{}
        lsp.tsserver.setup{}
        lsp.harper_ls.setup({
          settings = {
            ["harper-ls"] = { userDictPath = "~/.config/harper-ls/dictionary.txt" }
          }
        })

        vim.api.nvim_set_hl(0, "FloatBorder", { link = "WinSeparator" })
      end
    },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {
          "lua_ls",
          "ruby_lsp",
          "tsserver",
          "harper_ls",
        }
      }
    },
    {
      "stevearc/dressing.nvim",
      dependencies = { "nvim-telescope/telescope.nvim" },
      event = "VeryLazy",
      config = function()
        require("dressing").setup({
          input = {
            border = "single",
            title_pos = "center",
            min_width = 60,
            win_options = {
              winhl = "FloatBorder:Normal" -- For input borders should be more distinctive
            },
            mappings = {
              i = {
                ["<Esc>"] = "Close"
              }
            }
          },
          select = {
            telescope = require("telescope.themes").get_cursor({
              borderchars = telescope_borderchars
            })
          }
        })
      end,
    },
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      event = "VeryLazy",
      opts = {
        keymaps = {
          ["<C-p>"] = {
            function()
              require("oil").open_preview({ split = "belowright" })
            end,
            desc = "Preview the entry",
          },
          ["<C-s>"] = false,
          ["<C-v>"] = { "actions.select", opts = { vertical = true, split = "belowright" }, desc = "Open the entry in a vertical split" },
        },
        columns = { { "icon", directory = "", add_padding = false } },
        git = {
          add = function()
            return true
          end,
          mv = function()
            return true
          end,
          rm = function()
            return true
          end
        }
      },
    }
  },
  install = { colorscheme = { "terminal16" } },
  checker = { enabled = false },
  ui = { border = "single" }
})
