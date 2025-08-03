-- Simple integration test runner for mona.nvim
-- This script tests the plugin functionality directly

print("Running mona.nvim integration tests...")
print("=" .. string.rep("=", 50))

-- Mock Neovim API for testing
vim = {
  cmd = function(cmd)
    print("VIM CMD:", cmd)
  end,
  split = function(str, sep)
    local result = {}
    for match in (str .. sep):gmatch("(.-)" .. sep) do
      table.insert(result, match)
    end
    return result
  end,
  fn = {
    exists = function(cmd)
      return 2 -- Command exists
    end,
    has = function(feature)
      return 0 -- Return 0 (false) for any feature check
    end,
    getenv = function(var)
      return nil -- Return nil for any environment variable
    end,
    fnamemodify = function(filename, modifier)
      return filename -- Return filename as-is for simplicity
    end,
  },
  api = {
    nvim_buf_set_lines = function() end,
    nvim_list_uis = function()
      return {} -- Return empty list to indicate headless mode
    end,
    nvim_call_function = function(func_name, args)
      if func_name == "stdpath" then
        return "/tmp" -- Return a default path for stdpath
      end
      return nil
    end,
    nvim_create_user_command = function(name, callback, opts)
      print("Registered command:", name)
    end,
  },
  o = {
    runtimepath = {
      append = function() end,
    },
  },
  loop = {
    os_homedir = function()
      return os.getenv("HOME") or "~"
    end,
    os_uname = function()
      return { sysname = "Linux" }
    end,
  },
  NIL = {}, -- Mock vim.NIL
  tbl_deep_extend = function(mode, target, ...)
    local sources = { ... }
    for _, source in ipairs(sources) do
      if type(source) == "table" then
        for k, v in pairs(source) do
          if mode == "force" or target[k] == nil then
            target[k] = v
          end
        end
      end
    end
    return target
  end,
  F = {
    if_nil = function(val, default)
      return val ~= nil and val or default
    end,
  },
}

-- Add current directory to package path
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Test 1: Check if mona module can be loaded
print("Test 1: Loading mona module...")
local success, mona = pcall(require, "mona")
if success then
  print("✓ mona module loaded successfully")
else
  print("✗ Failed to load mona module:", mona)
  os.exit(1)
end

-- Test 2: Check if setup function works
print("Test 2: Testing setup function...")
local success, result = pcall(function()
  mona.setup({
    font_features = {
      texture_healing = true,
      ligatures = {
        enable = true,
        stylistic_sets = {
          equals = true,
          comparison = true,
          arrows = true,
          markup = true,
          fsharp = false,
          repeating = true,
          colons = true,
          dots = true,
          comparison_alt = true,
          tags = true,
        },
      },
      character_variants = {
        zero_style = 2,
        one_serif = false,
        asterisk_height = 0,
        asterisk_style = 0,
        comparison_style = 0,
        force_arrow_style = false,
        closed_brackets = false,
        at_underscore = false,
      },
    },
  })
end)
if success then
  print("✓ Setup function works")
else
  print("✗ Setup function failed:", result)
  os.exit(1)
end

-- Test 3: Check if config module can be loaded
print("Test 3: Loading config module...")
local success, config = pcall(require, "mona.config")
if success then
  print("✓ config module loaded successfully")
  print("  - Texture healing:", config.config.font_features.texture_healing)
else
  print("✗ Failed to load config module:", config)
  os.exit(1)
end

-- Test 4: Check if other modules can be loaded
local modules = {
  "mona.utils",
  "mona.installer",
  "mona.terminal",
  "mona.preview",
  "mona.health",
  "mona.highlights",
}
for _, module_name in ipairs(modules) do
  print("Test 4: Loading " .. module_name .. "...")
  local success, module = pcall(require, module_name)
  if success then
    print("✓ " .. module_name .. " loaded successfully")
  else
    print("✗ Failed to load " .. module_name .. ":", module)
    os.exit(1)
  end
end

print("=" .. string.rep("=", 50))
print("✓ All integration tests passed!")
