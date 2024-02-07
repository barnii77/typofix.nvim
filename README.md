# Overview
![typofix](docs/typo-ide-fix.png)

## What TypoFix is **not**
TypoFix is not a plugin that checks your spelling and it does not auto-correct all your text/code/comments when you add a typo.

## What TypoFix is
TypoFix is a Neovim plugin that makes it quick and easy to manage insert abbreviations (see `:help iabbrev`).
You can simply install it using your favorite package manager, select what user commands you want to have and you're good to go!

# Installation
To install using Lazy, just add this to your list of plugins:
```lua
{
  {
    "barnii77/typofix.nvim",
    opts = {
      path = "path/to/abbreviations/file.vim",
      features = {
        create = true,
        delete = true,
        list = true,
        enable = true,
        disable = true,
        print_opts = false,
      },
    }
  }
}
```

# Configuration

## Options
| option | default | description |
|--------|---------|-------------|
| path   | "$HOME/.config/nvim/typofix.vim" | The path where the vim file containing the iabbrevs |
| features.create | true | whether to add the TypoFixCreate command as a user command on startup |
| features.delete | true | whether to add the TypoFixDelete command as a user command on startup |
| features.list | true | whether to add the TypoFixList command as a user command on startup |
| features.enable | true | whether to add the TypoFixEnable command as a user command on startup |
| features.disable | true | whether to add the TypoFixDisable command as a user command on startup |
| features.print_opts | true | whether to add the TypoFixPrintOpts command as a user command on startup |

## Features
| command | description |
|---------|-------------|
| TypoFixCreate | Create a new typo fix and write it to file |
| TypoFixDelete | Delete a typo fix and remove it from file |
| TypoFixList | List all typo fixes in file |
| TypoFixEnable | Enable fixing of typos |
| TypoFixDisable | Disables fixing of typos |
| TypoFixPrintOpts | Prints the path where your typo file is stored |
