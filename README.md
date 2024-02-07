# 💥 Overview
![typofix](docs/typo-ide-fix.png)

## What TypoFix is **not**
TypoFix is not a plugin that checks your spelling and it does not auto-correct all your text/code/comments when you add a typo.

## What TypoFix is
TypoFix is a Neovim plugin that makes it quick and easy to manage insert abbreviations (see `:help iabbrev`).
You can simply install it using your favorite package manager, select what user commands you want to have and you're good to go!

# 📦 Installation
To install using Lazy, just add this to your list of plugins:
```lua
-- NOTE: these {} are not required if you use default settings
{
  "barnii77/typofix.nvim"
}
```

Full list of settings (adjust however you like):
```lua
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
```

# ⚙️ Configuration
| option | default | description |
|--------|---------|-------------|
| path   | "$HOME/.config/nvim/typofix.vim" | The path where the vim file containing the iabbrevs is stored |
| features.create | true | whether to add the TypoFixCreate command as a user command on startup |
| features.delete | true | whether to add the TypoFixDelete command as a user command on startup |
| features.list | true | whether to add the TypoFixList command as a user command on startup |
| features.enable | true | whether to add the TypoFixEnable command as a user command on startup |
| features.disable | true | whether to add the TypoFixDisable command as a user command on startup |
| features.print_opts | true | whether to add the TypoFixPrintOpts command as a user command on startup |

# ✨ Features
| command | description |
|---------|-------------|
| TypoFixCreate | Create a new typo fix and write it to file |
| TypoFixDelete | Delete a typo fix and remove it from file |
| TypoFixList | List all typo fixes in file |
| TypoFixEnable | Enable fixing of typos |
| TypoFixDisable | Disables fixing of typos |
| TypoFixPrintOpts | Prints the path where your typo file is stored |

# How it works
Behind the scenes, this plugin uses Vim's iabbreviation feature, which allows you to set abbreviations that, when a space is placed after them, will be expanded to their full form. This can be used for fixing typos because you can just set the incorrect version as the abbreviation for the correct version. So if this feature exists in Vim/Neovim already, where does this plugin fit in?

# Why I made it
If you didn't use this plugin, what would you have to do to create a new abbreviation once you notice you are making a certain typo very often?

The worst way to do it:
1. You have to quit Neovim
2. You have to navigate to your configuration
3. You have to open your configuration file of choice where you want to add all the abbreviations
4. You have to remember what the typo was and type it out in your config
5. You have to quit Neovim again
6. You have to go back to where you were before and re-open all your files

Now, this can be optimized a bit:
1. Open a file in your config folder where you store your abbreviations and type out the entire file path while doing so
2. Source your file, once again typing out the entire file path

What does this look like with TypoFix?
1. You type `:TypoFixCreate` (or just do `<Leader>ufc` like me xD)
2. You take a sip of your green tea and enjoy the fact you didn't have to type out file paths

For deleting, the procedure is similar.

However, once you want to deactivate and activate the typo-fixing, the manual methods start to fall apart. Here's what you need for those:
1. Create an iabbrev.vim file
2. Create an iunabbrev.vim file
3. Keep them synchronized, which increases the work required to use the manual methods drastically.
4. Once in a while, go and fix up the files because you will probably screw up the synchronization

Meanwhile, TypoFix does all that for you, and you don't have to take any extra steps!
TypoFix keeps track of your typos in the Vim file at the path you specified without you having to do anything but use the plugin commands.
