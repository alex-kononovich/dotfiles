-- Highlight trailing whitespace
--
-- Can be disabled per buffer:
-- `vim.b.trailing_whitespace_disabled = true`

local function turn_highlight_on()
  vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })
end

local function turn_highlight_off()
  vim.api.nvim_set_hl(0, "TrailingWhitespace", {})
end

vim.api.nvim_create_autocmd({"WinNew", "BufWinEnter"}, {
  callback = function()
    if not vim.b.trailing_whitespace_disabled then
      vim.fn.matchadd("TrailingWhitespace", [[\s\+$]])
    end
  end
})

-- Only highlight trailing whitespace in Normal mode   
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:n",
  callback = turn_highlight_on
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "n:*",
  callback = turn_highlight_off
})

-- `ModeChanged` is not fired when first entering Neovim,
-- turn the highlight on manually
turn_highlight_on()
