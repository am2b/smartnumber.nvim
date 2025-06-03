local M = {}

--切换当前窗口的相对行号设置
local function set_relative_number(enabled)
    vim.wo.relativenumber = enabled
end

--插件初始化入口
function M.setup()
    local group = vim.api.nvim_create_augroup("smartnumber", { clear = true })

    --进入插入模式
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function()
            set_relative_number(false)
        end,
    })

    --离开插入模式
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function()
            set_relative_number(true)
        end,
    })

    --进入命令模式(包括:/?)
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = group,
        callback = function()
            set_relative_number(false)
            --强制刷新行号
            vim.cmd("redraw")
        end,
    })

    --离开命令模式
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = group,
        callback = function()
            set_relative_number(true)
        end,
    })

    --当前窗口获得焦点(vim自己分屏)
    vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function()
            local mode = vim.fn.mode()
            if mode == "i" then
                set_relative_number(false)
            else
                set_relative_number(true)
            end
        end,
    })

    --当前窗口失去焦点(vim自己分屏)
    vim.api.nvim_create_autocmd("WinLeave", {
        group = group,
        callback = function()
            set_relative_number(false)
        end,
    })

    --当前窗口获得焦点(tmux分屏)
    vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = function()
            local mode = vim.fn.mode()
            vim.wo.relativenumber = (mode ~= "i")
        end,
    })

    --当前窗口失去焦点(tmux分屏)
    vim.api.nvim_create_autocmd("FocusLost", {
        group = group,
        callback = function()
            vim.wo.relativenumber = false
        end,
    })

    --启动时初始化一次
    local mode = vim.fn.mode()
    if mode == "i" then
        set_relative_number(false)
    else
        set_relative_number(true)
    end
end

return M
