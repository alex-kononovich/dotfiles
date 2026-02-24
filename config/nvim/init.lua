-- Bootstrap `lazy.nvim`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
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

-- Make sure to set up `mapleader` and `maplocalleader` before
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

-- Do not fold by default
vim.o.foldlevelstart = 99

-- Completion menu behaviour
vim.o.completeopt = "noinsert,menu,menuone,popup"

-- UI
vim.cmd.colorscheme("minimal")
vim.o.fillchars = "fold:—,vert:│"
vim.opt.shortmess:append("a")
vim.opt.shortmess:append("T")
vim.opt.shortmess:append("W")
vim.o.signcolumn = "number"
vim.o.winborder = "single" -- border for floating windows

vim.ui.input = function(opts, on_confirm)
  return require("ui/input").create(opts, on_confirm)
end

vim.ui.select = function(items, opts, on_choice)
  return require("ui/select").create(items, opts, on_choice)
end

-- invisible characters
vim.opt.listchars = "tab:▶ ,space:·,nbsp:␣,eol:¬"

-- Highlight yanked region
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter" }, {
  callback = function()
    -- Highlight TODO items
    vim.fn.matchadd("Todo", "TODO")
    vim.fn.matchadd("Todo", "FIXME")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "psql",
  callback = function()
    vim.keymap.set("n", "<Tab>", "f|", { desc = "Next table cell" })
    vim.keymap.set("n", "<S-Tab>", "F|", { desc = "Previous table cell" })
  end,
})

-- Enable treesitter
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "http", "lua", "json", "typescript", "javascript" },
  callback = function()
    -- syntax highlighting, provided by Neovim
    vim.treesitter.start()
    -- folds, provided by Neovim
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldmethod = "expr"
    -- indentation, provided by nvim-treesitter
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Turn buffer into a scratch buffer
vim.api.nvim_create_user_command("Scratch", function()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
end, {})

-- Better grep
vim.o.grepprg = "ag --vimgrep --literal"
vim.api.nvim_create_user_command("Grep", function(opts)
  vim.cmd.grep({ args = opts.fargs, mods = { silent = true } })
  vim.cmd.copen()
end, { nargs = "+", complete = "file", desc = "More usable grep" })
vim.keymap.set("n", "<leader>f", ":Grep<space>", { desc = "Search in files" })
vim.keymap.set("n", "<leader>F", "<cmd>Grep<cword><cr>", { desc = "Search for word under cursor" })

-- Global keymappings
vim.cmd([[cnoremap <expr> %% expand('%:h').'/']])
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>Q", "<cmd>tabclose<cr>", { desc = "Close current tab page" })

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then
      return
    end

    -- Don't use LSP syntax highlighting (use Tree-sitter instead)
    client.server_capabilities.semanticTokensProvider = nil

    -- Enable full completion support including auto-imports (via `additionalTextEdits`)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        convert = function(item)
          -- For TS shows import source
          local info = (item.labelDetails and item.labelDetails.description)

          return {
            word = item.insertText,
            info = (info and string.format(" %-50s", info)),
          }
        end,
      })
    end
  end,
})

-- Don't show signs for diagnostics
vim.diagnostic.config({
  signs = false,
})

-- Don't update diagnostics as I type
vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = false,
  })

-- Open Code
vim.o.autoread = true -- auto-reload files changed by the agent
vim.api.nvim_create_user_command("Opencode", function(opts)
  require("opencode_send").send(opts)
end, { range = true, nargs = "?", desc = "Send selection or filename to opencode along with a message" })

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
    },
  },
  spec = {
    {
      "famiu/bufdelete.nvim",
      keys = {
        { "<leader>d", "<cmd>Bdelete<cr>" },
      },
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
          right = "<C-Right>",
        },
      },
    },
    {
      "dmtrKovalenko/fff.nvim",
      build = "cargo build --release",
      opts = {
        title = "Files",
        prompt = "> ",
        preview = { enabled = false },
        layout = {
          prompt_position = "top",
          width = 0.4,
          height = 0.4,
        },
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
      "tpope/vim-surround",
      dependencies = { "tpope/vim-repeat" },
      event = "VeryLazy",
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
        -- TODO: git log search command
        vim.api.nvim_create_user_command("Gstash", "Gclog -g stash", {})
      end,
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        vim.lsp.config("lua_ls", {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                },
              },
            },
          },
        })
        vim.lsp.enable("lua_ls")
        vim.lsp.enable("tsgo")

        vim.lsp.config("ruby_lsp", {
          init_options = {
            linters = { "rubocop_internal", "reek" },
          },
        })
        vim.lsp.enable("ruby_lsp")
        vim.lsp.enable("cspell_ls")

        vim.lsp.config("harper_ls", {
          settings = {
            ["harper-ls"] = {
              dialect = "Canadian",
              userDictPath = "~/.config/harper-ls/dictionary.txt",
              codeActions = {
                ForceStable = true,
              },
              linters = {
                ToDoHyphen = false,
              },
            },
          },
        })
        vim.lsp.enable("harper_ls")
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
    },
    {
      "stevearc/conform.nvim",
      init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
      keys = {
        {
          "<leader>a",
          function()
            require("conform").format()
          end,
          desc = "Format file",
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
          sql = { "sleek" },
          d2 = { "d2" },
        },
      },
    },
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      event = "VeryLazy",
      keys = {
        { "-", "<cmd>Oil<cr>", desc = "Open file explorer" },
      },
      opts = {
        keymaps = {
          ["<C-h>"] = false,
          ["<C-v>"] = {
            "actions.select",
            opts = { vertical = true, split = "belowright" },
            desc = "Open the entry in a vertical split",
          },
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
          desc = "View current Yaml key path",
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
      end,
    },
    {
      "terrastruct/d2-vim",
      dependencies = {
        {
          "ravsii/tree-sitter-d2",
          dependencies = { "nvim-treesitter/nvim-treesitter" },
          build = "make nvim-install",
        },
      },
      ft = { "d2" },
    },
  },
  install = { colorscheme = { "terminal16" } },
  checker = { enabled = false },
})
