-- The prefix keeps the tmux keys while cmd+k clears the terminal.
rex.bind("ctrl+b>shift+r", "client.config.reload")
rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+b>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })
rex.bind("ctrl+b>s", "session.switch")
rex.bind("ctrl+b>shift+9", "session.previous")
rex.bind("ctrl+b>shift+0", "session.next")
rex.bind("ctrl+b>shift+;", "client.palette.toggle")
rex.bind("ctrl+b>n", "client.tab.next")
rex.bind("ctrl+b>p", "client.tab.previous")
rex.bind("ctrl+b>,", "pane.rename")
rex.bind("ctrl+b>o", "pane.focus_next")
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("shift+pageup", "client.scroll.page_up")
rex.bind("shift+pagedown", "client.scroll.page_down")

-- Number tabs within the current session; absent positions do nothing.
rex.action{
    name = "select_session_tab",
    title = "Select Tab in Current Session",
    args = { index = "integer" },
    run = function(ctx, args)
        local view, err = rex.session.view{ session_id = ctx.session_id }
        assert(view, err)
        local window = (view.windows or {})[args.index]
        if window then
            rex.client.queue("session.select", {
                session_id = ctx.session_id,
                window_id = window.window_id,
            })
        end
    end,
}

for index = 1, 9 do
    rex.bind("alt+" .. index, "select_session_tab", { index = index })
end

-- Detect local Neovim from the terminal's foreground process.
-- A missing foreground process counts as not Neovim; query errors stop navigation.
local function vim_is_running(block_id)
    local process, err = rex.block.call("com.superlogical.terminal", "process", { block_id = block_id })
    assert(process, err)
    return process.foreground ~= nil and process.foreground.name == "nvim"
end

rex.action{
    name = "navigate_vim_or_pane",
    title = "Navigate Vim or Pane",
    description = "Send Control and an arrow to Vim, or focus the adjacent Rex pane.",
    args = { direction = "string" },
    run = function(ctx, args)
        if vim_is_running(ctx.block_id) then
            rex.client.queue("pane.send_key", { key = "ctrl+" .. args.direction })
        else
            rex.client.queue("pane.focus", { direction = args.direction })
        end
    end,
}

for _, direction in ipairs({ "left", "down", "up", "right" }) do
    rex.bind("ctrl+" .. direction, "navigate_vim_or_pane", { direction = direction })
end

rex.action{
    name = "dotfiles_session",
    title = "Open Dotfiles Session",
    category = "Session",
    run = function()
        local existing, list_err = rex.call("session.list")
        assert(existing, list_err)
        for _, session in ipairs(existing.sessions or {}) do
            if session.label == "dotfiles" then
                rex.client.queue("session.select", { session_id = session.session_id })
                return
            end
        end

        local directory = os.getenv("HOME") .. "/.dotfiles"
        local session, err = rex.call("session.create", {
            label = "dotfiles",
            initial_windows = {
                {
                    window_label = "code",
                    layout = rex.layout.block{
                        flavor = "com.superlogical.terminal.shell",
                        options = { cwd = directory, initial_input = "nvim\n" },
                    },
                },
            },
        })
        assert(session, err)
        rex.client.queue("session.select", {
            session_id = session.session_id,
            window_id = session.initial_windows[1].window_id,
        })
    end,
}

rex.action{
    name = "codez_session",
    title = "Open Codez Session",
    category = "Session",
    run = function()
        local existing, list_err = rex.call("session.list")
        assert(existing, list_err)
        for _, session in ipairs(existing.sessions or {}) do
            if session.label == "asana-codez" then
                rex.client.queue("session.select", { session_id = session.session_id })
                return
            end
        end

        local directory = os.getenv("HOME") .. "/sandbox/asana"
        local session, err = rex.call("session.create", {
            label = "asana-codez",
            initial_windows = {
                {
                    window_label = "code",
                    layout = rex.layout.block{
                        flavor = "com.superlogical.terminal.shell",
                        options = { cwd = directory, initial_input = "nvim\n" },
                    },
                },
                {
                    window_label = "tests",
                    layout = rex.layout.block{
                        label = "tests",
                        flavor = "com.superlogical.terminal.shell",
                        options = { cwd = directory },
                    },
                },
                {
                    window_label = "server",
                    layout = rex.layout.block{
                        flavor = "com.superlogical.terminal.shell",
                        options = { cwd = directory, initial_input = "zsand-sync -k webapp\n" },
                    },
                },
                {
                    window_label = "codex",
                    layout = rex.layout.block{
                        label = "codex",
                        flavor = "com.superlogical.terminal.shell",
                        options = { cwd = directory, initial_input = "codex\n" },
                    },
                },
            },
        })
        assert(session, err)
        rex.client.queue("session.select", {
            session_id = session.session_id,
            window_id = session.initial_windows[1].window_id,
        })
    end,
}

