vim.api.nvim_create_user_command("Psql", function(opts)
  require("psql").process_user_command(opts)
end, {
  desc = "Run psql command",
  nargs = "*",
  complete = function()
    return { "connect" }
  end,
})

vim.keymap.set("v", "<leader>r", function()
  require("psql").run_visual_selection()
end, { desc = "Run visual selection in psql", buffer = true })

vim.keymap.set("n", "<leader>r", function()
  require("psql").run_current_statement()
end, { desc = "Run current SQL statement in psql", nowait = true, buffer = true })
