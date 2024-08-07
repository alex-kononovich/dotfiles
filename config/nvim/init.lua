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

-- Bootstrap lazy.nvim
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
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- general text options
vim.o.wrap = false
vim.o.textwidth = 80
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- always show line numbers
vim.o.number = true

-- don't use swap file
vim.o.swapfile = false

-- persist undo history
vim.o.undodir = "~/.vim/undo-dir"
vim.o.undofile = true

-- smart case search
vim.o.ignorecase = true
vim.o.smartcase = true

-- read custom configurations in .vimrc per folder
vim.o.exrc = true
vim.o.secure = true

-- live substitution preview
vim.o.inccommand = "split"

-- UI
vim.o.fillchars = "fold:—,vert:│"
vim.opt.shortmess:append("a")
vim.opt.shortmess:append("T")
vim.opt.shortmess:append("W")

-- higlight yanked region
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup="Visual", timeout=300 })
  end
})

-- higlight trailing whitespace, but only in Normal mode
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

-- global keymappings
vim.cmd([[cnoremap <expr> %% expand('%:h').'/']])
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true })
vim.keymap.set("n", "<leader>d", "<cmd>Bdelete<cr>", { silent = true })
vim.keymap.set("n", "<leader>o", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>n", "<cmd>Neotree toggle filesystem<cr>", { silent = true })
vim.keymap.set("n", "-", "<cmd>Neotree filesystem reveal<cr>", { silent = true })
vim.keymap.set("n", "<leader>f", ":Ack<space>")
vim.keymap.set("n", "<leader>F", "<cmd>Ack<cword><cr>", { silent = true })
vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { silent = true })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { silent = true })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { silent = true })
vim.keymap.set("n", "<leader>gr", "<cmd>Gread<cr>", { silent = true })

require("lazy").setup({
  spec = {
    {
      "alex-kononovich/terminal16.vim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.o.termguicolors = false -- needs to be set for neovim >= 0.10
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
      dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }},
      cmd = "Telescope",
      opts = {
        defaults = {
          preview = false,
          results_title = false,
          layout_strategy = "vertical",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
            width = 80,
            height = 30
          },
          mappings = {
            i = {
              ["<esc>"] = "close",
              ["<C-s>"] = "select_horizontal",
              ["<C-x>"] = false
            }
          }
        },
        pickers = { find_files = { prompt_title = "Files" } },
      },
      config = function(_,opts)
        require("telescope").load_extension("fzf")
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
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      cmd = "Neotree",
      opts = {
        popup_border_style = "rounded",
        filesystem = {
          window = {
            mappings = {
              ["/"] = "none",
              [">"] = "none",
              ["<"] = "none",
              ["#"] = "none",
              ["w"] = "none",
              ["f"] = "none",
              ["oc"] = "none",
              ["od"] = "none",
              ["og"] = "none",
              ["om"] = "none",
              ["on"] = "none",
              ["os"] = "none",
              ["ot"] = "none",
              ["o"] = "toggle_node",
            }
          }
        },
        event_handlers = {
          {
            event = "file_open_requested",
            handler = function() vim.cmd("Neotree close") end
          },
          {
            event = "neo_tree_window_after_open",
            handler = function(args) vim.cmd("wincmd =") end
          },
          {
            event = "neo_tree_window_after_close",
            handler = function(args) vim.cmd("wincmd =") end
          }
        }
      }
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
      cmd = { "Git", "Gread", "Gwrite" }
    }
  },
  install = { colorscheme = { "terminal16" } },
  checker = { enabled = false },
  ui = { border = "rounded" }
})
