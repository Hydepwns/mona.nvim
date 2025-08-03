local mona = require("mona")
local utils = require("mona.utils")

-- Completion functions
local function complete_font_types(arglead, cmdline, cursorpos)
  local types = { "otf", "variable", "frozen" }
  return vim.tbl_filter(function(t)
    return t:match("^" .. vim.pesc(arglead))
  end, types)
end

local function complete_font_families(arglead, cmdline, cursorpos)
  local families = { "all", "neon", "argon", "xenon", "radon", "krypton" }
  -- Handle partial comma-separated input
  local last_comma = arglead:find(",.*$")
  if last_comma then
    local prefix = arglead:sub(1, last_comma)
    local partial = arglead:sub(last_comma + 1)
    local completions = {}
    for _, family in ipairs(families) do
      if family:match("^" .. vim.pesc(partial)) then
        table.insert(completions, prefix .. family)
      end
    end
    return completions
  else
    return vim.tbl_filter(function(f)
      return f:match("^" .. vim.pesc(arglead))
    end, families)
  end
end

-- Font management commands
vim.api.nvim_create_user_command("MonaInstall", function(opts)
  local args = vim.split(opts.args, " ")
  local installer = require("mona.installer")

  -- Use async installation if available
  if installer.install_async then
    installer.install_async({
      font_type = args[1] or "variable",
      families = args[2] and vim.split(args[2], ",") or { "all" },
    }, function(success, message)
      if not success then
        utils.notify_error("Installation failed: " .. message)
      end
    end)
  else
    installer.install({
      font_type = args[1] or "variable",
      families = args[2] and vim.split(args[2], ",") or { "all" },
    })
  end
end, {
  nargs = "*",
  complete = function(arglead, cmdline, cursorpos)
    local parts = vim.split(cmdline:sub(1, cursorpos), " ")
    if #parts == 2 then
      return complete_font_types(arglead, cmdline, cursorpos)
    elseif #parts == 3 then
      return complete_font_families(arglead, cmdline, cursorpos)
    end
  end,
  desc = "Install Monaspace fonts (args: [font_type] [families])",
})

vim.api.nvim_create_user_command("MonaUpdate", function()
  require("mona.installer").update()
end, {
  desc = "Update Monaspace fonts to latest version",
})

vim.api.nvim_create_user_command("MonaUninstall", function(opts)
  local families = opts.args ~= "" and vim.split(opts.args, ",") or nil
  require("mona.installer").uninstall(families)
end, {
  nargs = "?",
  complete = complete_font_families,
  desc = "Uninstall Monaspace fonts (args: [families])",
})

-- Configuration commands
vim.api.nvim_create_user_command("MonaPreview", function()
  require("mona.preview").show()
end, {
  desc = "Preview Monaspace fonts in a floating window",
})

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
  complete = function(arglead, cmdline, cursorpos)
    local parts = vim.split(cmdline:sub(1, cursorpos), " ")
    if #parts == 2 then
      local terminals = { "alacritty", "kitty", "wezterm", "ghostty" }
      return vim.tbl_filter(function(t)
        return t:match("^" .. vim.pesc(arglead))
      end, terminals)
    else
      -- File path completion
      return vim.fn.getcompletion(arglead, "file")
    end
  end,
  desc = "Export terminal configuration for Monaspace fonts",
})

-- Existing command enhancement
vim.api.nvim_create_user_command("MonaLoad", function()
  require("mona.highlights").load()
end, {
  desc = "Load Monaspace font style mappings",
})

vim.api.nvim_create_user_command("MonaStatus", function()
  local installer = require("mona.installer")
  local installation = installer.check_installation()

  print("Monaspace Font Status:")
  for family, installed in pairs(installation) do
    local status = installed and "✓" or "✗"
    print(string.format("  %s %s", status, utils.format_font_family(family)))
  end
end, {
  desc = "Check Monaspace font installation status",
})

-- Health check command
vim.api.nvim_create_user_command("MonaHealth", function()
  require("mona.health").check()
end, {
  desc = "Run health checks for mona.nvim",
})

-- Cache management commands
vim.api.nvim_create_user_command("MonaCacheClear", function()
  require("mona.cache").clear()
  utils.info("Mona cache cleared")
end, {
  desc = "Clear all mona.nvim cache",
})

vim.api.nvim_create_user_command("MonaCacheStats", function()
  local cache = require("mona.cache")
  local stats = cache.stats()
  print("Mona Cache Statistics:")
  print(string.format("  Total entries: %d", stats.total))
  print(string.format("  Active entries: %d", stats.active))
  print(string.format("  Expired entries: %d", stats.expired))
  print(string.format("  Cache file size: %d bytes", stats.file_size))
end, {
  desc = "Show mona.nvim cache statistics",
})

-- Terminal detection command
vim.api.nvim_create_user_command("MonaDetectTerminal", function()
  local terminal_module = require("mona.terminal")
  local detected = terminal_module.detect()
  local capabilities = terminal_module.capabilities(detected)

  print("Terminal Detection:")
  print(string.format("  Detected: %s", detected))
  print(string.format("  Font mixing: %s", capabilities.font_mixing and "✓" or "✗"))
  print(string.format("  Ligatures: %s", capabilities.ligatures and "✓" or "✗"))
  print(string.format("  Variable fonts: %s", capabilities.variable_fonts and "✓" or "✗"))
end, {
  desc = "Detect current terminal and show capabilities",
})

-- Set up key mappings
local function setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- Font preview
  vim.keymap.set("n", "<leader>mf", ":MonaPreview<CR>", opts)

  -- Install fonts
  vim.keymap.set("n", "<leader>mi", ":MonaInstall<CR>", opts)

  -- Check status
  vim.keymap.set("n", "<leader>ms", ":MonaStatus<CR>", opts)

  -- Health check
  vim.keymap.set("n", "<leader>mh", ":MonaHealth<CR>", opts)
end

-- Set up key mappings when plugin loads
setup_keymaps()
