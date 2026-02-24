--- OpenCode integration: :Opencode [message] sends current file as context.

local M = {}

local BASE = "http://localhost:4096"

local function post(path, body)
  vim.system({
    "curl", "-s", "--connect-timeout", "1",
    "-X", "POST", "-H", "Content-Type: application/json",
    "-d", vim.fn.json_encode(body or {}),
    BASE .. path,
  }, { text = true }):wait()
end

local function get(path)
  local r = vim.system({
    "curl", "-s", "--connect-timeout", "1",
    BASE .. path,
  }, { text = true }):wait()
  local ok, obj = pcall(vim.fn.json_decode, r.stdout or "")
  return ok and obj or nil
end

function M.send(opts)
  local abs = vim.api.nvim_buf_get_name(0)
  local sessions = get("/session?limit=1&roots=true")
  if not sessions or #sessions == 0 then return end

  local url = "file://" .. abs
  if opts.range ~= 0 then
    url = ("%s?start=%d&end=%d"):format(url, opts.line1, opts.line2)
  end

  local parts = {{
    type = "file",
    mime = "text/plain",
    url = url,
    filename = vim.fn.fnamemodify(abs, ":."),
  }}
  if opts.args and opts.args ~= "" then
    parts[#parts + 1] = { type = "text", text = opts.args }
  end

  local sid = sessions[1].id
  post(("/session/%s/prompt_async"):format(sid), { parts = parts })
  post("/tui/select-session", { sessionID = sid })
end

return M
