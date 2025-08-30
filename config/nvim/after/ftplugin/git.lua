-- Override `gx` for git buffers to open GitHub PRs if called on a PR number

if not vim.b.loaded_gx_github then
  --- @param error string
  local function show_error(error)
    vim.notify(error, vim.log.levels.ERROR)
  end

  --- @param pr_number number
  local function open_github_pr(pr_number)
    local cmd, err = vim.ui.open(pr_number, { cmd = { "gh", "pr", "view", "--web" } })

    if err then
      show_error(err)
    elseif cmd then
      local result = cmd:wait()

      if result.code ~= 0 then
        show_error(result.stderr)
      end
    end
  end

  local function open_github_or_jira()
    local current_word = vim.fn.expand("<cWORD>")

    if current_word:match("#%d+") then
      local pr_number = current_word:match("%d+")
      open_github_pr(pr_number)
    elseif current_word:match("%u%u%u+%-%d+") then
      local jira_issue = current_word:match("%u%u%u+%-%d+")
      print("Not implemented: opening JIRA ticket " .. jira_issue)
    else
      -- fall back to `vim.ui.open`
      vim.ui.open(current_word)
    end
  end

  local gx_desc = "Open PR in GitHub"
  vim.keymap.set(
    { "n", "v" },
    "gx",
    open_github_or_jira,
    { noremap = true, buffer = true, desc = gx_desc }
  )
end

vim.b.loaded_gx_github = true
