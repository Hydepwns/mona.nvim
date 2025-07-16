local mona = require("mona")
local utils = require("mona.utils")

-- Font management commands
vim.api.nvim_create_user_command("MonaInstall", function(opts)
  local args = vim.split(opts.args, " ")
  require("mona.installer").install({
    font_type = args[1] or "variable",
    families = args[2] and vim.split(args[2], ",") or { "all" }
  })
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    local parts = vim.split(cmdline, " ")
    if #parts == 2 then
      return { "otf", "variable", "frozen" }
    elseif #parts == 3 then
      return { "all", "neon", "argon", "xenon", "radon", "krypton" }
    end
  end
})

vim.api.nvim_create_user_command("MonaUpdate", function()
  require("mona.installer").update()
end, {})

vim.api.nvim_create_user_command("MonaUninstall", function(opts)
  local families = opts.args ~= "" and vim.split(opts.args, ",") or nil
  require("mona.installer").uninstall(families)
end, { nargs = "?" })

-- Configuration commands
vim.api.nvim_create_user_command("MonaPreview", function()
  require("mona.preview").show()
end, {})

vim.api.nvim_create_user_command("MonaExportConfig", function(opts)
  local args = vim.split(opts.args, " ")
  local terminal = args[1]
  local filepath = args[2]
  
  if not terminal then
    utils.error("Usage: MonaExportConfig <terminal> [filepath]")
    return
  end
  
  local config = require("mona.terminal").export(terminal, filepath)
  if not filepath then
    utils.info(config)
  else
    utils.info(string.format("Config exported to: %s", filepath))
  end
end, {
  nargs = "+",
  complete = function()
    return { "alacritty", "kitty", "wezterm", "ghostty" }
  end
})

-- Existing command enhancement
vim.api.nvim_create_user_command("MonaLoad", function()
  require("mona.highlights").load()
end, {})

vim.api.nvim_create_user_command("MonaStatus", function()
  local installer = require("mona.installer")
  local installation = installer.check_installation()
  
  print("Monaspace Font Status:")
  for family, installed in pairs(installation) do
    local status = installed and "✓" or "✗"
    print(string.format("  %s %s", status, utils.format_font_family(family)))
  end
end, {})

-- Health check command
vim.api.nvim_create_user_command("MonaHealth", function()
  require("mona.health").check()
end, {}) 