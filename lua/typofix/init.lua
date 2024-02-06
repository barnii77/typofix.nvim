-- TypoFix object for setup (lazy)
---@class TypoFix
---@field opts table
local TypoFix = {
  typofixes = {},
  opts = {},
}
TypoFix.__index = TypoFix

function TypoFix.new()
  print("ran typofix new")
  return setmetatable({
    opts = {
      path = "$HOME/.config/nvim/.typofix/iabbrevs.vim",
      enabled = true,
    }
  }, TypoFix)
end

---@param opts table
function TypoFix:setup(opts)
  print("ran typofix setup")
  opts = vim.tbl_extend("force", {}, {
    path = "$HOME/.config/nvim/.typofix/iabbrevs.vim",
    enabled = true,
  }, opts)
end
--   self.opts = opts
--   vim.api.nvim_create_user_command('TypoFixCreate', CreateTypo(), { nargs = 0 })
--   vim.api.nvim_create_user_command('TypoFixDelete', DeleteTypo(), { nargs = 0 })
-- end


-- functionality

local typofix = TypoFix.new()

---@param incorrect string
---@param correct string
---@param forced boolean
function RegisterTypo(incorrect, correct, forced)
  if typofix.typofixes[incorrect] and not forced then
    print("Typo already registered: " .. incorrect)
    vim.ui.input({ prompt = "Overwrite [y/n]: " }, function(confirmation) RegisterTypo(incorrrect, correct, confirmation == "y") end)
  else
    typofix.typofixes[incorrect] = correct
    vim.cmd("iabbrev " .. incorrect .. correct)
  end
end

---@param incorrect string
function UnregisterTypo(incorrect)
  if typofix.typofixes[incorrect] then
    typofix.typofixes[incorrect] = nil
    vim.cmd("iunabbrev " .. incorrect)
  else
    print("Typo not found: " .. incorrect)
  end
end

---@param incorrect string
function ReadTypoCorrect(incorrrect)
  vim.ui.input({ prompt = "Correct: " }, function(correct) RegisterTypo(incorrrect, correct, false) end)
end

function CreateTypo()
  vim.ui.input({ prompt = "Incorrect: " }, ReadTypoCorrect)
end

function DeleteTypo()
  vim.ui.input({ prompt = "Incorrect: " }, UnregisterTypo)
end

return typofix
