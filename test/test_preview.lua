-- Preview module tests for mona.nvim
-- Mock Neovim API for testing
vim = {
  api = {
    nvim_create_buf = function(listed, scratch)
      return 1 -- Return buffer handle
    end,
    nvim_buf_set_lines = function(buf, start, end_idx, strict, lines)
      -- Mock implementation
    end,
    nvim_open_win = function(buf, enter, opts)
      return 1 -- Return window handle
    end,
    nvim_buf_set_option = function(buf, name, value)
      -- Mock implementation
    end,
    nvim_buf_set_keymap = function(buf, mode, lhs, rhs, opts)
      -- Mock implementation
    end,
    nvim_buf_add_highlight = function(buf, ns_id, hl_group, line, col_start, col_end)
      -- Mock implementation
    end,
    nvim_buf_set_name = function(buf, name)
      -- Mock implementation
    end,
    nvim_win_is_valid = function(win)
      return true
    end,
    nvim_buf_is_valid = function(buf)
      return true
    end,
    nvim_win_close = function(win, force)
      -- Mock implementation
    end,
    nvim_buf_delete = function(buf, opts)
      -- Mock implementation
    end,
  },
  o = {
    lines = 24,
    columns = 80,
  },
  split = function(str, sep, plain)
    local result = {}
    local pattern = string.format("([^%s]+)", sep or "%s")
    for match in str:gmatch(pattern) do
      table.insert(result, match)
    end
    return result
  end,
  log = {
    levels = {
      INFO = 1,
      WARN = 2,
      ERROR = 3,
    },
  },
  notify = function(msg, level)
    print(string.format("[%s] %s", level == 1 and "INFO" or level == 2 and "WARN" or "ERROR", msg))
  end,
}

-- Add current directory to package path for testing
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Mock config module
package.loaded["mona.config"] = {
  config = {
    preview = {
      sample_text = "Test sample text\nLine 2\nLine 3",
      window_opts = {
        width = 80,
        height = 20,
        border = "rounded",
      },
    },
  },
}

local function test_preview_module()
  print("Testing preview module...")

  local preview = require("mona.preview")

  -- Test module structure
  assert(preview.preview_buffer == nil, "preview_buffer should be nil initially")
  assert(preview.preview_window == nil, "preview_window should be nil initially")
  assert(type(preview.show) == "function", "show function should exist")
  assert(type(preview.close) == "function", "close function should exist")
  assert(
    type(preview.apply_preview_highlights) == "function",
    "apply_preview_highlights function should exist"
  )
  assert(type(preview.cycle_fonts) == "function", "cycle_fonts function should exist")

  print("✓ Preview module structure tests passed!")
end

local function test_preview_show()
  print("Testing preview show functionality...")

  local preview = require("mona.preview")

  -- Test show function
  local success, err = pcall(preview.show)
  assert(success, "show function should not error: " .. tostring(err))

  -- Test that preview window and buffer are set
  assert(preview.preview_window ~= nil, "preview_window should be set after show")
  assert(preview.preview_buffer ~= nil, "preview_buffer should be set after show")

  print("✓ Preview show functionality tests passed!")
end

local function test_preview_close()
  print("Testing preview close functionality...")

  local preview = require("mona.preview")

  -- First show preview
  preview.show()

  -- Test close function
  local success, err = pcall(preview.close)
  assert(success, "close function should not error: " .. tostring(err))

  -- Test that preview window and buffer are cleared
  assert(preview.preview_window == nil, "preview_window should be nil after close")
  assert(preview.preview_buffer == nil, "preview_buffer should be nil after close")

  print("✓ Preview close functionality tests passed!")
end

local function test_preview_highlights()
  print("Testing preview highlights functionality...")

  local preview = require("mona.preview")

  -- Test apply_preview_highlights function
  local success, err = pcall(preview.apply_preview_highlights)
  assert(success, "apply_preview_highlights should not error: " .. tostring(err))

  print("✓ Preview highlights functionality tests passed!")
end

local function test_preview_cycle_fonts()
  print("Testing preview cycle fonts functionality...")

  local preview = require("mona.preview")

  -- Test cycle_fonts function
  local success, err = pcall(function()
    preview.cycle_fonts("bold")
  end)
  assert(success, "cycle_fonts should not error: " .. tostring(err))

  print("✓ Preview cycle fonts functionality tests passed!")
end

-- Run all tests
print("Running mona.nvim preview tests...")
print("=" .. string.rep("=", 50))

test_preview_module()
test_preview_show()
test_preview_close()
test_preview_highlights()
test_preview_cycle_fonts()

print("=" .. string.rep("=", 50))
print("All preview tests passed!")
