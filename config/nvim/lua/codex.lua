-- Codex integration: :Codex [message] pastes message + file reference.
-- Uses the current session's codex window in tmux or codex block in Rex.

local M = {}

local function file_reference(opts)
  local abs = vim.api.nvim_buf_get_name(0)
  if abs:match("^fugitive://") then
    abs = vim.fn.FugitiveReal(abs)
  end
  if abs == "" then
    vim.notify("Codex: current buffer has no filename", vim.log.levels.ERROR)
    return ""
  end

  local ref = vim.fn.fnamemodify(abs, ":.")
  if ref == "" then
    vim.notify("Codex: current buffer has no filename", vim.log.levels.ERROR)
    return ""
  end

  if opts.range ~= 0 then
    if opts.line1 == opts.line2 then
      return ("%s#L%d"):format(ref, opts.line1)
    end
    return ("%s#L%d-L%d"):format(ref, opts.line1, opts.line2)
  end

  return ref
end

-- Copy file reference into a system clipboard.
-- Includes selected lines range for visual selection.
function M.copy(opts)
  local ref = file_reference(opts)
  if ref == "" then
    return
  end

  vim.fn.setreg("+", ref)
end

-- Send selected ref along with the message to Codex instance in either Tmux or Rex
-- Tmux: look for a window named `codex`
-- Rex: look for a pane (block) named `codex`
function M.send(opts)
  local ref = file_reference(opts)
  if not ref then
    return
  end

  local payload = ref
  if opts.args ~= nil and opts.args ~= "" then
    payload = ref .. "\n" .. opts.args
  end

  if vim.env.TMUX then
    vim.system({ "tmux", "send-keys", "-l", "-t", ":codex", payload }):wait()
    vim.system({ "tmux", "select-window", "-t", ":codex" }):wait()
  elseif vim.env.REX_SESSION then
    local rex = require("rex")
    rex.block_send("codex", payload)
    rex.block_select("codex")
  else
    vim.notify("Codex: run Neovim inside tmux or Rex", vim.log.levels.ERROR)
  end
end

return M
