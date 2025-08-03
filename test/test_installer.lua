-- Installer module tests for mona.nvim
-- Mock Neovim API for testing
vim = {
  tbl_deep_extend = function(mode, ...)
    local result = {}
    for i = 1, select("#", ...) do
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
  fn = {
    expand = function(path)
      return path:gsub("~", "/home/user")
    end,
    glob = function(pattern, nosuf, list)
      if pattern:match("MonaspaceNeon") then
        return { "/home/user/.local/share/fonts/MonaspaceNeon-Regular.ttf" }
      elseif pattern:match("MonaspaceArgon") then
        return {}
      else
        return { "/home/user/.local/share/fonts/MonaspaceXenon-Regular.ttf" }
      end
    end,
    system = function(cmd)
      if cmd:match("curl") then
        return "Downloaded successfully"
      elseif cmd:match("unzip") then
        return "Extracted successfully"
      elseif cmd:match("fc-cache") then
        return "Cache refreshed"
      else
        return "Command executed"
      end
    end,
    systemlist = function(cmd)
      if cmd:match("find.*%.ttf") then
        return { "/tmp/mona_test_12345/MonaspaceNeon-Regular.ttf" }
      elseif cmd:match("find.*%.otf") then
        return { "/tmp/mona_test_12345/MonaspaceNeon-Regular.otf" }
      else
        return {}
      end
    end,
    tempname = function()
      return "/tmp/mona_test_12345"
    end,
    mkdir = function(path, mode)
      -- Mock implementation
    end,
    delete = function(path, flags)
      -- Mock implementation
    end,
    json_decode = function(str)
      -- Simple JSON parser for test
      if str:match('"tag_name"%s*:%s*"v1%.0%.0"') then
        return {
          tag_name = "v1.0.0",
          assets = {
            {
              browser_download_url = "https://example.com/monaspace.zip",
            },
          },
        }
      end
      error("Invalid JSON")
    end,
    writefile = function(lines, filepath)
      -- Mock implementation
    end,
    fnamemodify = function(path, mod)
      return path
    end,
  },
  v = {
    shell_error = 0,
  },
  loop = {
    os_uname = function()
      return { sysname = "Linux" }
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

local function test_installer_module()
  print("Testing installer module...")

  local installer = require("mona.installer")

  -- Test module structure
  assert(type(installer.config) == "table", "config table should exist")
  assert(type(installer.get_install_path) == "function", "get_install_path function should exist")
  assert(
    type(installer.check_installation) == "function",
    "check_installation function should exist"
  )
  assert(type(installer.download_file) == "function", "download_file function should exist")
  assert(type(installer.extract_archive) == "function", "extract_archive function should exist")
  assert(
    type(installer.refresh_font_cache) == "function",
    "refresh_font_cache function should exist"
  )
  assert(
    type(installer.get_latest_release) == "function",
    "get_latest_release function should exist"
  )
  assert(type(installer.install) == "function", "install function should exist")
  assert(type(installer.update) == "function", "update function should exist")
  assert(type(installer.uninstall) == "function", "uninstall function should exist")

  print("✓ Installer module structure tests passed!")
end

local function test_installer_config()
  print("Testing installer config...")

  local installer = require("mona.installer")

  -- Test config structure
  assert(type(installer.config.install_path) == "table", "install_path should be a table")
  assert(installer.config.install_path.Darwin, "should have Darwin path")
  assert(installer.config.install_path.Linux, "should have Linux path")
  assert(installer.config.install_path.Windows, "should have Windows path")

  assert(type(installer.config.github_api) == "string", "github_api should be a string")
  assert(installer.config.github_api:match("github%.com"), "github_api should contain github.com")

  assert(type(installer.config.font_types) == "table", "font_types should be a table")
  assert(#installer.config.font_types > 0, "font_types should not be empty")

  assert(type(installer.config.font_families) == "table", "font_families should be a table")
  assert(#installer.config.font_families > 0, "font_families should not be empty")

  print("✓ Installer config tests passed!")
end

local function test_installer_get_install_path()
  print("Testing installer get_install_path functionality...")

  local installer = require("mona.installer")

  -- Test Linux path
  local path = installer.get_install_path()
  assert(type(path) == "string", "get_install_path should return a string")
  assert(path:match("/home/user/.local/share/fonts"), "should return correct Linux path")

  -- Test with different OS
  local original_os_uname = vim.loop.os_uname

  -- Test macOS
  vim.loop.os_uname = function()
    return { sysname = "Darwin" }
  end
  path = installer.get_install_path()
  assert(path:match("/home/user/Library/Fonts"), "should return correct macOS path")

  -- Test Windows
  vim.loop.os_uname = function()
    return { sysname = "Windows" }
  end
  path = installer.get_install_path()
  print("DEBUG: Windows path = " .. path)
  assert(
    path:match("C:\\Windows\\Fonts") or path:match("C:/Windows/Fonts"),
    "should return correct Windows path"
  )

  -- Test unsupported OS
  vim.loop.os_uname = function()
    return { sysname = "UnknownOS" }
  end
  local success, err = pcall(installer.get_install_path)
  assert(not success, "should error for unsupported OS")
  assert(err:match("Unsupported OS"), "should have specific error message")

  -- Restore original function
  vim.loop.os_uname = original_os_uname

  print("✓ Installer get_install_path functionality tests passed!")
end

local function test_installer_check_installation()
  print("Testing installer check_installation functionality...")

  local installer = require("mona.installer")

  local status = installer.check_installation()

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

  print("✓ Installer check_installation functionality tests passed!")
end

local function test_installer_download_file()
  print("Testing installer download_file functionality...")

  local installer = require("mona.installer")

  -- Test successful download
  local success, err = pcall(function()
    installer.download_file("https://example.com/file.zip", "/tmp/test.zip")
  end)
  assert(success, "download_file should not error: " .. tostring(err))

  -- Test with progress callback
  local progress_called = false
  success, err = pcall(function()
    installer.download_file("https://example.com/file.zip", "/tmp/test.zip", function(msg)
      progress_called = true
      assert(msg:match("Downloading"), "progress message should mention downloading")
    end)
  end)
  assert(success, "download_file with callback should not error: " .. tostring(err))
  assert(progress_called, "progress callback should be called")

  print("✓ Installer download_file functionality tests passed!")
end

local function test_installer_extract_archive()
  print("Testing installer extract_archive functionality...")

  local installer = require("mona.installer")

  -- Test zip extraction
  local success, err = pcall(function()
    installer.extract_archive("/tmp/test.zip", "/tmp/extract")
  end)
  assert(success, "extract_archive should not error: " .. tostring(err))

  -- Test tar.gz extraction
  success, err = pcall(function()
    installer.extract_archive("/tmp/test.tar.gz", "/tmp/extract")
  end)
  assert(success, "extract_archive should handle tar.gz: " .. tostring(err))

  -- Test unsupported format
  success, err = pcall(function()
    installer.extract_archive("/tmp/test.rar", "/tmp/extract")
  end)
  assert(not success, "should error for unsupported format")
  assert(err:match("Unsupported archive format"), "should have specific error message")

  print("✓ Installer extract_archive functionality tests passed!")
end

local function test_installer_refresh_font_cache()
  print("Testing installer refresh_font_cache functionality...")

  local installer = require("mona.installer")

  -- Test Linux cache refresh
  local success, err = pcall(installer.refresh_font_cache)
  assert(success, "refresh_font_cache should not error: " .. tostring(err))

  -- Test with different OS
  local original_os_uname = vim.loop.os_uname

  -- Test macOS (should not need cache refresh)
  vim.loop.os_uname = function()
    return { sysname = "Darwin" }
  end
  success, err = pcall(installer.refresh_font_cache)
  assert(success, "refresh_font_cache should work on macOS: " .. tostring(err))

  -- Test Windows (should not need cache refresh)
  vim.loop.os_uname = function()
    return { sysname = "Windows" }
  end
  success, err = pcall(installer.refresh_font_cache)
  assert(success, "refresh_font_cache should work on Windows: " .. tostring(err))

  -- Restore original function
  vim.loop.os_uname = original_os_uname

  print("✓ Installer refresh_font_cache functionality tests passed!")
end

local function test_installer_get_latest_release()
  print("Testing installer get_latest_release functionality...")

  local installer = require("mona.installer")

  -- Mock successful API response
  local original_system = vim.fn.system
  vim.fn.system = function(cmd)
    if cmd:match("curl.*github%.com") then
      return '{"tag_name": "v1.0.0", "assets": [{"browser_download_url": "https://example.com/monaspace.zip"}]}'
    else
      return ""
    end
  end

  local release = installer.get_latest_release(false) -- disable cache for test

  -- Test return structure
  assert(type(release) == "table", "get_latest_release should return a table")
  assert(release.version, "should have version")
  assert(release.download_url, "should have download_url")
  assert(release.version == "v1.0.0", "should parse version correctly")
  assert(
    release.download_url == "https://example.com/monaspace.zip",
    "should parse download_url correctly"
  )

  -- Restore original function
  vim.fn.system = original_system

  print("✓ Installer get_latest_release functionality tests passed!")
end

local function test_installer_install()
  print("Testing installer install functionality...")

  local installer = require("mona.installer")

  -- Test default installation
  local original_system = vim.fn.system
  vim.fn.system = function(cmd)
    if cmd:match("curl.*github%.com") then
      return '{"tag_name": "v1.0.0", "browser_download_url": "https://example.com/monaspace.zip"}'
    elseif cmd:match("curl") then
      return "Downloaded successfully"
    elseif cmd:match("unzip") then
      return "Extracted successfully"
    elseif cmd:match("cp") then
      return ""
    else
      return "Command executed"
    end
  end
  local success, err = pcall(function()
    installer.install()
  end)
  assert(success, "install should not error: " .. tostring(err))

  -- Test specific families
  success, err = pcall(function()
    installer.install({ families = { "neon", "argon" } })
  end)
  assert(success, "install with specific families should not error: " .. tostring(err))

  -- Test with force flag
  success, err = pcall(function()
    installer.install({ force = true })
  end)
  assert(success, "install with force should not error: " .. tostring(err))

  -- Restore original function
  vim.fn.system = original_system

  print("✓ Installer install functionality tests passed!")
end

local function test_installer_update()
  print("Testing installer update functionality...")

  local installer = require("mona.installer")

  -- Mock successful update
  local original_system = vim.fn.system
  vim.fn.system = function(cmd)
    if cmd:match("curl.*github%.com") then
      return '{"tag_name": "v1.0.0", "browser_download_url": "https://example.com/monaspace.zip"}'
    elseif cmd:match("curl") then
      return "Downloaded successfully"
    elseif cmd:match("unzip") then
      return "Extracted successfully"
    elseif cmd:match("cp") then
      return ""
    else
      return "Command executed"
    end
  end
  -- Test update function
  local success, err = pcall(installer.update)
  assert(success, "update should not error: " .. tostring(err))
  -- Restore original function
  vim.fn.system = original_system

  print("✓ Installer update functionality tests passed!")
end

local function test_installer_uninstall()
  print("Testing installer uninstall functionality...")

  local installer = require("mona.installer")

  -- Test uninstall all
  local success, err = pcall(function()
    installer.uninstall({ "neon", "argon", "xenon", "radon", "krypton" })
  end)
  assert(success, "uninstall should not error: " .. tostring(err))

  -- Test uninstall specific families
  success, err = pcall(function()
    installer.uninstall({ "neon", "argon" })
  end)
  assert(success, "uninstall specific families should not error: " .. tostring(err))

  print("✓ Installer uninstall functionality tests passed!")
end

-- Run all tests
print("Running mona.nvim installer tests...")
print("=" .. string.rep("=", 50))

test_installer_module()
test_installer_config()
test_installer_get_install_path()
test_installer_check_installation()
test_installer_download_file()
test_installer_extract_archive()
test_installer_refresh_font_cache()
test_installer_get_latest_release()
test_installer_install()
test_installer_update()
test_installer_uninstall()

print("=" .. string.rep("=", 50))
print("All installer tests passed!")
