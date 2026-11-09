-- Rex operations for Neovim plugins. Uses the current Rex session from the environment.
local M = {}

--- Select a block by label or ID within the current session.
--- Shows its containing tab in the app before focusing the block.
--- Raises an error if the block cannot be resolved.
function M.block_select(block)
  local result = vim.system({ "rex", "block", "inspect", block, "--json" }, { text = true }):wait()
  assert(result.code == 0, result.stderr)
  local target = vim.json.decode(result.stdout)
  -- Server focus alone does not switch the visible tab in the app.
  vim.system({
    "rex", "do", "session.select",
    "session_id=" .. target.session_id,
    "window_id=" .. target.block.window_id,
  }):wait()
  return vim.system({ "rex", "focus", target.block.block_id }):wait()
end

--- Send literal text to a block by label or ID in the current session.
--- Does not append Enter or change focus. Returns the completed CLI result.
function M.block_send(block, text)
  return vim.system({ "rex", "send", "-b", block }, { stdin = text }):wait()
end

--- Send a list of keys using Rex syntax, such as { "enter", "ctrl+c" }.
--- Does not change focus. Returns the completed CLI result.
function M.block_send_keys(block, keys)
  local command = { "rex", "send-key", "-b", block }
  vim.list_extend(command, keys)
  return vim.system(command):wait()
end

return M
