-- Minimal opencode integration.
-- Discovers a running `opencode --port` process and appends text to its prompt.
local M = {}

--- Find the port of a running `opencode --port` process in the current CWD.
---@return number|nil port
function M.find_port()
  local pgrep = vim.system({ "pgrep", "-f", "opencode.*--port" }, { text = true }):wait()
  if pgrep.code ~= 0 or not pgrep.stdout then
    return nil
  end

  for pid_str in pgrep.stdout:gmatch("%d+") do
    local lsof = vim.system(
      { "lsof", "-w", "-iTCP", "-sTCP:LISTEN", "-P", "-n", "-a", "-p", pid_str },
      { text = true }
    ):wait()

    if lsof.code == 0 and lsof.stdout then
      for line in lsof.stdout:gmatch("[^\r\n]+") do
        local port_str = line:match(":(%d+)%s")
        if port_str then
          local port = tonumber(port_str)
          if port then
            return port
          end
        end
      end
    end
  end

  return nil
end

--- Append text to the opencode TUI prompt.
---@param port number
---@param text string
function M.append(port, text)
  local body = vim.fn.json_encode({
    type = "tui.prompt.append",
    properties = { text = text },
  })

  vim.system({
    "curl", "-s", "--connect-timeout", "1",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "-d", body,
    "http://localhost:" .. port .. "/tui/publish",
  })
end

--- Send context to opencode.
--- With a visual range: sends `filepath L1-L10`.
--- Without: sends `filepath`.
---@param opts { range: number, line1: number, line2: number }
function M.send(opts)
  local port = M.find_port()
  if not port then
    vim.notify("No running opencode found", vim.log.levels.WARN)
    return
  end

  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local text
  if opts.range ~= 0 then
    text = file .. " L" .. opts.line1 .. "-L" .. opts.line2 .. " "
  else
    text = file .. " "
  end

  M.append(port, text)
end

return M
