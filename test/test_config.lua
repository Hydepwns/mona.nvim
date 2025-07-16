-- Configuration validation tests for mona.nvim
-- Mock Neovim API for testing
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
  }
}

local function test_config_validation()
  print("Testing configuration validation...")
  
  local config = require("mona.config")
  
  -- Test valid configuration
  local success, err = pcall(config.setup, {
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
        }
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
      }
    },
    terminal_config = {
      auto_generate = false,
      terminals = { "alacritty", "kitty" }
    },
    preview = {
      sample_text = "Test text",
      window_opts = {
        width = 80,
        height = 20,
        border = "rounded"
      }
    }
  })
  
  assert(success, "Valid configuration should not error: " .. tostring(err))
  print("✓ Valid configuration accepted")
  
  -- Test invalid boolean
  success, err = pcall(config.setup, {
    font_features = { texture_healing = "invalid" }
  })
  assert(not success, "Invalid boolean should error")
  assert(err:match("texture_healing must be boolean"), "Should have specific error message")
  print("✓ Invalid boolean rejected")
  
  -- Test invalid number
  success, err = pcall(config.setup, {
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
        }
      },
      character_variants = { zero_style = 5, one_serif = false, asterisk_height = 0, asterisk_style = 0, comparison_style = 0, force_arrow_style = false, closed_brackets = false, at_underscore = false }
    },
    terminal_config = { auto_generate = false, terminals = { "alacritty", "kitty" } },
    preview = { sample_text = "Test text", window_opts = { width = 80, height = 20, border = "rounded" } }
  })
  assert(not success, "Invalid number should error")
  if not (err and err:match("zero_style must be <=")) then
    print("[DEBUG] Range error message was: ", err)
  end
  assert(err:match("zero_style must be <="), "Should have range error message")
  print("✓ Invalid number rejected")
  
  -- Test invalid table
  success, err = pcall(config.setup, {
    font_features = "not a table"
  })
  assert(not success, "Invalid table should error")
  assert(err:match("font_features must be a table"), "Should have table error message")
  print("✓ Invalid table rejected")
  
  print("Configuration validation tests passed!")
end

-- Test utils module
local function test_utils()
  print("Testing utils module...")
  
  local utils = require("mona.utils")
  
  -- Test notification functions
  assert(utils.notify, "notify function should exist")
  assert(utils.error, "error function should exist")
  assert(utils.warn, "warn function should exist")
  assert(utils.info, "info function should exist")
  
  -- Test validation functions
  assert(utils.validate_boolean, "validate_boolean function should exist")
  assert(utils.validate_number, "validate_number function should exist")
  assert(utils.validate_string, "validate_string function should exist")
  assert(utils.validate_table, "validate_table function should exist")
  assert(utils.validate_enum, "validate_enum function should exist")
  
  -- Test utility functions
  assert(utils.get_os, "get_os function should exist")
  assert(utils.is_gui, "is_gui function should exist")
  assert(utils.format_font_family, "format_font_family function should exist")
  
  -- Test format_font_family
  assert(utils.format_font_family("neon") == "Neon", "Should capitalize first letter")
  assert(utils.format_font_family("argon") == "Argon", "Should capitalize first letter")
  
  print("✓ Utils module tests passed!")
end

-- Test error handling consistency
local function test_error_handling()
  print("Testing error handling consistency...")
  
  local utils = require("mona.utils")
  
  -- Test error function includes plugin prefix
  local success, err = pcall(utils.error, "Test error")
  assert(not success, "error function should throw")
  assert(err:match("%[mona%.nvim%]"), "Error should include plugin prefix")
  
  print("✓ Error handling consistency tests passed!")
end

-- Add current directory to package path for testing
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Run all tests
print("Running mona.nvim configuration tests...")
print("=" .. string.rep("=", 50))

test_utils()
test_error_handling()
test_config_validation()

print("=" .. string.rep("=", 50))
print("All configuration tests passed!") 