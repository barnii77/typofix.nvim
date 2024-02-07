-- TypoFix object for setup (lazy)

local typofix = {}

--- Utility function to check if path to typo fix storage is valid
--- If file does not exist, it will be created
---@param path string
---@return boolean
local function check_path_is_valid_and_create_file_if_not_exists(path)
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

--- Utility function to trim whitespaces from a string
---@param s any
---@return unknown
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

--- Utility function to check if a string starts with another string
---@param str any
---@param start any
---@return boolean
local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local function abbreviation_exists(abbrev)
  -- Use the :abbreviate command with the abbreviation to check
  local output = trim(vim.fn.execute('iabbrev ' .. abbrev))
  -- Check if the output contains the abbreviation
  -- The output will be more than one line if the abbreviation exists
  if output == '' then
    return false
  elseif output:sub(1, 1) ~= 'i' then
    return false
  else
    return true
  end
end

--- Setup called by Lazy / Packer / etc.
---@param opts table
function typofix.setup(opts)
  if opts == nil then
    opts = {}
  end
  typofix.opts = vim.tbl_extend("force", {
    -- get home env variable
    path = "$HOME/.config/nvim/typofix.vim",
    features = {
      create = true,
      delete = true,
      list = true,
      print_opts = true,
      enable = true,
      disable = true,
    },
    enable_on_startup = true,
  }, opts)
  typofix.opts.path = vim.fn.expand(typofix.opts.path .. ":p"):sub(1, -3)

  if not check_path_is_valid_and_create_file_if_not_exists(typofix.opts.path) then
    vim.notify("Error in TypoFix plugin setup: Path to typofix storage file is invalid; Path: " .. typofix.opts.path,
      vim.log.levels.ERROR)
  else
    -- read file
    if typofix.opts.enable_on_startup then
      vim.cmd("source " .. typofix.opts.path)
    end
    if typofix.opts.features.create then
      vim.api.nvim_create_user_command('TypoFixCreate', CreateTypo, { nargs = 0 })
    end
    if typofix.opts.features.delete then
      vim.api.nvim_create_user_command('TypoFixDelete', DeleteTypo, { nargs = 0 })
    end
    if typofix.opts.features.list then
      vim.api.nvim_create_user_command('TypoFixList', TypoFixList, { nargs = 0 })
    end
    if typofix.opts.features.print_opts then
      vim.api.nvim_create_user_command('TypoFixPrintOpts', function() vim.notify(typofix.opts.path) end, { nargs = 0 })
    end
    if typofix.opts.features.enable then
      vim.api.nvim_create_user_command('TypoFixEnable', typofix.enable, { nargs = 0 })
    end
    if typofix.opts.features.disable then
      vim.api.nvim_create_user_command('TypoFixDisable', typofix.disable, { nargs = 0 })
    end
  end
end

function typofix.enable()
  vim.cmd("source " .. typofix.opts.path)
end

function typofix.disable()
  local file = io.open(typofix.opts.path, "r")
  if file == nil then
    vim.notify("Could not read file: " .. typofix.opts.path, vim.log.levels.WARN)
    return
  end
  local cmd = ""
  for line in file:lines() do
    if starts_with(line, ":iabbrev ") then
      line = trim(line:sub(10))
      -- NOTE: ^(%S+) matches all non-whitespace characters at the start of a string (= first word)
      local incorrect = line:match("^(%S+)")
      if abbreviation_exists(incorrect) then
        cmd = cmd .. "iunabbrev " .. incorrect .. "\n"
      end
    end
  end
  vim.cmd(cmd)
end

-- functionality

function TypoFixList()
  local file = io.open(typofix.opts.path, "r")
  if file == nil then
    vim.notify("Could not read file: " .. typofix.opts.path, vim.log.levels.WARN)
    return
  end
  local lines = {}
  for line in file:lines() do
    if starts_with(line, ":iabbrev ") then
      line = line:sub(10)
      table.insert(lines, line)
    end
  end
  file:close()
  local joined = table.concat(lines, "\n")
  vim.notify(joined)
end

--- Unregisters a typo in the typo storage file
---@param incorrect string
local function unregister_typo_in_file(incorrect)
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

--- Saves a typo to the typo storage file
---@param incorrect string
---@param correct string
local function save_typo(incorrect, correct)
  local file = io.open(typofix.opts.path, "a")
  if file == nil then
    vim.notify("Could not open file: " .. typofix.opts.path, vim.log.levels.WARN)
    return
  end
  file:write(":iabbrev " .. incorrect .. " " .. correct .. "\n")
  file:close()
end

--- Registers a typo
---@param incorrect string
---@param correct string
---@param forced boolean
local function register_typo(incorrect, correct, forced)
  if incorrect == nil or correct == nil then return end
  local abbrev_exists = abbreviation_exists(incorrect)
  if abbrev_exists and not forced then
    vim.notify("Typo already registered: " .. incorrect)
    vim.ui.input({ prompt = "Overwrite [y/n]: " },
      function(confirmation) if confirmation == "y" then register_typo(incorrect, correct, true) end end)
    return
  elseif abbrev_exists then
    -- if overwrite, remove the old one from file so there are no duplicates
    unregister_typo_in_file(incorrect)
  end
  vim.cmd("iabbrev " .. incorrect .. " " .. correct)
  save_typo(incorrect, correct)
  vim.notify("Created TypoFix for " .. incorrect .. " (" .. correct .. ")")
end

--- Unregisters a typo
---@param incorrect string
local function unregister_typo(incorrect)
  if incorrect == nil then return end
  if abbreviation_exists(incorrect) then
    vim.cmd("iunabbrev " .. incorrect)
    unregister_typo_in_file(incorrect)
    vim.notify("Deleted TypoFix for " .. incorrect)
  else
    vim.notify("Typo not found: " .. incorrect)
  end
end

--- Reads the correct form of a typo (called by CreateTypo)
---@param incorrect string
local function read_typo_correct(incorrect)
  if incorrect == nil then return end
  vim.ui.input({ prompt = "Correct: " }, function(correct) register_typo(incorrect, correct, false) end)
end

--- Creates a typo
function CreateTypo()
  vim.ui.input({ prompt = "Incorrect: " }, read_typo_correct)
end

--- Deletes a typo
function DeleteTypo()
  vim.ui.input({ prompt = "Incorrect: " }, unregister_typo)
end

return typofix
