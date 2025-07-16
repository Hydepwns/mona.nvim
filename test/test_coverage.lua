#!/usr/bin/env lua

-- Simple coverage test for mona.nvim
-- This script loads all modules and exercises basic functionality

-- Set up package path
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Mock Neovim API
vim = {
  tbl_deep_extend = function(mode, ...)
    local result = {}
    for i = 1, select('#', ...) do
      local t = select(i, ...)
      if type(t) == "table" then
        for k, v in pairs(t) do
          if mode == "force" or result[k] == nil then
            result[k] = v
          end
        end
      end
    end
    return result
  end,
  log = {
    levels = {
      INFO = 1,
      WARN = 2,
      ERROR = 3
    }
  },
  notify = function(msg, level)
    print(string.format("[%s] %s", level == 1 and "INFO" or level == 2 and "WARN" or "ERROR", msg))
  end,
  fn = {
    has = function(feature)
      return feature == "gui_running" and 0 or 0
    end
  },
  loop = {
    os_uname = function()
      return { sysname = "Linux" }
    end
  },
  o = {
    guifont = "MonaspaceNeon:h12"
  },
  cmd = function(cmd)
    print("[vim.cmd] " .. cmd)
  end,
  opt = {
    runtimepath = {
      append = function(path)
        print("[runtimepath] append: " .. path)
      end
    }
  }
}

print("Loading mona.nvim modules for coverage...")

-- Load and exercise all modules
local modules = {
  "mona.config",
  "mona.utils", 
  "mona.highlights",
  "mona.preview",
  "mona.health",
  "mona.terminal",
  "mona.installer",
  "mona.init"
}

for _, module_name in ipairs(modules) do
  print("Loading " .. module_name .. "...")
  local module = require(module_name)
  print("✓ " .. module_name .. " loaded successfully")
  
  -- Exercise basic functionality if available
  if module.setup then
    print("  - Testing setup function...")
    local success, err = pcall(module.setup, {})
    if success then
      print("  ✓ setup function executed")
    else
      print("  ⚠ setup function failed: " .. tostring(err))
    end
  end
  
  if module.load then
    print("  - Testing load function...")
    local success, err = pcall(module.load)
    if success then
      print("  ✓ load function executed")
    else
      print("  ⚠ load function failed: " .. tostring(err))
    end
  end
end

print("Coverage test completed!") 