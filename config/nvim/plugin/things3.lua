-- Things 3 integration: show and complete current task
--
-- Commands:
-- :Todo
-- :Todo complete

-- Show the topmost item on the list
local show_todo_script = [=[
tell application "Things3"
  repeat with todo in to dos of list "Today"
    if status of todo is open then
      return name of todo
    end if
  end repeat
end tell
]=]

-- Complete the topmost item on the list
local complete_todo_script = [=[
tell application "Things3"
  repeat with todo in to dos of list "Today"
    if status of todo is open then
      set status of todo to completed
      return name of todo
    end if
  end repeat
end tell
]=]

-- Run given script and print its output
--- @param icon string Icon to use when printing results
--- @param script string AppleScript to run
local function run_todo_script(icon, script)
  local output = vim.fn.trim(vim.fn.system("osascript -e '" .. script .. "'"))

  print(icon .. " " .. output)
end

vim.api.nvim_create_user_command("Todo", function(opts)
  local complete = opts.fargs[1] == "complete"

  if complete then
    run_todo_script("☑︎", complete_todo_script)
  else
    run_todo_script("□", show_todo_script)
  end
end, { nargs = "?", complete = function() return { "complete" } end})
