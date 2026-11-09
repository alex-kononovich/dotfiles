local M = {}

--- Move within Neovim before asking Rex to focus an adjacent pane.
local function navigate(window_direction, pane_direction)
  local previous_window = vim.api.nvim_get_current_win()
  local moved, move_error = pcall(vim.cmd.wincmd, window_direction)
  if not moved then
    vim.notify(tostring(move_error), vim.log.levels.ERROR)
    return
  end
  if vim.api.nvim_get_current_win() ~= previous_window then
    return
  end

  local ok, result = pcall(function()
    return vim.system({
      "rex",
      "--autostart=false",
      "focus", pane_direction,
      "--wrap",
    }, { text = true, timeout = 1000 }):wait()
  end)
  if not ok then
    vim.notify("Rex navigation: " .. tostring(result), vim.log.levels.ERROR)
  elseif result.code ~= 0 then
    local message = vim.trim(result.stderr or "")
    if message == "" then
      message = "command exited with status " .. result.code
    end
    vim.notify("Rex navigation: " .. message, vim.log.levels.ERROR)
  end
end

--- Install normal mode arrow mappings when Neovim runs directly inside Rex.
--- Return false elsewhere so the existing tmux integration remains in charge.
--- Rex navigation may leave a zoomed pane and wraps at the edge of its layout.
function M.setup()
  if not vim.env.REX_SESSION then
    return false
  end

  local directions = { Left = "h", Down = "j", Up = "k", Right = "l" }
  for arrow, window_direction in pairs(directions) do
    vim.keymap.set("n", "<C-" .. arrow .. ">", function()
      navigate(window_direction, arrow:lower())
    end, { desc = "Navigate Neovim or Rex " .. arrow:lower(), silent = true })
  end
  return true
end

return M
