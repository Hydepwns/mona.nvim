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

-- Consistent error function with plugin prefix (throws error - stops execution)
M.error = function(message)
  error(string.format("[mona.nvim] %s", message))
end

-- Non-throwing error notification (continues execution)
M.notify_error = function(message)
  M.notify(string.format("[mona.nvim] %s", message), vim.log.levels.ERROR)
end

-- Consistent warning function
M.warn = function(message)
  M.notify(string.format("[mona.nvim] %s", message), vim.log.levels.WARN)
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
  M.error(
    string.format(
      "%s must be one of {%s}, got %s",
      name,
      table.concat(allowed_values, ", "),
      tostring(value)
    )
  )
end

-- Safe file operations
M.safe_write_file = function(filepath, content, critical)
  critical = critical ~= false -- default to critical
  local success, err = pcall(function()
    vim.fn.writefile(vim.split(content, "\n"), vim.fn.expand(filepath))
  end)

  if not success then
    local msg = string.format("Failed to write file %s: %s", filepath, err)
    if critical then
      M.error(msg)
    else
      M.notify_error(msg)
    end
  end

  return success
end

-- Safe directory creation
M.safe_mkdir = function(dirpath, critical)
  critical = critical ~= false -- default to critical
  local success, err = pcall(function()
    vim.fn.mkdir(dirpath, "p")
  end)

  if not success then
    local msg = string.format("Failed to create directory %s: %s", dirpath, err)
    if critical then
      M.error(msg)
    else
      M.notify_error(msg)
    end
  end

  return success
end

-- Safe file deletion
M.safe_delete = function(filepath, critical)
  critical = critical == true -- default to non-critical for deletions
  local success, err = pcall(function()
    vim.fn.delete(filepath, "rf")
  end)

  if not success then
    local msg = string.format("Failed to delete %s: %s", filepath, err)
    if critical then
      M.error(msg)
    else
      M.warn(msg)
    end
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

-- Retry logic wrapper
M.with_retry = function(fn, opts)
  opts = vim.tbl_deep_extend("force", {
    max_attempts = 3,
    delay = 1000, -- milliseconds
    backoff = 1.5, -- exponential backoff multiplier
    on_retry = nil, -- callback function(attempt, error)
    should_retry = nil, -- function(error) returning boolean
  }, opts or {})

  local attempt = 1
  local delay = opts.delay

  while attempt <= opts.max_attempts do
    local ok, result = pcall(fn)

    if ok then
      return result
    end

    -- Check if we should retry this error
    if opts.should_retry and not opts.should_retry(result) then
      M.error(result)
    end

    if attempt < opts.max_attempts then
      if opts.on_retry then
        opts.on_retry(attempt, result)
      else
        M.warn(
          string.format(
            "Attempt %d/%d failed: %s. Retrying in %dms...",
            attempt,
            opts.max_attempts,
            tostring(result),
            delay
          )
        )
      end

      -- Wait before retry
      vim.wait(delay)

      -- Apply backoff
      delay = math.floor(delay * opts.backoff)
    else
      -- Final attempt failed
      M.error(
        string.format("Operation failed after %d attempts: %s", opts.max_attempts, tostring(result))
      )
    end

    attempt = attempt + 1
  end
end

-- Async retry logic wrapper
M.with_retry_async = function(fn, opts, callback)
  opts = vim.tbl_deep_extend("force", {
    max_attempts = 3,
    delay = 1000,
    backoff = 1.5,
    on_retry = nil,
    should_retry = nil,
  }, opts or {})

  local attempt = 1
  local delay = opts.delay

  local function try_once()
    fn(function(success, result)
      if success then
        if callback then
          callback(true, result)
        end
        return
      end

      -- Check if we should retry this error
      if opts.should_retry and not opts.should_retry(result) then
        if callback then
          callback(false, result)
        end
        return
      end

      if attempt < opts.max_attempts then
        if opts.on_retry then
          opts.on_retry(attempt, result)
        else
          M.warn(
            string.format(
              "Attempt %d/%d failed: %s. Retrying in %dms...",
              attempt,
              opts.max_attempts,
              tostring(result),
              delay
            )
          )
        end

        -- Schedule retry
        vim.defer_fn(function()
          attempt = attempt + 1
          delay = math.floor(delay * opts.backoff)
          try_once()
        end, delay)
      else
        -- Final attempt failed
        local error_msg = string.format(
          "Operation failed after %d attempts: %s",
          opts.max_attempts,
          tostring(result)
        )
        M.notify_error(error_msg)
        if callback then
          callback(false, error_msg)
        end
      end
    end)
  end

  try_once()
end

return M
