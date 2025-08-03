local M = {}
local utils = require("mona.utils")

-- Cache configuration
M.config = {
  cache_file = nil, -- Will be set in M.get_cache_file()
  default_ttl = 300 -- 5 minutes default TTL
}

-- Get cache file path
M.get_cache_file = function()
  if not M.config.cache_file then
    if vim and vim.fn and vim.fn.stdpath then
      M.config.cache_file = vim.fn.stdpath("cache") .. "/mona_nvim_cache.json"
    else
      -- Fallback for testing
      local home = (vim and vim.env and vim.env.HOME) or 
                   (vim and vim.env and vim.env.USERPROFILE) or 
                   os.getenv and os.getenv("HOME") or 
                   os.getenv and os.getenv("USERPROFILE") or 
                   "/tmp"
      M.config.cache_file = home .. "/.mona_nvim_cache.json"
    end
  end
  return M.config.cache_file
end

-- In-memory cache
local cache = {}
local cache_loaded = false

-- Load cache from disk
M.load = function()
  if cache_loaded then
    return
  end
  
  local cache_file = M.get_cache_file()
  if vim.fn and vim.fn.filereadable and vim.fn.filereadable(cache_file) == 1 then
    local ok, content = pcall(vim.fn.readfile, cache_file)
    if ok and #content > 0 and vim.fn and vim.fn.json_decode then
      local cache_ok, loaded_cache = pcall(vim.fn.json_decode, table.concat(content))
      if cache_ok then
        cache = loaded_cache
        cache_loaded = true
      end
    end
  end
  
  cache_loaded = true
end

-- Save cache to disk
M.save = function()
  local cache_file = M.get_cache_file()
  if vim.fn and vim.fn.fnamemodify then
    local cache_dir = vim.fn.fnamemodify(cache_file, ":h")
    utils.safe_mkdir(cache_dir, false)
  end
  
  if vim.fn and vim.fn.json_encode then
    local ok, json = pcall(vim.fn.json_encode, cache)
    if ok then
      utils.safe_write_file(cache_file, json, false)
    end
  end
end

-- Get value from cache
M.get = function(key)
  M.load()
  
  local entry = cache[key]
  if not entry then
    return nil
  end
  
  -- Check expiration
  if entry.expires and entry.expires < os.time() then
    cache[key] = nil
    return nil
  end
  
  return entry.value
end

-- Set value in cache
M.set = function(key, value, ttl)
  M.load()
  
  cache[key] = {
    value = value,
    expires = ttl and (os.time() + ttl) or nil,
    created = os.time()
  }
  
  M.save()
end

-- Remove value from cache
M.delete = function(key)
  M.load()
  
  cache[key] = nil
  M.save()
end

-- Clear expired entries
M.clean = function()
  M.load()
  
  local now = os.time()
  local cleaned = false
  
  for key, entry in pairs(cache) do
    if entry.expires and entry.expires < now then
      cache[key] = nil
      cleaned = true
    end
  end
  
  if cleaned then
    M.save()
  end
end

-- Clear all cache
M.clear = function()
  cache = {}
  M.save()
end

-- Get cache statistics
M.stats = function()
  M.load()
  
  local total = 0
  local expired = 0
  local now = os.time()
  
  for _, entry in pairs(cache) do
    total = total + 1
    if entry.expires and entry.expires < now then
      expired = expired + 1
    end
  end
  
  local file_size = 0
  if vim.fn and vim.fn.getfsize then
    file_size = vim.fn.getfsize(M.get_cache_file())
  end
  
  return {
    total = total,
    expired = expired,
    active = total - expired,
    file_size = file_size
  }
end

-- Cache key generators
M.keys = {
  -- Font installation status
  font_installed = function(family, font_type)
    return string.format("font:installed:%s:%s", family or "all", font_type or "default")
  end,
  
  -- Font version
  font_version = function()
    return "font:version:latest"
  end,
  
  -- Terminal detection
  terminal_type = function()
    return "terminal:detected"
  end,
  
  -- Font file paths
  font_files = function(family)
    return string.format("font:files:%s", family)
  end
}

return M