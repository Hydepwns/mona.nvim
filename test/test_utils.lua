-- Utility function tests for mona.nvim
-- Add current directory to package path for testing
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Mock Neovim API for testing
vim = vim or {}
vim.log = vim.log or { levels = { INFO = 1, WARN = 2, ERROR = 3 } }
vim.notify = vim.notify
  or function(msg, level)
    print(string.format("[NOTIFY %s] %s", level, msg))
  end
vim.fn = vim.fn
  or {
    writefile = function(lines, path)
      return true
    end,
    mkdir = function(path, p)
      return true
    end,
    delete = function(path, rf)
      return true
    end,
    has = function(feature)
      return 0
    end,
  }
vim.loop = vim.loop or {
  os_uname = function()
    return { sysname = "Linux" }
  end,
}

local utils = require("mona.utils")

local function test_notify()
  print("Testing notify...")
  utils.notify("Test info", vim.log.levels.INFO)
  utils.warn("Test warn")
  utils.info("Test info")
  print("✓ notify, warn, info tested")
end

local function test_error()
  print("Testing error...")
  local ok, err = pcall(function()
    utils.error("Test error")
  end)
  assert(not ok and err:match("%[mona%.nvim%]"), "Error should include plugin prefix")
  print("✓ error tested")
end

local function test_validate_table()
  print("Testing validate_table...")
  utils.validate_table({}, "tbl")
  local ok = pcall(function()
    utils.validate_table(123, "tbl")
  end)
  assert(not ok, "Should error on non-table")
  print("✓ validate_table tested")
end

local function test_validate_boolean()
  print("Testing validate_boolean...")
  utils.validate_boolean(true, "bool")
  local ok = pcall(function()
    utils.validate_boolean("no", "bool")
  end)
  assert(not ok, "Should error on non-boolean")
  print("✓ validate_boolean tested")
end

local function test_validate_string()
  print("Testing validate_string...")
  utils.validate_string("hi", "str")
  local ok = pcall(function()
    utils.validate_string(123, "str")
  end)
  assert(not ok, "Should error on non-string")
  print("✓ validate_string tested")
end

local function test_validate_number()
  print("Testing validate_number...")
  utils.validate_number(5, "num", 1, 10)
  local ok = pcall(function()
    utils.validate_number("no", "num")
  end)
  assert(not ok, "Should error on non-number")
  ok = pcall(function()
    utils.validate_number(0, "num", 1, 10)
  end)
  assert(not ok, "Should error on min")
  ok = pcall(function()
    utils.validate_number(11, "num", 1, 10)
  end)
  assert(not ok, "Should error on max")
  print("✓ validate_number tested")
end

local function test_validate_enum()
  print("Testing validate_enum...")
  utils.validate_enum("a", "enum", { "a", "b" })
  local ok = pcall(function()
    utils.validate_enum("c", "enum", { "a", "b" })
  end)
  assert(not ok, "Should error on invalid enum")
  print("✓ validate_enum tested")
end

local function test_safe_write_file()
  print("Testing safe_write_file...")
  local ok = utils.safe_write_file("/tmp/test_utils_file", "line1\nline2")
  assert(ok, "safe_write_file should succeed")
  print("✓ safe_write_file tested")
end

local function test_safe_mkdir()
  print("Testing safe_mkdir...")
  local ok = utils.safe_mkdir("/tmp/test_utils_dir")
  assert(ok, "safe_mkdir should succeed")
  print("✓ safe_mkdir tested")
end

local function test_safe_delete()
  print("Testing safe_delete...")
  local ok = utils.safe_delete("/tmp/test_utils_file")
  assert(ok, "safe_delete should succeed")
  print("✓ safe_delete tested")
end

local function test_get_os()
  print("Testing get_os...")
  local os = utils.get_os()
  assert(os == "Linux", "get_os should return Linux")
  print("✓ get_os tested")
end

local function test_is_gui()
  print("Testing is_gui...")
  local gui = utils.is_gui()
  assert(gui == false, "is_gui should return false in test")
  print("✓ is_gui tested")
end

local function test_format_font_family()
  print("Testing format_font_family...")
  assert(utils.format_font_family("neon") == "Neon", "Should capitalize")
  print("✓ format_font_family tested")
end

print("Running mona.nvim utils tests...")
test_notify()
test_error()
test_validate_table()
test_validate_boolean()
test_validate_string()
test_validate_number()
test_validate_enum()
test_safe_write_file()
test_safe_mkdir()
test_safe_delete()
test_get_os()
test_is_gui()
test_format_font_family()
print("All utils tests passed!")
