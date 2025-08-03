local M = {}

-- Public API
M.setup = function(opts)
  local config = require("mona.config")
  config.setup(opts)
end

M.install = function(opts)
  local installer = require("mona.installer")
  installer.install(opts)
end

M.update = function()
  local installer = require("mona.installer")
  installer.update()
end

M.uninstall = function(families)
  local installer = require("mona.installer")
  installer.uninstall(families)
end

M.check_installation = function()
  local installer = require("mona.installer")
  return installer.check_installation()
end

M.generate_config = function(terminal, font_map)
  local terminal_module = require("mona.terminal")
  return terminal_module.generate(terminal, font_map)
end

M.export_config = function(terminal, filepath)
  local terminal_module = require("mona.terminal")
  return terminal_module.export(terminal, filepath)
end

M.preview = function()
  local preview = require("mona.preview")
  preview.show()
end

M.health_check = function()
  local health = require("mona.health")
  health.check()
end

return M
