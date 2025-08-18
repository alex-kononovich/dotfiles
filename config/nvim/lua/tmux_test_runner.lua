---cSpell:dictionaries vim,cpp

-- Runs a command in `tests` Tmux pane
--- @param cmd string
local function run_in_tests_pane(cmd)
  vim.cmd("update") -- save current buffer
  vim.system({"tmux", "send-keys", "-t", "tests", cmd, "Enter"}) -- type in tests followed by Enter
  vim.system({"tmux", "select-window", "-t", "tests"}) -- switch to tests
end

local tmuxTestRunnerGroup = vim.api.nvim_create_augroup("Tmux test runner", { clear = true })

local M = {}

-- Sets up a key mapping to run current file in `tests` Tmux pane.
-- The mapping will invoke `cmd` with current file name and switch to `tests` pane.
-- Example:
-- ```lua
-- -- Project-specific .nvim.lua
-- local rt = require("tmux_test_runner")
-- rt.create_run_test_keymapping({"*.test.js", "*.test.ts", "*.test.tsx"}, "jest")
-- rt.create_run_test_keymapping("*_test.rb", "bin/rails test")
-- ```
--
---@param pattern string|string[] `BufReadPost`-compatible pattern of files to attach keymapping to.
---@param cmd string command to run.
---@param keymapping? string keymapping to create. Default is `<leader>rt`.
---@param desc? string description for created keymapping. Default is "Run current test".
function M.create_run_test_keymapping(pattern, cmd, keymapping, desc)
  keymapping = keymapping or "<leader>rt"
  desc = desc or "Run current test"

  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = pattern,
    callback = function()
      vim.keymap.set("n", keymapping, function()
        run_in_tests_pane(cmd.." "..vim.fn.expand("%:."))
      end, { desc = desc, nowait = true, buffer = true })
    end,
    group = tmuxTestRunnerGroup
  })
end

-- Adds a key mapping to re-run last command in `tests` Tmux pane.
--
---@param keymapping? string keymapping to create. Default is `<leader>rr`.
function M.create_rerun_last_command_keymapping(keymapping)
  keymapping = keymapping or "<leader>rr"

  vim.keymap.set("n", keymapping, function()
    run_in_tests_pane("Up") -- Up is a special key in `tmux send-keys` and maps to Up key
  end, { nowait = true, desc = "Rerun last command in `tests` Tmux pane" })
end

return M
