-- keyshow.lua
-- Displays currently pressed keystrokes in a floating window
local M = {}

local config = {
    -- Window position: "bottom-right" | "bottom-left" | "top-right" | "top-left" | "bottom-center"
    position = "bottom-right",
    -- Padding from edge of screen
    margin = {
        x = 4,
        y = 2
    },
    -- How long (ms) to keep a key visible after the last keystroke
    timeout = 1500,
    -- Max number of keys to show in history
    max_keys = 6,
    -- Show mode prefix (e.g. "N ❯", "I ❯")
    show_mode = true,
    -- Minimum window width
    min_width = 10,
    -- Border style: "rounded" | "single" | "double" | "solid" | "shadow" | "none"
    border = "rounded",
    -- Ignored keys
    ignored_keys = {
        ["<MouseMove>"] = true,
        ["<ScrollWheelUp>"] = true,
        ["<ScrollWheelDown>"] = true,
        ["<ScrollWheelLeft>"] = true,
        ["<ScrollWheelRight>"] = true,
        ["<S-ScrollWheelUp>"] = true,
        ["<S-ScrollWheelDown>"] = true,
        ["<S-ScrollWheelLeft>"] = true,
        ["<S-ScrollWheelRight>"] = true,
        ["<C-ScrollWheelUp>"] = true,
        ["<C-ScrollWheelDown>"] = true,
        ["<C-ScrollWheelLeft>"] = true,
        ["<C-ScrollWheelRight>"] = true,
        ["<M-ScrollWheelUp>"] = true,
        ["<M-ScrollWheelDown>"] = true,
        ["<M-ScrollWheelLeft>"] = true,
        ["<M-ScrollWheelRight>"] = true,
        ["<LeftMouse>"] = true,
        ["<LeftRelease>"] = true,
        ["<RightMouse>"] = true,
        ["<RightRelease>"] = true
    }
}

local state = {
    buf = nil,
    win = nil,
    keys = {},
    timer = nil
}

-- Map of special key names to display strings
local special_keys = {
    ["<Space>"] = "SPC",
    ["<CR>"] = "RET",
    ["<Esc>"] = "ESC",
    ["<Tab>"] = "TAB",
    ["<BS>"] = "BSP",
    ["<Del>"] = "DEL",
    ["<Up>"] = "UP",
    ["<Down>"] = "DOWN",
    ["<Left>"] = "LEFT",
    ["<Right>"] = "RIGHT",
    ["<PageUp>"] = "PgUp",
    ["<PageDown>"] = "PgDn",
    ["<Home>"] = "Home",
    ["<End>"] = "End",
    ["<Insert>"] = "INS",
    ["<C-c>"] = "C-c",
    ["<C-v>"] = "C-v",
    ["<C-x>"] = "C-x",
    ["<C-z>"] = "C-z",
    ["<C-a>"] = "C-a",
    ["<C-s>"] = "C-s",
    ["<C-d>"] = "C-d",
    ["<C-f>"] = "C-f",
    ["<C-r>"] = "C-r",
    ["<C-u>"] = "C-u",
    ["<C-o>"] = "C-o",
    ["<C-w>"] = "C-w",
    ["<C-p>"] = "C-p",
    ["<C-n>"] = "C-n",
    ["<leader>"] = "LDR"
}

local mode_labels = {
    n = "NOR",
    i = "INS",
    v = "VIS",
    V = "V-L",
    ["\22"] = "V-B",
    c = "CMD",
    s = "SEL",
    t = "TRM",
    R = "REP",
    no = "OPR",
    x = "VIS"
}

local function get_mode_label()
    local mode = vim.api.nvim_get_mode().mode
    return mode_labels[mode] or mode:upper()
end

local function format_key(key)
    if special_keys[key] then
        return special_keys[key]
    end
    -- Detect <C-x> style keys not in the table
    if key:match("^<.+>$") then
        local inner = key:sub(2, -2)
        return string.format(config.special_key_fmt, inner)
    end
    return key
