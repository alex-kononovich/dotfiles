-- Codex integration: :Codex [message] pastes message + file reference.
-- Uses the current session's codex window in tmux or codex block in Rex.

local M = {}

local function file_reference(opts)
  local abs = vim.api.nvim_buf_get_name(0)
  if abs == "" then
    vim.notify("Codex: current buffer has no filename", vim.log.levels.ERROR)
    return
  end

  local ref = vim.fn.fnamemodify(abs, ":.")
  if opts.range == 0 then
    return ref
  end
  if opts.line1 == opts.line2 then
    return ("%s#L%d"):format(ref, opts.line1)
  end
  return ("%s#L%d-L%d"):format(ref, opts.line1, opts.line2)
end

local function read_context(ctx, line, row)
  if ctx.status then
    local section = line:match("^(%a+) %(%d+%)$")
    if section then
      ctx.section = section
    elseif line:match("^[A-Z?] ") then
      ctx.file_row = row
    end
  else
    local sha = line:match("^commit (%x+)")
    if sha then
      ctx.source = "commit " .. sha
      ctx.file_row = nil
    elseif line:match("^diff ") or (line:match("^%-%-%- ") and not ctx.file_row) then
      ctx.file_row = row
    end
  end
end

local function prefixed_path(path, prefix)
  return (path:gsub('^("?)', "%1" .. prefix, 1))
end

local function status_header(header, section)
  -- Fugitive uses --no-prefix in the status view.
  local src, dst = "i/", "w/"
  if section == "Staged" then
    src, dst = "c/", "i/"
  end
  local before = header[#header - 1]:sub(5)
  local after = header[#header]:sub(5)
  if before ~= "/dev/null" then
    header[#header - 1] = "--- " .. prefixed_path(before, src)
  end
  if after ~= "/dev/null" then
    header[#header] = "+++ " .. prefixed_path(after, dst)
  end
  return table.concat(header, "\n")
end

local function file_header(ctx, lines)
  local patch, start = lines, ctx.file_row
  if ctx.status then
    -- Status hides file headers but records each offset in the patch used to expand the row.
    local section = ctx.section
    if not ctx.patches[section] then
      ctx.patches[section] = vim.fn.eval("b:fugitive_status.diff." .. section .. ".stdout")
    end
    patch = ctx.patches[section]
    local filename = lines[start]:sub(3)
    start = ctx.expanded[section][filename][1] + 1
  end

  local stop = start
  while not patch[stop + 1]:match("^@@") do
    stop = stop + 1
  end
  if patch[start]:match("^diff %-%-git ") and patch[stop]:match("^%+%+%+ ") then
    start = start + 1
  end
  if ctx.status then
    return status_header(vim.list_slice(patch, start, stop), ctx.section)
  end
  return table.concat(patch, "\n", start, stop)
end

local function fence_patch(parts)
  local body = table.concat(parts, "\n")
  local fence = "```"
  for ticks in body:gmatch("```+") do
    if #ticks >= #fence then
      fence = ticks .. "`"
    end
  end
  return table.concat({ fence .. "diff", body, fence }, "\n")
end

local function append_hunk(parts, ctx, lines, header, stop, opts)
  if ctx.source then
    parts[#parts + 1] = ctx.source
    ctx.source = nil
  end
  if ctx.file_row then
    parts[#parts + 1] = file_header(ctx, lines)
    ctx.file_row = nil
  end
  parts[#parts + 1] = lines[header]
  local start = header + 1
  if opts.range ~= 0 then
    start = math.max(start, opts.line1)
    stop = math.min(stop, opts.line2)
  end
  for row = start, stop do
    parts[#parts + 1] = lines[row]
  end
end

local function git_file_reference(opts)
  local ctx = { status = vim.bo.filetype == "fugitive" }
  local name = vim.api.nvim_buf_get_name(0)
  if ctx.status then
    ctx.expanded = vim.b.fugitive_expanded
    ctx.patches = {}
  elseif name:match("^fugitive://") then
    ctx.source = "commit " .. vim.fn.FugitiveParse(name)[1]
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parts = {}
  local i = 1
  while i <= opts.line2 do
    if lines[i]:match("^@@+ %-") then
      local header = i
      i = i + 1
      while lines[i] and lines[i]:match("^[ +%-\\]") do
        i = i + 1
      end
      if i > opts.line1 then
        append_hunk(parts, ctx, lines, header, i - 1, opts)
      end
    else
      read_context(ctx, lines[i], i)
      i = i + 1
    end
  end
  if #parts == 0 then
    vim.notify("Codex: place the cursor or selection inside a diff hunk", vim.log.levels.WARN)
    return
  end
  return fence_patch(parts)
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

function M.send(opts)
  local ref = reference(opts)
  if not ref then
    return
  end

  local payload = ref .. "\n" .. opts.args

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
