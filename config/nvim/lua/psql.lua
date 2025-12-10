local M = {}

-- state
local buf_id = nil
local win_id = nil
local connection = nil
local database_url = nil
local connection_name = nil
local query_start_time = nil
local query_end_time = nil
local statusline_redraw_timer = nil

-- const
local hi_ns = vim.api.nvim_create_namespace("psql")

local function redraw_statusline()
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim__redraw({ win = win_id, statusline = true })
  elseif statusline_redraw_timer then
    statusline_redraw_timer:close()
    statusline_redraw_timer = nil
  end
end

local function start_query_timer()
  query_end_time = nil
  query_start_time = vim.uv.hrtime()

  if not statusline_redraw_timer then
    statusline_redraw_timer = vim.uv.new_timer()
  end

  statusline_redraw_timer:start(200, 200, vim.schedule_wrap(redraw_statusline))
end

local function stop_query_timer()
  if statusline_redraw_timer then
    statusline_redraw_timer:stop()
  end

  query_end_time = vim.uv.hrtime()
end

local function reset_query_timer()
  query_start_time = nil
  query_end_time = nil
  redraw_statusline()
end

local function display_results(output)
  local activate_window = false

  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf_id })
    vim.api.nvim_set_option_value("filetype", "psql", { buf = buf_id })
    vim.api.nvim_buf_set_name(buf_id, "psql")
  end

  if not win_id or not vim.api.nvim_win_is_valid(win_id) then
    local preview_height = vim.api.nvim_get_option_value("previewheight", {}) or 12
    win_id = vim.api.nvim_open_win(
      buf_id,
      activate_window,
      { win = -1, split = "below", height = preview_height }
    )

    vim.api.nvim_set_option_value(
      "statusline",
      "%!v:lua.require'psql'.statusline()",
      { win = win_id }
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
  stop_query_timer()
  vim.schedule(redraw_statusline)

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
  reset_query_timer()
  clear_results()
  resolve_default_database_url()
  create_connection()

  if connection then
    connection:write(cmd .. "\n")

    -- Do not run timer for psql meta commands
    if string.sub(cmd, 1, 1) ~= [[\]] then
      start_query_timer()
    end
  end
end

local function run_query(query, marginalia)
  if not marginalia then
    marginalia = ""
  end

  local last_char = string.sub(query, -1)

  if last_char ~= ";" then
    query = query .. ";"
  end

  run(marginalia .. query)
end

-- Runs EXPLAIN on the query and opens result in a browser
local function run_explain_analyze(query, marginalia)
  if not marginalia then
    marginalia = ""
  end

  -- ensure query doesn't end with `;`, otherwise `\g` command wouldn't work
  local last_char = string.sub(query, -1)
  if last_char == ";" then
    query = string.sub(query, 0, -2)
  end

  -- Use vim.inspect to escape the query
  -- Single quote escape (') is based on this answer: https://stackoverflow.com/a/1250279
  local escaped_query = string.gsub(vim.inspect(query), [[']], [['"'"']])

  -- See https://www.postgresql.org/docs/16/app-psql.html#APP-PSQL-META-COMMAND-G
  local steps = {
    [[\g (format=unaligned tuples_only=on pager=off)]], -- Make sure output is pure JSON
    [[sed "s/'\\[.*\\]'/'\\[redacted\\]'/g"]], -- Remove large vectors as they slow down the explainer
    [[sed "s/'{.*}'/'{redacted}'/g"]], -- Remove large arrays as they slow down the explainer
    string.format([[jq '{ query: %s, plan: .|tojson }']], escaped_query),
    [[curl "https://explain.dalibo.com/new.json" -H "Content-Type: application/json" -s -d @-]],
    [[jq -r '@uri "https://explain.dalibo.com/plan/\(.id)"']],
    [[xargs -n1 -I url /bin/bash -c 'echo url; open url']],
  }

  local g_command = table.concat(steps, " | ")

  run(marginalia .. "EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON) " .. query .. g_command)
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
    reset_query_timer()
    clear_results()
    return
  end

  local s_row, s_col, e_row, e_col = node:range()
  local hl_s_row, hl_s_col, hl_e_row, hl_e_col = node:range()
  local query_lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
  local query = table.concat(query_lines, "\n")

  local marginalia = ""
  local maybe_marginalia = node:prev_sibling()
  if maybe_marginalia and maybe_marginalia:type() == "marginalia" then
    local ms_row, ms_col, me_row, me_col = maybe_marginalia:range()
    hl_s_row = ms_row
    hl_s_col = ms_col
    local marginalia_lines = vim.api.nvim_buf_get_text(0, ms_row, ms_col, me_row, me_col, {})
    marginalia = table.concat(marginalia_lines, "\n")
  end

  -- highlight running query
  vim.hl.range(0, hi_ns, "Visual", { hl_s_row, hl_s_col }, { hl_e_row, hl_e_col }, { timeout = 300 })

  if explain then
    run_explain_analyze(query, marginalia)
  else
    run_query(query, marginalia)
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

function M.statusline()
  local conn = connection_name or ""

  local query_timing = ""
  if query_start_time then
    local endtime = query_end_time or vim.uv.hrtime()
    local elapsed_ms = (endtime - query_start_time) / 1000000

    if elapsed_ms < 1000 then
      query_timing = string.format(" %dms", elapsed_ms)
    elseif elapsed_ms < 60000 then
      query_timing = string.format(" %.2fs", elapsed_ms / 1000)
    else
      query_timing = string.format(" %.2fm", elapsed_ms / 60000)
    end
  end

  return "%f" .. query_timing .. "%=" .. conn
end

return M
