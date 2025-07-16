package = "mona.nvim"
version = "0.1.2-1"
rockspec_format = "3.0"

source = {
  url = "git+https://github.com/hydepwns/mona.nvim",
  tag = "v0.1.2"
}

description = {
  summary = "Enhanced monospaced font management and configuration for Neovim.",
  detailed = [[
Monaspace font management and configuration for Neovim. Features automated font installation, font feature configuration, terminal config generation, font preview, health checks, and cross-platform support (macOS, Linux, Windows).
  ]],
  homepage = "https://github.com/hydepwns/mona.nvim",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["mona"] = "lua/mona/init.lua",
    ["mona.config"] = "lua/mona/config.lua",
    ["mona.installer"] = "lua/mona/installer.lua",
    ["mona.terminal"] = "lua/mona/terminal.lua",
    ["mona.preview"] = "lua/mona/preview.lua",
    ["mona.health"] = "lua/mona/health.lua",
    ["mona.highlights"] = "lua/mona/highlights.lua",
    ["mona.utils"] = "lua/mona/utils.lua",
    ["mona.plugin"] = "lua/mona/plugin.lua",
    ["plugin.mona"] = "plugin/mona.lua"
  }
} 