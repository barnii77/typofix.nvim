-- TypoFix object for setup (lazy)

local typofix = {}

--- Utility function to check if path to typo fix storage is valid
--- If file does not exist, it will be created
---@param path string
---@return boolean
function CheckPathIsValidAndCreateFileIfNotExists(path)
  -- check length of extension
  local len = path:len()
  if len < 4 then
    return false
  end
  -- check extension
  local extension = path:sub(len - 3, len)
  if extension ~= ".vim" then
    return false
  end
  -- check if path exists
  if not vim.fn.isdirectory(vim.fn.fnamemodify(path, ":h")) then
    return false
  end
  local kind = vim.fn.filewritable(path)
  if kind == 2 then
    return false
  end
  -- otherwise, kind is 0 or 1, meaning it's writable and exists or not
  if kind == 0 then
    -- create if doesnt exist
    local file = io.open(path, "w")
    if file == nil then
      -- return false if not writable
      return false
    end
    file:write("")
    file:close()
  end
  return true
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

--- Setup called by Lazy / Packer / etc.
---@param opts table
function typofix.setup(opts)
  if opts == nil then
    opts = {}
  end
  typofix.opts = vim.tbl_extend("force", {}, {
    -- get home env variable
    path = "$HOME/.config/nvim/.typofix/iabbrevs.vim",
  }, opts)
  typofix.opts.path = vim.fn.expand(typofix.opts.path .. ":p"):sub(1, -3)

  if not CheckPathIsValidAndCreateFileIfNotExists(typofix.opts.path) then
    vim.notify("Error in TypoFix plugin setup: Path to typofix storage file is invalid; Path: " .. typofix.opts.path,
      vim.log.levels.ERROR)
  else
    -- read file
    vim.cmd("source " .. typofix.opts.path)
    vim.api.nvim_create_user_command('TypoFixCreate', CreateTypo, { nargs = 0 })
    vim.api.nvim_create_user_command('TypoFixDelete', DeleteTypo, { nargs = 0 })
    vim.api.nvim_create_user_command('TypoFixPrintOpts', function() vim.notify(typofix.opts.path) end, { nargs = 0 })
  end
end

-- functionality

function AbbreviationExists(abbrev)
  -- Use the :abbreviate command with the abbreviation to check
  local output = vim.fn.execute('iabbrev ' .. abbrev)
  -- Check if the output contains the abbreviation
  -- The output will be more than one line if the abbreviation exists
  if output == '' then
    return false
  elseif output[1] ~= 'i' then
    return false
  else
    return true
  end
end

--- Registers a typo
---@param incorrect string
---@param correct string
---@param forced boolean
function RegisterTypo(incorrect, correct, forced)
  if AbbreviationExists(incorrect) and not forced then
    vim.notify("Typo already registered: " .. incorrect)
    vim.ui.input({ prompt = "Overwrite [y/n]: " },
      function(confirmation) if confirmation == "y" then RegisterTypo(incorrrect, correct, true) end end)
  else
    vim.cmd("iabbrev " .. incorrect .. " " .. correct)
    SaveTypo(incorrect, correct)
    vim.notify("Created TypoFix for " .. incorrect .. " (" .. correct .. ")")
  end
end

--- Unregisters a typo in the typo storage file
---@param incorrect string
function UnregisterTypoInFile(incorrect)
  local file = io.open(typofix.opts.path, "r")
  if file == nil then
    vim.notify("Could not read file: " .. typofix.opts.path, vim.log.levels.WARN)
    return
  end
  local lines = {}
  for line in file:lines() do
    if not starts_with(line, ":iabbrev " .. incorrect) then
      table.insert(lines, line)
    end
  end
  file:close()
  file = io.open(typofix.opts.path, "w")
  if file == nil then
    vim.notify("Could not modify file: " .. typofix.opts.path, vim.log.levels.WARN)
    return
  end
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()
end

--- Unregisters a typo
---@param incorrect string
function UnregisterTypo(incorrect)
  if AbbreviationExists(incorrect) then
    vim.cmd("iunabbrev " .. incorrect)
    UnregisterTypoInFile(incorrect)
    vim.notify("Deleted TypoFix for " .. incorrect)
  else
    vim.notify("Typo not found: " .. incorrect)
  end
end

--- Reads the correct form of a typo (called by CreateTypo)
---@param incorrect string
function ReadTypoCorrect(incorrrect)
  vim.ui.input({ prompt = "Correct: " }, function(correct) RegisterTypo(incorrrect, correct, false) end)
end

--- Creates a typo
function CreateTypo()
  vim.ui.input({ prompt = "Incorrect: " }, ReadTypoCorrect)
end

--- Deletes a typo
function DeleteTypo()
  vim.ui.input({ prompt = "Incorrect: " }, UnregisterTypo)
end

--- Saves a typo to the typo storage file
---@param incorrect string
---@param correct string
function SaveTypo(incorrect, correct)
  local file = io.open(typofix.opts.path, "a")
  if file == nil then
    vim.notify("Could not open file: " .. typofix.opts.path, vim.log.levels.WARN)
    return
  end
  file:write(":iabbrev " .. incorrect .. " " .. correct .. "\n")
  file:close()
end

return typofix
