local helpers = require("plenary.test_harness").test_directory
local eq = assert.are.same

vim.cmd([[packadd plenary.nvim]])

local function exec_cmd(cmd)
  vim.cmd(cmd)
end

describe("mona.nvim integration", function()
  before_each(function()
    -- Reload plugin for each test
    package.loaded["mona"] = nil
    package.loaded["mona.config"] = nil
    package.loaded["mona.installer"] = nil
    package.loaded["mona.terminal"] = nil
    package.loaded["mona.preview"] = nil
    package.loaded["mona.health"] = nil
    package.loaded["mona.highlights"] = nil
    vim.cmd([[silent! delcommand MonaInstall]])
    vim.cmd([[silent! delcommand MonaStatus]])
    vim.cmd([[silent! delcommand MonaPreview]])
    vim.cmd([[silent! delcommand MonaHealth]])
    vim.cmd([[silent! delcommand MonaExportConfig]])
    vim.cmd([[silent! delcommand MonaLoad]])
    vim.cmd([[silent! delcommand MonaUninstall]])
    vim.cmd([[silent! delcommand MonaUpdate]])
    
    -- Source the plugin file to register commands
    vim.cmd([[runtime plugin/mona.lua]])
  end)

  it("loads the plugin and sets up config", function()
    local mona = require("mona")
    assert(mona)
    mona.setup({ font_features = { texture_healing = true } })
    eq(true, require("mona.config").config.font_features.texture_healing)
  end)

  it("registers MonaInstall command", function()
    -- Test that the command exists without executing it
    local cmd_exists = vim.fn.exists(":MonaInstall") == 2
    assert(cmd_exists, "MonaInstall command should be registered")
  end)

  it("registers MonaStatus command", function()
    local ok = pcall(function() exec_cmd("MonaStatus") end)
    assert(ok)
  end)

  it("registers MonaPreview command", function()
    local ok = pcall(function() exec_cmd("MonaPreview") end)
    assert(ok)
  end)

  it("registers MonaHealth command", function()
    local ok = pcall(function() exec_cmd("MonaHealth") end)
    assert(ok)
  end)
end) 