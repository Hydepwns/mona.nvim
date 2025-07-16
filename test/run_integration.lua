-- Integration test runner for mona.nvim
-- This script sets up the environment and runs the integration test

-- Mock LuaJIT global for plenary.nvim compatibility
jit = {
  version = "LuaJIT 2.1.0-beta3",
  os = "Linux"
}
_VERSION = "Lua 5.1"

-- Add current directory to package path
package.path = package.path .. ";lua/?.lua;lua/?/init.lua;test/plenary.nvim/lua/?.lua;test/plenary.nvim/lua/?/init.lua"

-- Preload ffi module for non-LuaJIT environments
package.preload["ffi"] = function()
  return {
    C = {},
    cdef = function() end,
    new = function() return {} end,
    cast = function(ctype, ptr) return ptr end,
    string = function(ptr) return "" end,
    sizeof = function() return 0 end,
    offsetof = function() return 0 end,
    alignof = function() return 0 end,
    typeof = function() return {} end,
    metatype = function(ctype, metatable) return ctype end,
    load = function() return {} end,
    abi = function() return {} end,
    os = "Linux",
    arch = "x64"
  }
end

-- Mock Neovim API for testing
vim = {
  cmd = function(cmd)
    print("VIM CMD:", cmd)
  end,
  fn = {
    exists = function(cmd)
      return 2  -- Command exists
    end,
    has = function(feature)
      return 0  -- Return 0 (false) for any feature check
    end,
    getenv = function(var)
      return vim.NIL  -- Return vim.NIL for any environment variable
    end,
    fnamemodify = function(filename, modifier)
      return filename  -- Return filename as-is for simplicity
    end
  },
  api = {
    nvim_buf_set_lines = function() end,
    nvim_list_uis = function()
      return {}  -- Return empty list to indicate headless mode
    end,
    nvim_call_function = function(func_name, args)
      if func_name == "stdpath" then
        return "/tmp"  -- Return a default path for stdpath
      end
      return nil
    end
  },
  o = {
    runtimepath = {
      append = function() end
    }
  },
  loop = {
    os_homedir = function()
      return os.getenv("HOME") or "~"
    end,
    os_uname = function()
      return { sysname = "Linux" }
    end
  },
  NIL = {},  -- Mock vim.NIL
  tbl_deep_extend = function(mode, target, ...)
    local sources = {...}
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
    end
  }
}

-- Load plenary.busted
local busted = require("plenary.busted")

-- Run the integration test
print("Running mona.nvim integration tests...")
print("=" .. string.rep("=", 50))

busted.run("test/plugin/integration_spec.lua") 