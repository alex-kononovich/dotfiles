-- Replacement for `vim.ui.input`

local Input = {
  buf_id = nil,
  win_id = nil,
  width = 60,
  prompt = "",
}

local focus_timer = nil

-- Formats prompt by padding it with spaces
---@param prompt string|nil
---@return string|nil
local function format_title(prompt)
  if not prompt then
    return nil
  end

  -- If prompt ends with a space
  if prompt:sub(-1, -1) == " " then
    return " " .. prompt
  else
    return " " .. prompt .. " "
  end
end

-- Create and show the input
---@param opts { prompt: string|nil, default: string|nil, border?: string[], input_prompt?: string }
---@param on_confirm fun(user_input: string|nil):nil
function Input.create(opts, on_confirm)
  Input.destroy()

  local window_opts = {
    relative = "cursor",
    row = 1,
    col = 0,
    style = "minimal",
    title = format_title(opts.prompt),
    width = Input.width,
    height = 1,
    border = opts.border,
  }

  Input.prompt = opts.input_prompt or Input.prompt or ""

  focus_timer = vim.uv.new_timer()
  Input.buf_id = vim.api.nvim_create_buf(false, true)
  Input.win_id = vim.api.nvim_open_win(Input.buf_id, true, window_opts)

  vim.api.nvim_buf_set_option(Input.buf_id, "buftype", "prompt")
  vim.fn.prompt_setprompt(Input.buf_id, Input.prompt)

  vim.cmd.startinsert()

  if opts.default then
    local placeholder = opts.default
    vim.api.nvim_buf_set_lines(Input.buf_id, 0, 1, true, { placeholder })
    vim.api.nvim_win_set_cursor(Input.win_id, { 1, #placeholder })
  end

  local function cancel()
    on_confirm(nil)
    Input.destroy()
  end

  local function confirm()
    on_confirm(Input.get_value())
    Input.destroy()
  end

  local check_focus = vim.schedule_wrap(function()
    local is_cur_win = vim.api.nvim_get_current_win() == Input.win_id

    if not is_cur_win then
      cancel()
    end
  end)

  vim.api.nvim_buf_set_keymap(Input.buf_id, "i", "<Esc>", "", { callback = cancel })
  vim.api.nvim_buf_set_keymap(Input.buf_id, "i", "<C-c>", "", { callback = cancel })
  vim.api.nvim_buf_set_keymap(Input.buf_id, "i", "<Enter>", "", { callback = confirm })
  vim.api.nvim_buf_set_keymap(Input.buf_id, "i", "<C-x>", "", {}) -- prevent autocomplete
  vim.api.nvim_buf_set_keymap(Input.buf_id, "i", "<C-w>", "<C-s-w>", {}) -- fix for <C-w> in `prompt` buffer

  focus_timer:start(1000, 1000, check_focus)
end

-- Destroys the input completely
function Input.destroy()
  if Input.win_id and vim.api.nvim_win_is_valid(Input.win_id) then
    vim.api.nvim_win_close(Input.win_id, true)
    Input.win_id = nil
  end

  if Input.buf_id then
    vim.api.nvim_buf_delete(Input.buf_id, { force = true })
    Input.buf_id = nil
    vim.cmd.stopinsert()
  end

  if focus_timer then
    focus_timer:close()
    focus_timer = nil
  end
end

-- Returns text entered into the input
---@return string
function Input.get_value()
  local line = vim.api.nvim_buf_get_lines(Input.buf_id, 0, 1, true)[1]
  local value, _ = line:gsub(Input.prompt, "")
  return value
end

return Input
