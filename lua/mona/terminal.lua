local M = {}
local utils = require("mona.utils")

M.configs = {
  alacritty = function(font_map)
    return string.format([[
[font]
normal = { family = "Monaspace %s" }
bold = { family = "Monaspace %s" }
italic = { family = "Monaspace %s" }
bold_italic = { family = "Monaspace %s" }
]], font_map.normal, font_map.bold, font_map.italic, font_map.bold_italic)
  end,
  
  kitty = function(font_map)
    return string.format([[
font_family      Monaspace %s Var
bold_font        Monaspace %s Var
italic_font      Monaspace %s Var
bold_italic_font Monaspace %s Var
]], font_map.normal, font_map.bold, font_map.italic, font_map.bold_italic)
  end,
  
  wezterm = function(font_map)
    return string.format([[
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
]], font_map.normal, font_map.bold, font_map.italic, font_map.bold_italic)
  end,
  
  ghostty = function(font_map)
    return string.format([[
font-family = "Monaspace %s"
font-family-bold = "Monaspace %s"
font-family-italic = "Monaspace %s"
font-family-bold-italic = "Monaspace %s"
]], font_map.normal, font_map.bold, font_map.italic, font_map.bold_italic)
  end
}

M.generate = function(terminal, font_map)
  font_map = font_map or {
    normal = "Neon",
    bold = "Xenon",
    italic = "Radon",
    bold_italic = "Krypton"
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
    ghostty = home .. "/.config/ghostty/config"
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