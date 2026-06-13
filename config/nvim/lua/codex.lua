-- Codex integration: :Codex [message] pastes message + file reference.
-- Relies on Codex being run in Tmux window named `codex`

local M = {}

local function file_reference(opts)
  local abs = vim.api.nvim_buf_get_name(0)
  if abs == "" then
    return nil
  end

  local ref = vim.fn.fnamemodify(abs, ":.")
  if ref == "" then
    return nil
  end

  if opts.range ~= 0 then
    if opts.line1 == opts.line2 then
      return ("%s#L%d"):format(ref, opts.line1)
    end
    return ("%s#L%d-L%d"):format(ref, opts.line1, opts.line2)
  end

  return ref
end

function M.send(opts)
  local ref = file_reference(opts)
  if not ref then
    vim.notify("Codex: current buffer has no filename", vim.log.levels.ERROR)
    return
  end

  local payload = ref
  if opts.args ~= nil and opts.args ~= "" then
    payload = ref .. "\n" .. opts.args
  end

  vim.system({ "tmux", "send-keys", "-l", "-t", "codex", payload }):wait()
  vim.system({ "tmux", "select-window", "-t", "codex" }):wait()
end

return M
