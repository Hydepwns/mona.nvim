local M = {}
local utils = require("mona.utils")

M.check = function()
  vim.health.start("mona.nvim")

  -- Check OS support
  local os_name = utils.get_os()
  if os_name == "Darwin" or os_name == "Linux" or os_name:match("Windows") then
    vim.health.ok("OS supported: " .. os_name)
  else
    vim.health.warn("Untested OS: " .. os_name)
  end

  -- Check font installation
  local installer = require("mona.installer")
  local installation = installer.check_installation()

  local all_installed = true
  for family, installed in pairs(installation) do
    if installed then
      vim.health.ok("Monaspace " .. utils.format_font_family(family) .. " installed")
    else
      vim.health.warn("Monaspace " .. utils.format_font_family(family) .. " not found")
      all_installed = false
    end
  end

  if not all_installed then
    vim.health.info("Run :MonaInstall to install missing fonts")
  end

  -- Check terminal support
  local term = vim.env.TERM_PROGRAM or vim.env.TERM
  local supported_terms = {
    "alacritty",
    "kitty",
    "WezTerm",
    "ghostty",
    "iTerm.app",
    "Terminal.app",
    "tmux",
  }

  local term_supported = false
  for _, supported in ipairs(supported_terms) do
    if term and term:lower():match(supported:lower()) then
      term_supported = true
      vim.health.ok("Terminal appears to be: " .. term)
      break
    end
  end

  if not term_supported then
    vim.health.warn("Unknown terminal: " .. (term or "undetected"))
    vim.health.info("Font mixing may not work correctly")
  end

  -- Check GUI support
  if utils.is_gui() then
    vim.health.ok("GUI Neovim detected - full font feature support available")
  else
    vim.health.info("Terminal Neovim - using terminal font style workaround")
  end

  -- Check required external tools
  local tools = { "curl", "unzip" }
  for _, tool in ipairs(tools) do
    local result = vim.fn.system("which " .. tool)
    if vim.v.shell_error == 0 then
      vim.health.ok(tool .. " available")
    else
      vim.health.warn(tool .. " not found - required for font installation")
    end
  end

  -- Check configuration
  local config = require("mona.config").config
  if config.font_features.texture_healing then
    vim.health.info("Texture healing enabled")
  end
  if config.font_features.ligatures.enable then
    vim.health.info("Ligatures enabled")
  end
end

return M
