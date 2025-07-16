local M = {}

-- Fallback for vim.split in non-Neovim environments
if not vim or not vim.split then
  vim = vim or {}
  vim.split = function(str, sep, plain)
    local result = {}
    local pattern = string.format("([^%s]+)", sep or "%s")
    for match in str:gmatch(pattern) do
      table.insert(result, match)
    end
    return result
  end
end

-- Fallback for vim.fn.expand in non-Neovim environments
if not vim or not vim.fn or not vim.fn.expand then
  vim = vim or {}
  vim.fn = vim.fn or {}
  vim.fn.expand = function(path)
    return path
  end
end

-- Consistent notification function
M.notify = function(message, level)
  level = level or vim.log.levels.INFO
  vim.notify(message, level)
end

-- Consistent error function with plugin prefix
M.error = function(message)
  error(string.format("[mona.nvim] %s", message))
end

-- Consistent warning function
M.warn = function(message)
  M.notify(message, vim.log.levels.WARN)
end

-- Consistent info function
M.info = function(message)
  M.notify(message, vim.log.levels.INFO)
end

-- Validate table structure
M.validate_table = function(value, name, required_keys)
  if type(value) ~= "table" then
    M.error(string.format("%s must be a table, got %s", name, type(value)))
  end
  
  if required_keys then
    for _, key in ipairs(required_keys) do
      if value[key] == nil then
        M.error(string.format("%s must contain key '%s'", name, key))
      end
    end
  end
end

-- Validate boolean value
M.validate_boolean = function(value, name)
  if type(value) ~= "boolean" then
    M.error(string.format("%s must be boolean, got %s", name, type(value)))
  end
end

-- Validate string value
M.validate_string = function(value, name)
  if type(value) ~= "string" then
    M.error(string.format("%s must be string, got %s", name, type(value)))
  end
end

-- Validate number value
M.validate_number = function(value, name, min, max)
  if type(value) ~= "number" then
    M.error(string.format("%s must be number, got %s", name, type(value)))
  end
  
  if min and value < min then
    M.error(string.format("%s must be >= %d, got %d", name, min, value))
  end
  
  if max and value > max then
    M.error(string.format("%s must be <= %d, got %d", name, max, value))
  end
end

-- Validate one of allowed values
M.validate_enum = function(value, name, allowed_values)
  for _, allowed in ipairs(allowed_values) do
    if value == allowed then
      return
    end
  end
  M.error(string.format("%s must be one of {%s}, got %s", 
    name, table.concat(allowed_values, ", "), tostring(value)))
end

-- Safe file operations
M.safe_write_file = function(filepath, content)
  local success, err = pcall(function()
    vim.fn.writefile(vim.split(content, "\n"), vim.fn.expand(filepath))
  end)
  
  if not success then
    M.error(string.format("Failed to write file %s: %s", filepath, err))
  end
  
  return success
end

-- Safe directory creation
M.safe_mkdir = function(dirpath)
  local success, err = pcall(function()
    vim.fn.mkdir(dirpath, "p")
  end)
  
  if not success then
    M.error(string.format("Failed to create directory %s: %s", dirpath, err))
  end
  
  return success
end

-- Safe file deletion
M.safe_delete = function(filepath)
  local success, err = pcall(function()
    vim.fn.delete(filepath, "rf")
  end)
  
  if not success then
    M.warn(string.format("Failed to delete %s: %s", filepath, err))
  end
  
  return success
end

-- Get OS name consistently
M.get_os = function()
  return vim.loop.os_uname().sysname
end

-- Check if running in GUI
M.is_gui = function()
  return vim.fn.has("gui_running") == 1
end

-- Format font family name (capitalize first letter)
M.format_font_family = function(family)
  return family:gsub("^%l", string.upper)
end

return M 