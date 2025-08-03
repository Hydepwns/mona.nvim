local M = {}
local utils = require("mona.utils")
local cache = require("mona.cache")

M.configs = {
  alacritty = function(font_map)
    return string.format(
      [[
[font]
normal = { family = "Monaspace %s" }
bold = { family = "Monaspace %s" }
italic = { family = "Monaspace %s" }
bold_italic = { family = "Monaspace %s" }
]],
      font_map.normal,
      font_map.bold,
      font_map.italic,
      font_map.bold_italic
    )
  end,

  kitty = function(font_map)
    return string.format(
      [[
font_family      Monaspace %s Var
bold_font        Monaspace %s Var
italic_font      Monaspace %s Var
bold_italic_font Monaspace %s Var
]],
      font_map.normal,
      font_map.bold,
      font_map.italic,
      font_map.bold_italic
    )
  end,

  wezterm = function(font_map)
    return string.format(
      [[
return {
  font = wezterm.font_with_fallback({
    { family = "Monaspace %s" },
  }),
  font_rules = {
    {
      intensity = "Bold",
      font = wezterm.font("Monaspace %s"),
    },
    {
      italic = true,
      font = wezterm.font("Monaspace %s", { style = "Italic" }),
    },
    {
      intensity = "Bold",
      italic = true,
      font = wezterm.font("Monaspace %s"),
    },
  },
}
]],
      font_map.normal,
      font_map.bold,
      font_map.italic,
      font_map.bold_italic
    )
  end,

  ghostty = function(font_map)
    return string.format(
      [[
font-family = "Monaspace %s"
font-family-bold = "Monaspace %s"
font-family-italic = "Monaspace %s"
font-family-bold-italic = "Monaspace %s"
]],
      font_map.normal,
      font_map.bold,
      font_map.italic,
      font_map.bold_italic
    )
  end,
}

M.generate = function(terminal, font_map)
  font_map = font_map
    or {
      normal = "Neon",
      bold = "Xenon",
      italic = "Radon",
      bold_italic = "Krypton",
    }

  if M.configs[terminal] then
    return M.configs[terminal](font_map)
  else
    utils.error(string.format("Unsupported terminal: %s", terminal))
  end
end

M.export = function(terminal, filepath)
  local config = M.generate(terminal)
  if filepath then
    utils.safe_write_file(vim.fn.expand(filepath), config)
  else
    return config
  end
end

-- Get default config file paths for terminals
M.get_default_paths = function()
  local home = vim.env.HOME or vim.env.USERPROFILE
  return {
    alacritty = home .. "/.config/alacritty/alacritty.toml",
    kitty = home .. "/.config/kitty/kitty.conf",
    wezterm = home .. "/.config/wezterm/wezterm.lua",
    ghostty = home .. "/.config/ghostty/config",
  }
end

-- Detect current terminal
M.detect = function(use_cache)
  use_cache = use_cache ~= false -- default to using cache

  -- Try to get from cache first
  if use_cache then
    local cached_terminal = cache.get(cache.keys.terminal_type())
    if cached_terminal then
      return cached_terminal
    end
  end

  local terminal_checks = {
    -- Check environment variables first
    { env = "TERM_PROGRAM", value = "ghostty", name = "ghostty" },
    { env = "TERM_PROGRAM", value = "WezTerm", name = "wezterm" },
    { env = "TERM_PROGRAM", value = "iTerm.app", name = "iterm2" },
    { env = "TERM_PROGRAM", value = "vscode", name = "vscode" },
    { env = "KITTY_WINDOW_ID", value = nil, name = "kitty" },
    { env = "ALACRITTY_SOCKET", value = nil, name = "alacritty" },
    { env = "VTE_VERSION", value = nil, name = "gnome-terminal" },
    { env = "KONSOLE_VERSION", value = nil, name = "konsole" },
    { env = "XTERM_VERSION", value = nil, name = "xterm" },
    { env = "TMUX", value = nil, name = "tmux" },
  }

  -- Check environment variables
  for _, check in ipairs(terminal_checks) do
    local env_value = vim.env[check.env]
    if env_value then
      if not check.value or env_value:match(check.value) then
        -- Cache the detected terminal
        cache.set(cache.keys.terminal_type(), check.name, 1800) -- 30 minute TTL
        return check.name
      end
    end
  end

  -- Fallback to process detection on Unix-like systems
  if utils.get_os() ~= "Windows" then
    local ppid = vim.fn.getpid()
    local ps_cmd = string.format("ps -p %d -o ppid=", ppid)
    local parent_pid = vim.fn.system(ps_cmd):gsub("%s+", "")

    if parent_pid ~= "" then
      local parent_cmd = string.format("ps -p %s -o comm=", parent_pid)
      local parent_process = vim.fn.system(parent_cmd):gsub("%s+", ""):lower()

      -- Map process names to terminal types
      local process_map = {
        alacritty = "alacritty",
        kitty = "kitty",
        wezterm = "wezterm",
        ["wezterm-gui"] = "wezterm",
        ghostty = "ghostty",
        iterm2 = "iterm2",
        ["gnome-terminal"] = "gnome-terminal",
        konsole = "konsole",
        xterm = "xterm",
      }

      for process, terminal in pairs(process_map) do
        if parent_process:match(process) then
          -- Cache the detected terminal
          cache.set(cache.keys.terminal_type(), terminal, 1800) -- 30 minute TTL
          return terminal
        end
      end
    end
  end

  -- Cache unknown result
  cache.set(cache.keys.terminal_type(), "unknown", 300) -- 5 minute TTL
  return "unknown"
end

-- Get terminal capabilities
M.capabilities = function(terminal)
  terminal = terminal or M.detect()

  local capabilities_map = {
    alacritty = { font_mixing = true, ligatures = true, variable_fonts = true },
    kitty = { font_mixing = true, ligatures = true, variable_fonts = true },
    wezterm = { font_mixing = true, ligatures = true, variable_fonts = true },
    ghostty = { font_mixing = true, ligatures = true, variable_fonts = true },
    iterm2 = { font_mixing = true, ligatures = true, variable_fonts = true },
    ["gnome-terminal"] = { font_mixing = false, ligatures = false, variable_fonts = false },
    konsole = { font_mixing = false, ligatures = true, variable_fonts = false },
    xterm = { font_mixing = false, ligatures = false, variable_fonts = false },
    vscode = { font_mixing = false, ligatures = true, variable_fonts = true },
    tmux = { font_mixing = false, ligatures = false, variable_fonts = false },
  }

  return capabilities_map[terminal]
    or {
      font_mixing = false,
      ligatures = false,
      variable_fonts = false,
    }
end

-- Auto-generate configs for configured terminals
M.auto_generate = function()
  local config = require("mona.config").config
  if not config.terminal_config.auto_generate then
    return
  end

  local paths = M.get_default_paths()

  for _, terminal in ipairs(config.terminal_config.terminals) do
    local path = paths[terminal]
    if path then
      M.export(terminal, path)
      utils.info(string.format("Generated config for %s at %s", terminal, path))
    end
  end
end

return M
