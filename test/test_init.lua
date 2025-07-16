-- Init module tests for mona.nvim
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
  end
}

-- Add current directory to package path for testing
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Mock all dependent modules
package.loaded["mona.config"] = {
  setup = function(opts)
    -- Mock implementation
  end
}

package.loaded["mona.installer"] = {
  install = function(opts)
    -- Mock implementation
  end,
  update = function()
    -- Mock implementation
  end,
  uninstall = function(families)
    -- Mock implementation
  end,
  check_installation = function()
    return {
      neon = true,
      argon = false,
      xenon = true,
      radon = false,
      krypton = true
    }
  end
}

package.loaded["mona.terminal"] = {
  generate = function(terminal, font_map)
    return "Generated config for " .. terminal
  end,
  export = function(terminal, filepath)
    if filepath then
      return true
    else
      return "Generated config for " .. terminal
    end
  end
}

package.loaded["mona.preview"] = {
  show = function()
    -- Mock implementation
  end
}

package.loaded["mona.health"] = {
  check = function()
    -- Mock implementation
  end
}

local function test_init_module()
  print("Testing init module...")
  
  local mona = require("mona")
  
  -- Test module structure
  assert(type(mona.setup) == "function", "setup function should exist")
  assert(type(mona.install) == "function", "install function should exist")
  assert(type(mona.update) == "function", "update function should exist")
  assert(type(mona.uninstall) == "function", "uninstall function should exist")
  assert(type(mona.check_installation) == "function", "check_installation function should exist")
  assert(type(mona.generate_config) == "function", "generate_config function should exist")
  assert(type(mona.export_config) == "function", "export_config function should exist")
  assert(type(mona.preview) == "function", "preview function should exist")
  assert(type(mona.health_check) == "function", "health_check function should exist")
  
  print("✓ Init module structure tests passed!")
end

local function test_init_setup()
  print("Testing init setup functionality...")
  
  local mona = require("mona")
  
  -- Test setup with valid options
  local success, err = pcall(function()
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
  end)
  assert(success, "setup should not error: " .. tostring(err))
  
  -- Test setup with nil options
  success, err = pcall(function()
    mona.setup()
  end)
  assert(success, "setup with nil options should not error: " .. tostring(err))
  
  print("✓ Init setup functionality tests passed!")
end

local function test_init_install()
  print("Testing init install functionality...")
  
  local mona = require("mona")
  
  -- Test install with default options
  local success, err = pcall(mona.install)
  assert(success, "install should not error: " .. tostring(err))
  
  -- Test install with custom options
  success, err = pcall(function()
    mona.install({
      font_type = "variable",
      families = { "neon", "argon" },
      force = true
    })
  end)
  assert(success, "install with custom options should not error: " .. tostring(err))
  
  print("✓ Init install functionality tests passed!")
end

local function test_init_update()
  print("Testing init update functionality...")
  
  local mona = require("mona")
  
  -- Test update function
  local success, err = pcall(mona.update)
  assert(success, "update should not error: " .. tostring(err))
  
  print("✓ Init update functionality tests passed!")
end

local function test_init_uninstall()
  print("Testing init uninstall functionality...")
  
  local mona = require("mona")
  
  -- Test uninstall all
  local success, err = pcall(mona.uninstall)
  assert(success, "uninstall should not error: " .. tostring(err))
  
  -- Test uninstall specific families
  success, err = pcall(function()
    mona.uninstall({ "neon", "argon" })
  end)
  assert(success, "uninstall specific families should not error: " .. tostring(err))
  
  print("✓ Init uninstall functionality tests passed!")
end

local function test_init_check_installation()
  print("Testing init check_installation functionality...")
  
  local mona = require("mona")
  
  local status = mona.check_installation()
  
  -- Test return structure
  assert(type(status) == "table", "check_installation should return a table")
  assert(status.neon ~= nil, "should check neon font")
  assert(status.argon ~= nil, "should check argon font")
  assert(status.xenon ~= nil, "should check xenon font")
  assert(status.radon ~= nil, "should check radon font")
  assert(status.krypton ~= nil, "should check krypton font")
  
  -- Test boolean values
  assert(type(status.neon) == "boolean", "neon status should be boolean")
  assert(type(status.argon) == "boolean", "argon status should be boolean")
  assert(type(status.xenon) == "boolean", "xenon status should be boolean")
  
  print("✓ Init check_installation functionality tests passed!")
end

local function test_init_generate_config()
  print("Testing init generate_config functionality...")
  
  local mona = require("mona")
  
  -- Test with default font map
  local config = mona.generate_config("alacritty")
  assert(type(config) == "string", "generate_config should return a string")
  assert(config:match("Generated config for alacritty"), "should generate config for alacritty")
  
  -- Test with custom font map
  local custom_font_map = {
    normal = "Argon",
    bold = "Neon",
    italic = "Xenon",
    bold_italic = "Radon"
  }
  config = mona.generate_config("kitty", custom_font_map)
  assert(type(config) == "string", "generate_config with custom map should return a string")
  assert(config:match("Generated config for kitty"), "should generate config for kitty")
  
  print("✓ Init generate_config functionality tests passed!")
end

local function test_init_export_config()
  print("Testing init export_config functionality...")
  
  local mona = require("mona")
  
  -- Test export without filepath (should return config)
  local config = mona.export_config("alacritty")
  assert(type(config) == "string", "export_config should return config string when no filepath")
  assert(config:match("Generated config for alacritty"), "should return config for alacritty")
  
  -- Test export with filepath (should write file)
  local success, err = pcall(function()
    mona.export_config("kitty", "/tmp/test_kitty.conf")
  end)
  assert(success, "export_config should not error when writing file: " .. tostring(err))
  
  print("✓ Init export_config functionality tests passed!")
end

local function test_init_preview()
  print("Testing init preview functionality...")
  
  local mona = require("mona")
  
  -- Test preview function
  local success, err = pcall(mona.preview)
  assert(success, "preview should not error: " .. tostring(err))
  
  print("✓ Init preview functionality tests passed!")
end

local function test_init_health_check()
  print("Testing init health_check functionality...")
  
  local mona = require("mona")
  
  -- Test health_check function
  local success, err = pcall(mona.health_check)
  assert(success, "health_check should not error: " .. tostring(err))
  
  print("✓ Init health_check functionality tests passed!")
end

-- Run all tests
print("Running mona.nvim init tests...")
print("=" .. string.rep("=", 50))

test_init_module()
test_init_setup()
test_init_install()
test_init_update()
test_init_uninstall()
test_init_check_installation()
test_init_generate_config()
test_init_export_config()
test_init_preview()
test_init_health_check()

print("=" .. string.rep("=", 50))
print("All init tests passed!") 