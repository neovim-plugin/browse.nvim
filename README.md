<div align="center">

# browse.nvim

### Seamless browsing experience in Neovim with customizable search providers

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![License](https://img.shields.io/github/license/neovim-plugin/browse.nvim?color=%23FFC600&style=for-the-badge)](https://github.com/neovim-plugin/browse.nvim/blob/main/LICENSE)

</div>

## Table of Contents
1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Setup](#setup)
5. [Usage](#usage)
   - [Bookmarks](#bookmarks)
   - [Search](#search)
   - [DevDocs](#devdocs)
   - [MDN](#mdn)
6. [Customizations](#customizations)
7. [Command Usage](#command-usage)
8. [Acknowledgements and Credits](#acknowledgements-and-credits)

---

## Features

- 🖥️ **Cross-platform**: Works on Linux, macOS, Windows, and WSL.
- ⌨️ **Efficient Searching**: Reduces search keystrokes for queries on [StackOverflow](https://stackoverflow.com), [DevDocs](https://devdocs.io), and [MDN](https://developer.mozilla.org/en-US/).
- 🔍 **Customizable Providers**: Define your own search providers or use pre-built ones.
- 🔖 **Bookmarks**: Easily open and search your saved bookmarks.

## Requirements

- [Neovim](https://github.com/neovim/neovim) (0.7.0+)
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for interactive picking.
- Command for opening URLs:
  - [xdg-open](https://linux.die.net/man/1/xdg-open) (Linux)
  - [wslview](https://github.com/wslutilities/wslu) (WSL)
  - [open](https://ss64.com/osx/open.html) (macOS)
  - [start](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/start) (Windows)
- [dressing.nvim](https://github.com/stevearc/dressing.nvim) (optional) for better input and selection UIs.

## Installation

- [lazy.nvim](https://github.com/folke/lazy.nvim)

  ```lua
  {
      "neovim-plugin/browse.nvim",
      dependencies = { "nvim-telescope/telescope.nvim" },
  }
  ```

- [packer.nvim](https://github.com/wbthomason/packer.nvim)

  ```lua
  use({
      "neovim-plugin/browse.nvim",
      requires = { "nvim-telescope/telescope.nvim" },
  })
  ```

- [vim-plug](https://github.com/junegunn/vim-plug)

  ```vim
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'neovim-plugin/browse.nvim'
  ```

## Setup

```lua
-- default values for the setup
require('browse').setup({
  bookmarks = {},
  icons = {
    bookmark_alias = "->",
    bookmark_prompt = "",
    grouped_bookmarks = "->",
  },
  persist_grouped_bookmarks_query = false,
  debug = false,
  use_icon = true,
  init = function()
    require("browse.providers.input")
    require("browse.providers.bookmarks")
    require("browse.providers.devdocs")
    require("browse.providers.mdn")
    require("browse.providers.devdocs_file")
  end,
})
```

## Usage

### Bookmarks

You can declare bookmarks in various formats. Below are some examples:

1. Grouped URLs with a name key (recommended):

   ```lua
   local bookmarks = {
     ["github"] = {
         ["name"] = "search github from neovim",
         ["code_search"] = "https://github.com/search?q=%s&type=code",
         ["repo_search"] = "https://github.com/search?q=%s&type=repositories",
         ["issues_search"] = "https://github.com/search?q=%s&type=issues",
         ["pulls_search"] = "https://github.com/search?q=%s&type=pullrequests",
     },
   }
   ```

2. URLs with aliases:

   ```lua
   local bookmarks = {
     ["github_code_search"] = "https://github.com/search?q=%s&type=code",
     ["github_repo_search"] = "https://github.com/search?q=%s&type=repositories",
   }
   ```

3. URLs with a query parameter:

   ```lua
   local bookmarks = {
     "https://github.com/search?q=%s&type=code",
     "https://github.com/search?q=%s&type=repositories",
   }
   ```

4. Simple and direct URLs:

   ```lua
   local bookmarks = {
        "https://github.com/hoob3rt/lualine.nvim",
        "https://github.com/neovim/neovim",
        "https://neovim.discourse.group/",
        "https://github.com/nvim-telescope/telescope.nvim",
        "https://github.com/rockerBOO/awesome-neovim",
    }
   ```

5. Combine all of the above in a single table if desired.

To use bookmarks:

```lua
vim.keymap.set("n", "<leader>b", function()
  require("browse").run_action({ bookmarks = bookmarks })
end)
```

> IF the `bookmarks` table is empty or not passed, selection "Bookmarks" in Telescope will show an
> empty result.

### Search

- Prompt a search: 

```lua
require('browse').run_action('input')
```

- Search with bookmarks:

```lua
require("browse").run_action('bookmarks', { bookmarks = bookmarks })
```

- Open `telescope.nvim` dropdown to select a method:

```lua
require("browse").run_action({ bookmarks = bookmarks })
```

### DevDocs

- Search [DevDocs](https://devdocs.io/):

```lua
require('browse').run_action("devdocs")
```

- Search DevDocs based on the current filetype:

```lua
require('browse').run_action("devdocs_file")
```

### MDN

- Search on [MDN](https://developer.mozilla.org/en-US/)

```lua
require('browse').run_action("mdn")
```

## Customizations

You can register your own provider with:

```lua
require('browse').register(provider)
```

## Command Usage

You can invoke the `Browse` command in Neovim using:

```vim
:Browse [subcommand]
```

- **Subcommand**: The `subcommand` corresponds to a specific provider (e.g., `input`, `mdn`, `devdocs`, `bookmarks`). If you provide a subcommand, `browse.nvim` will use that provider to execute the corresponding action.

- **Empty Subcommand**: If no subcommand is provided, the command will fallback to `Browse.run_action()`, which will prompt you to select a provider or perform a default action.

## Acknowledgements and Credits

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [open-browser.nvim](https://github.com/tyru/open-browser.vim)
- [original browse.nvim](https://github.com/lalitmee/browse.nvim)
