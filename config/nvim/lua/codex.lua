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

local comparisons = {
  Staged = "staged (HEAD → index)",
  Unstaged = "unstaged (index → working tree)",
}

local function patch_path(header, prefix)
  local path = header:sub(5):gsub("\t$", "")
  if path ~= "/dev/null" then
    return (path:gsub('^("?)' .. prefix .. '/', "%1"))
  end
end

local function read_context(ctx, line)
  if ctx.status then
    local section = line:match("^(%a+) %(%d+%)$")
    if section then
      ctx.source = comparisons[section]
      ctx.file = nil
    elseif line:match("^[A-Z?] ") then
      -- Fugitive includes both paths in a rename row.
      ctx.file = line:sub(3)
    end
    return
  end

  local sha = line:match("^commit (%x+)")
  if sha then
    ctx.source = "commit " .. sha
    ctx.file = nil
  elseif line:match("^diff ") then
    ctx.old = nil
    ctx.file = nil
  elseif line:match("^%-%-%- ") then
    ctx.old = patch_path(line, "a")
  elseif line:match("^%+%+%+ ") then
    local new = patch_path(line, "b")
    ctx.file = new or ctx.old
    if new and ctx.old and new ~= ctx.old then
      ctx.file = ctx.old .. " → " .. new
    end
  end
end

local function format_hunk(ctx, lines, header, first, last)
  local parts = { "Source: " .. ctx.source, "File: " .. ctx.file, "Hunk: " .. lines[header] }
  for i = first, last do
    parts[#parts + 1] = lines[i]
  end
  return table.concat(parts, "\n")
end

local function git_file_reference(opts)
  -- A custom git show format can omit the commit header.
  local ctx = { status = vim.bo.filetype == "fugitive", source = "git patch" }
  local name = vim.api.nvim_buf_get_name(0)
  if not ctx.status and name:match("^fugitive://") then
    ctx.source = "commit " .. vim.fn.FugitiveParse(name)[1]
  end
  local selected = opts.range ~= 0
  local first, last = opts.line1, opts.line2
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local blocks = {}
  local i = 1
  while i <= last do
    if lines[i]:match("^@@+ %-") then
      local header = i
      i = i + 1
      while lines[i] and lines[i]:match("^[ +%-\\]") do
        i = i + 1
      end
      if i > first then
        local start = selected and math.max(header + 1, first) or header + 1
        local stop = selected and math.min(i - 1, last) or i - 1
        blocks[#blocks + 1] = format_hunk(ctx, lines, header, start, stop)
      end
    else
      read_context(ctx, lines[i])
      i = i + 1
    end
  end
  if #blocks == 0 then
    vim.notify("Codex: place the cursor or selection inside a diff hunk", vim.log.levels.WARN)
    return
  end
  return table.concat(blocks, "\n\n")
end

local function reference(opts)
  if vim.bo.filetype == "git" or vim.bo.filetype == "fugitive" then
    return git_file_reference(opts)
  end
  return file_reference(opts)
end

function M.copy(opts)
  local ref = reference(opts)
  if not ref then
    return
  end

  vim.fn.setreg("+", ref)
end

-- Send selected ref along with the message to Codex instance in either Tmux or Rex
-- Tmux: look for a window named `codex`
-- Rex: look for a pane (block) named `codex`
function M.send(opts)
  local ref = reference(opts)
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
