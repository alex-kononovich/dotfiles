vim.loader.enable()

-- Use spacebar as the leader key
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
vim.opt.fillchars:append({ diff = " " })
vim.opt.shortmess:append("a")
vim.opt.shortmess:append("T")
vim.opt.shortmess:append("W")
vim.o.signcolumn = "number"
vim.o.winborder = "single" -- border for floating windows
if vim.fn.exists("+pumborder") == 1 then
  vim.o.pumborder = "single"
end

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

-- Turn buffer into a scratch buffer
vim.api.nvim_create_user_command("Scratch", function()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
end, {})

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

vim.diagnostic.config({
  signs = false,
  update_in_insert = false,
})

-- Codex
vim.api.nvim_create_user_command("Codex", function(opts)
  require("codex").send(opts)
end, { range = true, nargs = "?", desc = "Send selection or filename to Codex" })

-- diffs.nvim
vim.g.diffs = {
  highlights = {
    intra = {
      algorithm = "vscode",
    },
  },
  integrations = {
    fugitive = true,
  },
}

vim.g.fff = {
  lazy_sync = false,
  title = "Files",
  prompt = "> ",
  preview = { enabled = false },
  layout = {
    prompt_position = "top",
    width = function(columns)
      return math.min(80 / columns, 1)
    end,
    height = 0.4,
  },
}

-- Enable treesitter
local treesitter_languages = { "sql", "http", "lua", "json", "typescript", "javascript" }
vim.api.nvim_create_autocmd("FileType", {
  pattern = treesitter_languages,
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

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    local name = event.data.spec.name
    local kind = event.data.kind

    if name == "fff" and (kind == "install" or kind == "update") then
      if not event.data.active then
        vim.cmd.packadd("fff")
      end
      require("fff.download").download_or_build_binary()
      return
    end

    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not event.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end

      if kind == "install" then
        require("nvim-treesitter").install(treesitter_languages):wait(300000)
        return
      end

      vim.cmd("TSUpdate")
      return
    end
  end,
})

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/tpope/vim-repeat",
  "https://github.com/famiu/bufdelete.nvim",
  "https://github.com/srithon/nvim-tmux-navigation",
  "https://github.com/dmtrKovalenko/fff",
  "https://github.com/tpope/vim-surround",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-rhubarb",
  "https://github.com/barrettruth/diffs.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/stevearc/oil.nvim",
})

-- bufdelete.nvim
vim.keymap.set("n", "<leader>d", "<cmd>Bdelete<cr>")

-- nvim-tmux-navigation
require("nvim-tmux-navigation").setup({
  disable_when_zoomed = true,
  keybindings = {
    left = "<C-Left>",
    down = "<C-Down>",
    up = "<C-Up>",
    right = "<C-Right>",
  },
})

-- fff.nvim
vim.keymap.set("n", "<leader>o", function()
  require("fff").find_files()
end, { desc = "Open file finder" })
vim.keymap.set("n", "<leader>f", function()
  require("fff").live_grep({ grep = { modes = { "plain", "fuzzy", "regex" } } })
end, { desc = "Search in files" })
vim.keymap.set({ "n", "x" }, "<leader>F", function()
  require("fff").live_grep_under_cursor()
end, { desc = "Search current word / selection" })

-- fugitive
vim.g.fugitive_dynamic_colors = 0
vim.api.nvim_create_user_command("Gstash", "Gclog -g stash", {})
vim.keymap.set("n", "<leader>gs", "<cmd>0Git<cr>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git stage current file" })
vim.keymap.set(
  "n",
  "<leader>gr",
  "<cmd>Gread<cr>",
  { desc = "Git reset current file to staged version" }
)
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<cr>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gc", "<cmd>tab Git commit --verbose<cr>", { desc = "Git commit" })
local fugitive_keys = vim.api.nvim_create_augroup("fugitive_keys", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = fugitive_keys,
  pattern = { "FugitiveObject", "FugitiveIndex", "FugitivePager" },
  callback = function(event)
    vim.keymap.set("n", "{", "(", { buffer = event.buf, remap = true })
    vim.keymap.set("n", "}", ")", { buffer = event.buf, remap = true })
  end,
})

-- LSP configuration
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
vim.lsp.enable("tsc")

-- Conform
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "oxfmt" },
    typescript = { "oxfmt" },
    typescriptreact = { "oxfmt" },
    scss = { "oxfmt" },
    css = { "oxfmt" },
    json = { "oxfmt" },
    sql = { "sleek" },
    d2 = { "d2" },
    markdown = { "prettier", "injected" },
    html = { "prettier" },
  },
  formatters = {
    prettier = {
      prepend_args = {
        "--prose-wrap",
        "always",
        "--print-width",
        "80",
        "--ignore-path",
        "/dev/null",
      },
    },
    oxfmt = {
      prepend_args = { "--config", ".oxfmtrc.json" },
    },
  },
})
vim.keymap.set("n", "<leader>a", function()
  require("conform").format()
end, { desc = "Format file" })

-- Oil
require("oil").setup({
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
})
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open file explorer" })
