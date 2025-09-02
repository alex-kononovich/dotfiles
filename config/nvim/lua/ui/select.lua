-- Replacement for `vim.ui.select`

local Input = require("ui/input")

---@alias Highlight string
---@alias Line [string, Highlight][]
---@alias Item any

local List = {
  buf_id = nil,
  win_id = nil,
  extmark_ns_id = nil,
  extmark_id = nil,
  width = nil,
}

---@param width number
function List.create(width)
  List.destroy()
  List.buf_id = vim.api.nvim_create_buf(false, true)
  List.win_id = vim.api.nvim_open_win(List.buf_id, false, {
    relative = "cursor",
    row = 0,
    col = -1,
    style = "minimal",
    width = width,
    height = 1,
    focusable = false,
  })
  List.extmark_ns_id = vim.api.nvim_create_namespace("custom_ui_select")
  List.width = width
end

function List.destroy()
  if List.win_id and vim.api.nvim_win_is_valid(List.win_id) then
    vim.api.nvim_win_close(List.win_id, true)
    List.win_id = nil
  end

  if List.buf_id then
    vim.api.nvim_buf_delete(List.buf_id, { force = true })
    List.buf_id = nil
  end

  List.width = nil
end

-- Returns shortcut icon if possible, otherwise empty placeholder
local function shortcut_icon(index)
  local unicode_num_keys =
    { "1⃣", "2⃣", "3⃣", "4⃣", "5⃣", "6⃣", "7⃣", "8⃣", "9⃣" }
  return unicode_num_keys[index] or " "
end

---@param items Item[]
---@param selected_index number
---@param format_item fun(item: Item, width: number):Line
function List.render(items, selected_index, format_item)
  -- Clear previous draw
  if List.extmark_id then
    vim.api.nvim_buf_del_extmark(List.buf_id, List.extmark_ns_id, List.extmark_id)
  end

  local lines = {}
  for i = 1, #items do
    local shortcut = shortcut_icon(i) .. "  "
    local line = format_item(items[i], List.width - 3)
    table.insert(line, 1, { shortcut, "NonText" })

    if i == selected_index then
      -- Switch highlight group to Visual
      for j = 1, #line do
        line[j][2] = "Visual"
      end
    end

    table.insert(lines, line)
  end

  if #lines < 1 then
    lines = { { { "No matches", "NonText" } } }
  end

  List.extmark_id = vim.api.nvim_buf_set_extmark(List.buf_id, List.extmark_ns_id, 0, 0, {
    virt_lines = lines,
    end_row = 0,
  })

  vim.api.nvim_win_set_height(List.win_id, #lines + 1)
end

---@param item { action: { title: string }, ctx: { client_id: number } }
---@param width number
---@return Line
local function format_codeaction_item(item, width)
  -- TODO: truncate title to fit client name
  local title = item.action.title
  local title_length = #title:gsub("[\128-\191]", "")
  local client_name = vim.lsp.get_client_by_id(item.ctx.client_id).name

  -- TODO: ensure padding is at least one space
  local padding = string.rep(" ", width - title_length - #client_name)

  return {
    { title, "Normal" },
    { padding, "NonText" },
    { client_name, "NonText" },
  }
end

local Select = {}

---@param items Item[]
---@param opts { prompt: string|nil, kind: string|nil, format_item: fun(item: Item):string }
---@param on_choice fun(item?: Item, index: integer?):nil
function Select.create(items, opts, on_choice)
  local selected_index = 1
  local filtered_items = items
  local format_item = opts.format_item or tostring

  ---@param item_index number|nil
  local function commit_selection(item_index)
    local can_be_selected = item_index
      and #filtered_items > 0
      and item_index > 0
      and item_index <= #filtered_items

    if can_be_selected then
      on_choice(filtered_items[item_index], item_index)
    else
      on_choice(nil)
    end

    Input.destroy()
    List.destroy()
  end

  -- Handle <Enter> and <Esc>.
  -- If `selection_confirmed` is `nil` it means user has cancelled.
  local function on_make_selection(selection_confirmed)
    if not selection_confirmed then
      commit_selection(nil)
    else
      commit_selection(selected_index)
    end
  end

  local function render()
    List.render(filtered_items, selected_index, function(item, width)
      if opts.kind == "codeaction" then
        return format_codeaction_item(item, width)
      else
        return { { format_item(item), "Normal" } }
      end
    end)
  end

  local function move_selection_previous()
    selected_index = selected_index - 1

    -- Loop
    if selected_index < 1 then
      selected_index = #filtered_items
    end

    render()
  end

  local function move_selection_next()
    selected_index = selected_index + 1

    -- Loop
    if selected_index > #filtered_items then
      selected_index = 1
    end

    render()
  end

  local function filter_list()
    local query = Input.get_value()

    if query == "" then
      filtered_items = items
    else
      filtered_items = vim.fn.matchfuzzy(items, query, { text_cb = format_item })
    end

    selected_index = 1
    render()
  end

  Input.create({
    prompt = opts.prompt,
    border = { "┌", "─", "┐", "│", "┤", "─", "├", "│" },
    input_prompt = "> ",
  }, on_make_selection)
  List.create(Input.width)

  vim.keymap.set("i", "<C-n>", move_selection_next, { buffer = Input.buf_id })
  vim.keymap.set("i", "<C-p>", move_selection_previous, { buffer = Input.buf_id })
  for i = 1, 9 do
    local select_item_by_index = function()
      commit_selection(i)
    end
    vim.keymap.set("i", tostring(i), select_item_by_index, { buffer = Input.buf_id })
  end

  vim.api.nvim_create_autocmd("TextChangedI", { callback = filter_list, buffer = Input.buf_id })

  render()
end

return Select