end

local function build_display_text()
    local parts = {}
    if config.show_mode then
        table.insert(parts, get_mode_label() .. " ❯")
    end
    for _, k in ipairs(state.keys) do
        table.insert(parts, format_key(k))
    end
    return table.concat(parts, " ")
end

local function get_win_position(width, height)
    local lines = vim.o.lines
    local cols = vim.o.columns
    local mx, my = config.margin.x, config.margin.y

    local positions = {
        ["bottom-right"] = {
            row = lines - height - my - 2,
            col = cols - width - mx
        },
        ["bottom-left"] = {
            row = lines - height - my - 2,
            col = mx
        },
        ["top-right"] = {
            row = my,
            col = cols - width - mx
        },
        ["top-left"] = {
            row = my,
            col = mx
        },
        ["bottom-center"] = {
            row = lines - height - my - 2,
            col = math.floor((cols - width) / 2)
        }
    }

    return positions[config.position] or positions["bottom-right"]
end

local function close_window()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.win = nil
end

local function ensure_buf()
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        state.buf = vim.api.nvim_create_buf(false, true)
        vim.bo[state.buf].buftype = "nofile"
        vim.bo[state.buf].bufhidden = "wipe"
        vim.bo[state.buf].swapfile = false
        vim.bo[state.buf].filetype = "keyshow"
    end
    return state.buf
end

local function open_or_update_window()
    local text = build_display_text()
    local width = math.max(#text + 2, config.min_width)
    local pos = get_win_position(width, 1)

    local buf = ensure_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {" " .. text .. " "})

    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_set_config(state.win, {
            relative = "editor",
            row = pos.row,
            col = pos.col,
            width = width,
            height = 1
        })
    else
        state.win = vim.api.nvim_open_win(buf, false, {
            relative = "editor",
            row = pos.row,
            col = pos.col,
            width = width,
            height = 1,
            focusable = false,
            style = "minimal",
            border = config.border,
            zindex = 200
        })
        -- Highlight overrides
        vim.wo[state.win].winhl = "Normal:KeyShowNormal,FloatBorder:KeyShowBorder"
        vim.wo[state.win].wrap = false
    end
end

local function reset_timer()
    if state.timer then
        state.timer:stop()
        state.timer:close()
        state.timer = nil
    end

    state.timer = vim.uv.new_timer()
    state.timer:start(config.timeout, 0, vim.schedule_wrap(function()
        state.keys = {}
        close_window()
        if state.timer then
            state.timer:stop()
            state.timer:close()
            state.timer = nil
        end
    end))
end

local function on_key(key)
    -- Skip purely internal/silent sequences
    if key == "" then
        return
    end
    if config.ignored_keys[key] then
        return
    end

    -- Trim to max history
    table.insert(state.keys, key)
    if #state.keys > config.max_keys then
        table.remove(state.keys, 1)
    end

    open_or_update_window()
    reset_timer()
end

function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})

    -- Define highlight groups (user can override in colorscheme)
    vim.api.nvim_set_hl(0, "KeyShowNormal", {
        link = "NormalFloat",
        default = true
    })
    vim.api.nvim_set_hl(0, "KeyShowBorder", {
        link = "FloatBorder",
        default = true
    })

    -- Register key listener (non-recursive, catches every key)
    vim.on_key(function(key, _typed)
        vim.schedule(function()
            on_key(vim.fn.keytrans(key))
        end)
    end)

    -- Re-position on resize
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if state.win and vim.api.nvim_win_is_valid(state.win) then
                open_or_update_window()
            end
        end
    })
end

--- Toggle the keyshow window visibility
function M.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
        state.keys = {}
    else
        open_or_update_window()
    end
end

--- Manually clear key history
function M.clear()
    state.keys = {}
    close_window()
end

return M
