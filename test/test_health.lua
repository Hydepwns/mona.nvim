-- Health module tests for mona.nvim
-- Mock Neovim API for testing
vim = {
  health = {
    start = function(title)
      print("Health check started: " .. title)
    end,
    ok = function(message)
      print("✓ " .. message)
    end,
    warn = function(message)
      print("⚠ " .. message)
    end,
    info = function(message)
      print("ℹ " .. message)
    end
  },
  env = {
    TERM_PROGRAM = "alacritty",
    TERM = "xterm-256color"
  },
  fn = {
    system = function(cmd)
      if cmd:match("which curl") then
        return "/usr/bin/curl"
      elseif cmd:match("which unzip") then
        return "/usr/bin/unzip"
      else
        return ""
      end
    end,
    has = function(feature)
      return feature == "gui_running" and 0 or 0
    end
  },
  v = {
    shell_error = 0
  },
  loop = {
    os_uname = function()
      return { sysname = "Linux" }
    end
  },
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

-- Mock installer module
package.loaded["mona.installer"] = {
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

-- Mock config module
package.loaded["mona.config"] = {
  config = {
    font_features = {
      texture_healing = true,
      ligatures = {
        enable = true
      }
    }
  }
}

local function test_health_module()
  print("Testing health module...")
  
  local health = require("mona.health")
  
  -- Test module structure
  assert(type(health.check) == "function", "check function should exist")
  
  print("✓ Health module structure tests passed!")
end

local function test_health_check()
  print("Testing health check functionality...")
  
  local health = require("mona.health")
  
  -- Test check function
  local success, err = pcall(health.check)
  assert(success, "check function should not error: " .. tostring(err))
  
  print("✓ Health check functionality tests passed!")
end

local function test_health_os_detection()
  print("Testing health OS detection...")
  
  local health = require("mona.health")
  
  -- Test with different OS values
  local original_os_uname = vim.loop.os_uname
  
  -- Test Linux
  vim.loop.os_uname = function()
    return { sysname = "Linux" }
  end
  local success, err = pcall(health.check)
  assert(success, "health check should work on Linux: " .. tostring(err))
  
  -- Test macOS
  vim.loop.os_uname = function()
    return { sysname = "Darwin" }
  end
  success, err = pcall(health.check)
  assert(success, "health check should work on macOS: " .. tostring(err))
  
  -- Test Windows
  vim.loop.os_uname = function()
    return { sysname = "Windows_NT" }
  end
  success, err = pcall(health.check)
  assert(success, "health check should work on Windows: " .. tostring(err))
  
  -- Test unknown OS
  vim.loop.os_uname = function()
    return { sysname = "UnknownOS" }
  end
  success, err = pcall(health.check)
  assert(success, "health check should handle unknown OS: " .. tostring(err))
  
  -- Restore original function
  vim.loop.os_uname = original_os_uname
  
  print("✓ Health OS detection tests passed!")
end

local function test_health_terminal_detection()
  print("Testing health terminal detection...")
  
  local health = require("mona.health")
  
  -- Test with different terminal values
  local original_term_program = vim.env.TERM_PROGRAM
  local original_term = vim.env.TERM
  
  -- Test alacritty
  vim.env.TERM_PROGRAM = "alacritty"
  local success, err = pcall(health.check)
  assert(success, "health check should work with alacritty: " .. tostring(err))
  
  -- Test kitty
  vim.env.TERM_PROGRAM = "kitty"
  success, err = pcall(health.check)
  assert(success, "health check should work with kitty: " .. tostring(err))
  
  -- Test unknown terminal
  vim.env.TERM_PROGRAM = nil
  vim.env.TERM = "unknown_terminal"
  success, err = pcall(health.check)
  assert(success, "health check should handle unknown terminal: " .. tostring(err))
  
  -- Restore original values
  vim.env.TERM_PROGRAM = original_term_program
  vim.env.TERM = original_term
  
  print("✓ Health terminal detection tests passed!")
end

local function test_health_tool_detection()
  print("Testing health tool detection...")
  
  local health = require("mona.health")
  
  -- Test with different tool availability
  local original_system = vim.fn.system
  
  -- Test when tools are available
  vim.fn.system = function(cmd)
    if cmd:match("which curl") then
      return "/usr/bin/curl"
    elseif cmd:match("which unzip") then
      return "/usr/bin/unzip"
    else
      return ""
    end
  end
  local success, err = pcall(health.check)
  assert(success, "health check should work when tools are available: " .. tostring(err))
  
  -- Test when tools are missing
  vim.fn.system = function(cmd)
    return ""
  end
  success, err = pcall(health.check)
  assert(success, "health check should work when tools are missing: " .. tostring(err))
  
  -- Restore original function
  vim.fn.system = original_system
  
  print("✓ Health tool detection tests passed!")
end

-- Run all tests
print("Running mona.nvim health tests...")
print("=" .. string.rep("=", 50))

test_health_module()
test_health_check()
test_health_os_detection()
test_health_terminal_detection()
test_health_tool_detection()

print("=" .. string.rep("=", 50))
print("All health tests passed!") 