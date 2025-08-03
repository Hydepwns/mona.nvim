-- Terminal module tests for mona.nvim
-- Mock Neovim API for testing
vim = {
  env = {
    HOME = "/home/user",
    USERPROFILE = "/home/user",
  },
  fn = {
    expand = function(path)
      return path
    end,
    writefile = function(lines, filepath)
      -- Mock implementation
    end,
  },
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
    terminal_config = {
      auto_generate = true,
      terminals = { "alacritty", "kitty", "wezterm", "ghostty" },
    },
  },
}

local function test_terminal_module()
  print("Testing terminal module...")

  local terminal = require("mona.terminal")

  -- Test module structure
  assert(type(terminal.configs) == "table", "configs table should exist")
  assert(type(terminal.generate) == "function", "generate function should exist")
  assert(type(terminal.export) == "function", "export function should exist")
  assert(type(terminal.get_default_paths) == "function", "get_default_paths function should exist")
  assert(type(terminal.auto_generate) == "function", "auto_generate function should exist")

  -- Test configs table has expected terminals
  assert(terminal.configs.alacritty, "alacritty config should exist")
  assert(terminal.configs.kitty, "kitty config should exist")
  assert(terminal.configs.wezterm, "wezterm config should exist")
  assert(terminal.configs.ghostty, "ghostty config should exist")

  print("✓ Terminal module structure tests passed!")
end

local function test_terminal_generate()
  print("Testing terminal generate functionality...")

  local terminal = require("mona.terminal")

  -- Test default font map
  local config = terminal.generate("alacritty")
  assert(type(config) == "string", "generate should return a string")
  assert(config:match("Monaspace Neon"), "should contain default normal font")
  assert(config:match("Monaspace Xenon"), "should contain default bold font")
  assert(config:match("Monaspace Radon"), "should contain default italic font")
  assert(config:match("Monaspace Krypton"), "should contain default bold_italic font")

  -- Test custom font map
  local custom_font_map = {
    normal = "Argon",
    bold = "Neon",
    italic = "Xenon",
    bold_italic = "Radon",
  }
  config = terminal.generate("alacritty", custom_font_map)
  assert(config:match("Monaspace Argon"), "should contain custom normal font")
  assert(config:match("Monaspace Neon"), "should contain custom bold font")
  assert(config:match("Monaspace Xenon"), "should contain custom italic font")
  assert(config:match("Monaspace Radon"), "should contain custom bold_italic font")

  print("✓ Terminal generate functionality tests passed!")
end

local function test_terminal_configs()
  print("Testing terminal configs...")

  local terminal = require("mona.terminal")

  -- Test alacritty config
  local alacritty_config = terminal.generate("alacritty")
  assert(alacritty_config:match("%[font%]"), "alacritty config should contain [font] section")
  assert(
    alacritty_config:match("normal = { family ="),
    "alacritty config should contain normal font"
  )
  assert(alacritty_config:match("bold = { family ="), "alacritty config should contain bold font")
  assert(
    alacritty_config:match("italic = { family ="),
    "alacritty config should contain italic font"
  )
  assert(
    alacritty_config:match("bold_italic = { family ="),
    "alacritty config should contain bold_italic font"
  )

  -- Test kitty config
  local kitty_config = terminal.generate("kitty")
  assert(kitty_config:match("font_family"), "kitty config should contain font_family")
  assert(kitty_config:match("bold_font"), "kitty config should contain bold_font")
  assert(kitty_config:match("italic_font"), "kitty config should contain italic_font")
  assert(kitty_config:match("bold_italic_font"), "kitty config should contain bold_italic_font")

  -- Test wezterm config
  local wezterm_config = terminal.generate("wezterm")
  assert(wezterm_config:match("return {"), "wezterm config should start with return {")
  assert(
    wezterm_config:match("font = wezterm%.font_with_fallback"),
    "wezterm config should contain font_with_fallback"
  )
  assert(wezterm_config:match("font_rules = {"), "wezterm config should contain font_rules")

  -- Test ghostty config
  local ghostty_config = terminal.generate("ghostty")
  assert(ghostty_config:match("font%-family ="), "ghostty config should contain font-family")
  assert(
    ghostty_config:match("font%-family%-bold ="),
    "ghostty config should contain font-family-bold"
  )
  assert(
    ghostty_config:match("font%-family%-italic ="),
    "ghostty config should contain font-family-italic"
  )
  assert(
    ghostty_config:match("font%-family%-bold%-italic ="),
    "ghostty config should contain font-family-bold-italic"
  )

  print("✓ Terminal configs tests passed!")
end

local function test_terminal_export()
  print("Testing terminal export functionality...")

  local terminal = require("mona.terminal")

  -- Test export without filepath (should return config)
  local config = terminal.export("alacritty")
  assert(type(config) == "string", "export should return config string when no filepath")
  assert(config:match("Monaspace"), "exported config should contain Monaspace fonts")

  -- Test export with filepath (should write file)
  local success, err = pcall(function()
    terminal.export("kitty", "/tmp/test_kitty.conf")
  end)
  assert(success, "export should not error when writing file: " .. tostring(err))

  print("✓ Terminal export functionality tests passed!")
end

local function test_terminal_get_default_paths()
  print("Testing terminal get_default_paths functionality...")

  local terminal = require("mona.terminal")

  local paths = terminal.get_default_paths()

  -- Test paths structure
  assert(type(paths) == "table", "get_default_paths should return a table")
  assert(paths.alacritty, "should have alacritty path")
  assert(paths.kitty, "should have kitty path")
  assert(paths.wezterm, "should have wezterm path")
  assert(paths.ghostty, "should have ghostty path")

  -- Test path format
  assert(
    paths.alacritty:match("/%.config/alacritty/"),
    "alacritty path should contain .config/alacritty"
  )
  assert(paths.kitty:match("/%.config/kitty/"), "kitty path should contain .config/kitty")
  assert(paths.wezterm:match("/%.config/wezterm/"), "wezterm path should contain .config/wezterm")
  assert(paths.ghostty:match("/%.config/ghostty/"), "ghostty path should contain .config/ghostty")

  print("✓ Terminal get_default_paths functionality tests passed!")
end

local function test_terminal_auto_generate()
  print("Testing terminal auto_generate functionality...")

  local terminal = require("mona.terminal")

  -- Test auto_generate function
  local success, err = pcall(terminal.auto_generate)
  assert(success, "auto_generate should not error: " .. tostring(err))

  print("✓ Terminal auto_generate functionality tests passed!")
end

local function test_terminal_unsupported()
  print("Testing terminal unsupported terminal handling...")

  local terminal = require("mona.terminal")

  -- Test unsupported terminal
  local success, err = pcall(function()
    terminal.generate("unsupported_terminal")
  end)
  assert(not success, "generate should error for unsupported terminal")
  assert(err:match("Unsupported terminal"), "should have specific error message")

  print("✓ Terminal unsupported terminal handling tests passed!")
end

-- Run all tests
print("Running mona.nvim terminal tests...")
print("=" .. string.rep("=", 50))

test_terminal_module()
test_terminal_generate()
test_terminal_configs()
test_terminal_export()
test_terminal_get_default_paths()
test_terminal_auto_generate()
test_terminal_unsupported()

print("=" .. string.rep("=", 50))
print("All terminal tests passed!")
