vim.keymap.set("n", "<leader>r", function()
  require("http").run()
end, { desc = "Run current HTTP query", nowait = true, buffer = true })
