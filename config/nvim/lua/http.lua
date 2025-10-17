local M = {}

-- state
local buf_id = nil
local win_id = nil

local function display_results(output)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf_id })
    -- TODO: read file type from "Content-Type" header
    vim.api.nvim_set_option_value("filetype", "json", { buf = buf_id })
    vim.api.nvim_buf_set_name(buf_id, "json") -- TODO: name to include URL
  end

  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    win_id = vim.api.nvim_open_win(buf_id, false, { split = "right" })
  end

  vim.api.nvim_win_set_buf(win_id, buf_id)

  local lines = vim.split(output, "\n")

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_id })
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, true, lines)
  require("conform").format({ bufnr = buf_id, quiet = true }, function()
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })
  end)
end

local function clear_results()
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_id })
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, true, {})
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })
end

---@return table request for the current cursor position
local function parse_request()
  local config = vim.b.http or { headers = {} }
  local request_node = vim.treesitter.get_node()

  while request_node and request_node:type() ~= "request" do
    request_node = request_node:parent()
  end

  local request = {
    headers = config.headers,
  }

  for child, name in request_node:iter_children() do
    if name == "method" then
      request.method = vim.treesitter.get_node_text(child, 0)
    end

    if name == "url" then
      request.url = vim.treesitter.get_node_text(child, 0)

      if config.host then
        request.url = config.host .. request.url
      end
    end

    if name == "body" then
      request.body = vim.treesitter.get_node_text(child, 0)
    end

    if name == "header" then
      local header_name = vim.treesitter.get_node_text(child:named_child(0), 0)
      local header_value = vim.treesitter.get_node_text(child:named_child(1), 0)
      request.headers[header_name] = header_value
    end
  end

  return request
end

local function curl_cmd(request)
  local extra_flags = (vim.b.http and vim.b.http.flags) or {}

  local cmd = vim.list_extend({ "curl", "--silent" }, extra_flags)

  if request.method then
    table.insert(cmd, "-X" .. request.method)
  end

  if request.url then
    table.insert(cmd, request.url)
  end

  if request.body then
    table.insert(cmd, "-d" .. request.body)
  end

  if request.headers then
    for name, value in pairs(request.headers) do
      table.insert(cmd, "-H")
      table.insert(cmd, name .. ":" .. value)
    end
  end

  return cmd
end

local function on_io(err, data)
  if err then
    vim.schedule(function()
      vim.notify(err, vim.log.levels.ERROR)
    end)
  end

  if data and data ~= "" then
    vim.schedule(function()
      display_results(data)
    end)
  else
  end
end

local on_exit = function(obj)
  if obj.code ~= 0 then
    local message = string.format("curl exited with code: %s", obj.code)

    if obj.stderr then
      message = message .. "\n" .. obj.stderr
    end

    if obj.stdout then
      message = message .. "\n" .. obj.stdout
    end

    vim.schedule(function()
      vim.notify(message, vim.log.levels.ERROR)
    end)
  end
end

function M.run()
  clear_results()

  local request = parse_request()
  local cmd = curl_cmd(request)

  vim.system(cmd, { text = true, stdout = on_io, stderr = on_io }, on_exit)
end

return M
