# smartnumber.nvim

Automatically toggles Neovim line numbers between relative and absolute based on current mode.

## ✨ Features

- Automatically disables relative numbers in **Insert mode**
- Disables relative numbers in **Command-line mode** (`:`, `/`, `?`) instantly
- Restores relative numbers in **Normal mode**
- Handles **window focus** changes inside Neovim and in external multiplexer like **tmux**
- Keeps absolute line numbers in unfocused windows

## 📦 Installation (using [lazy.nvim](https://github.com/folke/lazy.nvim))

```lua
{
    "am2b/smartnumber.nvim",
    event = { 'VeryLazy' },

    config = function()
        require("smartnumber").setup()
    end,
}
```

## 🧠 How It Works

This plugin uses the following Neovim autocommands to detect changes in mode and focus:

- `InsertEnter`, `InsertLeave`: to toggle `relativenumber` in insert mode
- `CmdlineEnter`, `CmdlineLeave`: to handle `:`, `/`, and `?`
- `WinEnter`, `WinLeave`: for window focus changes inside Neovim
- `FocusGained`, `FocusLost`: to detect when Neovim gains or loses terminal focus (e.g. with tmux)
