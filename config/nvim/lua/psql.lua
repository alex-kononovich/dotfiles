local M = {}

-- state
local buf_id = nil
local win_id = nil
local connection = nil
local database_url = nil
local connection_name = nil

-- const
local hi_ns = vim.api.nvim_create_namespace("psql")

local function display_results(output)
  local activate_window = false

  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf_id })
    vim.api.nvim_set_option_value("filetype", "psql", { buf = buf_id })
  end

  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    local preview_height = vim.api.nvim_get_option_value("previewheight", {}) or 12
    win_id = vim.api.nvim_open_win(
      buf_id,
      activate_window,
      { win = -1, split = "below", height = preview_height }
    )
  end

  local lines = vim.split(output, "\n")

  -- Join last existing line and first new line in case IO buffer was flushed in a middle of a line
  if lines[1] then
    local last_chunk = vim.api.nvim_buf_get_text(buf_id, -1, 0, -1, -1, {})[1]
    lines[1] = last_chunk .. lines[1]
  end

  -- Remove last line if empty
  while lines[#lines] == "" do
    table.remove(lines, #lines)
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_id })
  vim.api.nvim_buf_set_lines(buf_id, -2, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })

  vim.api.nvim_win_set_buf(win_id, buf_id)
  if activate_window then
    vim.api.nvim_set_current_win(win_id)
  end

  vim.api.nvim_buf_set_name(buf_id, "psql [" .. tostring(connection_name) .. "]")
end

local function clear_results()
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_id })
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, true, {})
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })
end

local on_exit = function(obj)
  local message =
    string.format("psql exited with code: %s\n%s\n%s", obj.code, obj.stderr or "", obj.stdout or "")

  vim.schedule(function()
    clear_results()
    display_results(message)
  end)

  connection = nil
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

local function get_config_key(key)
  if vim.g.psql and vim.g.psql.connections then
    return vim.g.psql.connections[key]
  end
end

local function resolve_default_database_url()
  if not database_url then
    local default_alias = get_config_key("default")
    if default_alias then
      connection_name = default_alias
      database_url = get_config_key(default_alias)
    else
      database_url = vim.env.DATABASE_URL
      connection_name = database_url
    end
  end
end

local function create_connection()
  if not connection or connection:is_closing() then
    if not database_url then
      vim.notify("psql: no database to connect", vim.log.levels.ERROR)
      return
    end

    connection = vim.system(
      { "psql", database_url },
      { stdin = true, stdout = on_io, stderr = on_io },
      on_exit
    )
  end

  return connection
end

---@param cmd string Input to send to `psql`
local function run(cmd)
  clear_results()
  resolve_default_database_url()
  create_connection()

  if connection then
    connection:write(cmd .. "\n")
  end
end

local function run_query(query)
  local last_char = string.sub(query, -1)

  if last_char ~= ";" then
    query = query .. ";"
  end

  run(query)
end

-- Runs EXPLAIN on the query and opens result in a browser
local function run_explain_analyze(query)
  local g_command =
    [[\g (format=unaligned tuples_only=on pager=off) | jq '{ query: %s, plan: .|tojson }' | curl "https://explain.dalibo.com/new.json" -H "Content-Type: application/json" -d @- -s | jq -r '@uri "https://explain.dalibo.com/plan/\(.id)"' | xargs open]]

  -- ensure query doesn't end with `;`, otherwise `\g` command wouldn't work
  local last_char = string.sub(query, -1)
  if last_char == ";" then
    query = string.sub(query, 0, -2)
  end

  run(
    "EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON) "
      .. query
      .. string.format(g_command, vim.inspect(query))
  )
end

function M.run_visual_selection(explain)
  local selected_region =
    vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
  local query = table.concat(selected_region, "\n")

  if explain then
    run_explain_analyze(query)
  else
    run(query)
  end
end

function M.run_current_statement(explain)
  -- Find statement related to current cursor position
  local node = vim.treesitter.get_node()

  while node and node:type() ~= "statement" do
    node = node:parent()
  end

  if not node then
    clear_results()
    return
  end

  local s_row, s_col, e_row, e_col = node:range()

  vim.hl.range(0, hi_ns, "Visual", { s_row, s_col }, { e_row, e_col }, { timeout = 300 })

  local lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
  local query = table.concat(lines, "\n")

  if explain then
    run_explain_analyze(query)
  else
    run_query(query)
  end
end

function M.process_user_command(opts)
  if opts.fargs[1] == "connect" then
    connection_name = opts.fargs[2]
    database_url = get_config_key(connection_name) or connection_name
    if database_url then
      run("\\connect " .. database_url)
    else
      vim.notify("psql: no database to connect", vim.log.levels.ERROR)
    end
  else
    local cmd = table.concat(opts.fargs, " ")
    if cmd == "" then
      cmd = "\\?"
    end
    run(cmd)
  end
end

return M
