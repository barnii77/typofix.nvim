---@class TypoFix
---@field opts table
local TypoFix = {
  typofixes = {},
}
TypoFix.__index = TypoFix

local typofix = TypoFix.new()

function RegisterTypo(incorrect, correct, forced)
  if typofix.typofixes[incorrect] and not forced then
    print("Typo already registered: " .. incorrect)
    vim.ui.input({ prompt = "Overwrite [y/n]: " }, function(confirmation) RegisterTypo(incorrrect, correct, confirmation == "y") end)
  else
    typofix.typofixes[incorrect] = correct
    vim.cmd("iabbrev " .. incorrect .. correct)
  end
end

function DeleteTypo(incorrect)
  if typofix.typofixes[incorrect] then
    typofix.typofixes[incorrect] = nil
    vim.cmd("iunabbrev " .. incorrect)
  else
    print("Typo not found: " .. incorrect)
  end
end

function ReadTypoCorrect(incorrrect)
  vim.ui.input({ prompt = "Correct: " }, function(correct) RegisterTypo(incorrrect, correct) end)
end

function TypoCreate()
  vim.ui.input({ prompt = "Incorrect: " }, ReadTypoCorrect)
end

function TypoFix.new()
  return setmetatable({
    opts = {
      path = "$HOME/.config/nvim/.typofix/iabbrevs.vim",
      enabled = true,
    }
  }, TypoFix)
end

---@param opts table
function TypoFix:setup(opts)
  opts = vim.tbl_extend("force", {
    path = "$HOME/.config/nvim/.typofix/iabbrevs.vim",
    enabled = true,
  }, opts)
  self.opts = opts
  vim.api.nvim_create_user_command('TypoFixCreate', TypoCreate(), { nargs = 0 })
end

return typofix
