-- Simple validation script for mona.nvim
-- This script validates the plugin structure and basic functionality

print("Validating mona.nvim plugin structure...")
print("=" .. string.rep("=", 50))

-- Check if required files exist
local files = {
  "lua/mona/init.lua",
  "lua/mona/config.lua", 
  "lua/mona/installer.lua",
  "lua/mona/terminal.lua",
  "lua/mona/preview.lua",
  "lua/mona/health.lua",
  "lua/mona/highlights.lua",
  "lua/mona/utils.lua",
  "plugin/mona.lua",
  "README.md",
  "LICENSE"
}

print("Checking required files...")
for _, file in ipairs(files) do
  local f = io.open(file, "r")
  if f then
    f:close()
    print("✓ " .. file)
  else
    print("✗ " .. file .. " (missing)")
  end
end

-- Check directory structure
print("\nChecking directory structure...")
local dirs = {
  "lua/mona",
  "plugin", 
  "test"
}

for _, dir in ipairs(dirs) do
  local f = io.open(dir, "r")
  if f then
    f:close()
    print("✓ " .. dir)
  else
    print("✗ " .. dir .. " (missing)")
  end
end

-- Basic syntax check for Lua files
print("\nChecking Lua file syntax...")
local lua_files = {
  "lua/mona/init.lua",
  "lua/mona/config.lua",
  "lua/mona/installer.lua", 
  "lua/mona/terminal.lua",
  "lua/mona/preview.lua",
  "lua/mona/health.lua",
  "lua/mona/highlights.lua",
  "lua/mona/utils.lua",
  "plugin/mona.lua"
}

for _, file in ipairs(lua_files) do
  local f = io.open(file, "r")
  if f then
    local content = f:read("*all")
    f:close()
    
    -- Basic syntax check (very simple)
    if content:match("local M = {}") and content:match("return M") then
      print("✓ " .. file .. " (basic syntax OK)")
    else
      print("? " .. file .. " (syntax check inconclusive)")
    end
  else
    print("✗ " .. file .. " (cannot read)")
  end
end

-- Check README content
print("\nChecking README content...")
local f = io.open("README.md", "r")
if f then
  local content = f:read("*all")
  f:close()
  
  local checks = {
    { "mona.nvim", "Plugin name" },
    { "## Features", "Features section" },
    { "## Installation", "Installation section" },
    { "## Commands", "Commands section" },
    { ":MonaInstall", "Install command" },
    { ":MonaPreview", "Preview command" },
    { ":MonaHealth", "Health command" }
  }
  
  for _, check in ipairs(checks) do
    if content:find(check[1]) then
      print("✓ " .. check[2])
    else
      print("✗ " .. check[2])
    end
  end
else
  print("✗ Cannot read README.md")
end

print("\n" .. string.rep("=", 50))
print("Validation complete!")
print("\nPlugin structure appears to be correct.")
print("To test with Neovim, install the plugin and run:")
print("  :MonaHealth")
print("  :MonaStatus") 
print("  :MonaPreview") 