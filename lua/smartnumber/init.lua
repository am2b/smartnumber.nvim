local M = {}

--"正常模式"应恢复的相对行号基线
--默认尊重用户启动时的 relativenumber 设置;也可用 opts.relative 显式指定
local base_relnum = false

--当前是否处于插入模式(由InsertEnter/InsertLeave维护)
local in_insert = false

--切换当前窗口的相对行号设置
local function set_relative_number(enabled)
    --对帮助/终端/qf/无文件名等特殊buffer不做切换
    local bt = vim.bo.buftype
    --"":普通buffer
    --acwrite:特殊的"可写入,但保存行为由插件/脚本接管"的buffer
    if bt ~= "" and bt ~= "acwrite" then
        return
    end

    vim.wo.relativenumber = enabled
end

--插件初始化入口
function M.setup(opts)
    if not vim.opt.number:get() then
        vim.notify("smartnumber.nvim:请开启vim.opt.number = true,否则插入模式下行号会消失", vim.log.levels.WARN)
    end

    opts = opts or {}

    if opts.relative ~= nil then
        base_relnum = opts.relative
    else
        base_relnum = vim.opt.relativenumber:get()
    end

    --用户没开相对行号:插件不接管relativenumber,直接返回(全程绝对行号)
    if not base_relnum then
        return
    end

    local group = vim.api.nvim_create_augroup("smartnumber", { clear = true })

    --用in_insert标志维护插入状态
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function()
            in_insert = true
            set_relative_number(false)
        end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function()
            in_insert = false
            set_relative_number(true)
        end,
    })

    --命令模式(包括:/?)
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = group,
        callback = function()
            set_relative_number(false)
            vim.cmd("redraw")
        end,
    })

    --离开命令模式:按in_insert恢复(兼容ctrl-O从插入模式进命令行的场景)
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = group,
        callback = function()
            set_relative_number(not in_insert)
        end,
    })

    --当前窗口获得焦点(vim自己分屏)
    vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function()
            set_relative_number(not in_insert)
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
            set_relative_number(not in_insert)
        end,
    })

    --当前窗口失去焦点(tmux分屏)
    vim.api.nvim_create_autocmd("FocusLost", {
        group = group,
        callback = function()
            set_relative_number(false)
        end,
    })

    --启动时初始化一次
    in_insert = vim.fn.mode() == "i"
    set_relative_number(not in_insert)
end

return M
