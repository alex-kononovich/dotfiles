vim.keymap.set("n", "<C-]>", function()
  -- Default implementation sometimes falls back to workspace symbol query which
  -- usually times out (timeout is 1s)
  vim.lsp.buf.definition()
end, { buffer = true })
