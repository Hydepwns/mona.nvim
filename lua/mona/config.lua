local M = {}
local utils = require("mona.utils")

M.defaults = {
  -- Font mixing configuration (existing feature)
  use_default = true,
  style_map = {
    bold = {},
    italic = {},
    bold_italic = {},
  },
  
  -- New configuration options
  font_features = {
    texture_healing = true,    -- calt
    ligatures = {
      enable = true,          -- liga
      stylistic_sets = {      -- ss01-ss10
        equals = true,        -- ss01
        comparison = true,    -- ss02
        arrows = true,        -- ss03
        markup = true,        -- ss04
        fsharp = false,       -- ss05
        repeating = true,     -- ss06
        colons = true,        -- ss07
        dots = true,          -- ss08
        comparison_alt = true,-- ss09
        tags = true,          -- ss10
      }
    },
    character_variants = {
      zero_style = 2,         -- cv01: 1=plain, 2=slash, 3=reverse slash, 4=cutout
      one_serif = false,      -- cv02
      asterisk_height = 0,    -- cv30: 0=default, 1=top aligned
      asterisk_style = 0,     -- cv31: 0=default, 1=six-pointed
      comparison_style = 0,   -- cv32: 0=default, 1=angled
      force_arrow_style = false, -- cv60
      closed_brackets = false,   -- cv61
      at_underscore = false,     -- cv62
    }
  },
  
  -- Terminal configuration export
  terminal_config = {
    auto_generate = false,
    terminals = { "alacritty", "kitty", "wezterm", "ghostty" }
  },
  
  -- Font preview settings
  preview = {
    sample_text = [[
// Texture healing example: mi, il, rn
function example() {
  const result = items.filter(item => item !== null);
  return result || [];
}
/* Documentation looks better in slab serif */
-- Comments can use handwritten style (Radon) for better readability
]],
    window_opts = {
      width = 80,
      height = 20,
      border = "rounded"
    }
  }
}

M.config = M.defaults

-- Validate configuration structure
M.validate_config = function(config)
  -- Validate top-level options
  utils.validate_boolean(config.use_default, "use_default")
  utils.validate_table(config.style_map, "style_map")
  utils.validate_table(config.font_features, "font_features")
  utils.validate_table(config.terminal_config, "terminal_config")
  utils.validate_table(config.preview, "preview")
  
  -- Validate font_features
  local ff = config.font_features
  utils.validate_boolean(ff.texture_healing, "font_features.texture_healing")
  utils.validate_table(ff.ligatures, "font_features.ligatures")
  utils.validate_table(ff.character_variants, "font_features.character_variants")
  
  -- Validate ligatures
  utils.validate_boolean(ff.ligatures.enable, "font_features.ligatures.enable")
  utils.validate_table(ff.ligatures.stylistic_sets, "font_features.ligatures.stylistic_sets")
  
  -- Validate character variants
  utils.validate_number(ff.character_variants.zero_style, "font_features.character_variants.zero_style", 1, 4)
  utils.validate_boolean(ff.character_variants.one_serif, "font_features.character_variants.one_serif")
  utils.validate_number(ff.character_variants.asterisk_height, "font_features.character_variants.asterisk_height", 0, 1)
  utils.validate_number(ff.character_variants.asterisk_style, "font_features.character_variants.asterisk_style", 0, 1)
  utils.validate_number(ff.character_variants.comparison_style, "font_features.character_variants.comparison_style", 0, 1)
  utils.validate_boolean(ff.character_variants.force_arrow_style, "font_features.character_variants.force_arrow_style")
  utils.validate_boolean(ff.character_variants.closed_brackets, "font_features.character_variants.closed_brackets")
  utils.validate_boolean(ff.character_variants.at_underscore, "font_features.character_variants.at_underscore")
  
  -- Validate terminal_config
  utils.validate_boolean(config.terminal_config.auto_generate, "terminal_config.auto_generate")
  utils.validate_table(config.terminal_config.terminals, "terminal_config.terminals")
  
  -- Validate preview
  utils.validate_string(config.preview.sample_text, "preview.sample_text")
  utils.validate_table(config.preview.window_opts, "preview.window_opts")
  utils.validate_number(config.preview.window_opts.width, "preview.window_opts.width", 1)
  utils.validate_number(config.preview.window_opts.height, "preview.window_opts.height", 1)
  utils.validate_string(config.preview.window_opts.border, "preview.window_opts.border")
end

M.setup = function(opts)
  local config = vim.tbl_deep_extend("force", M.defaults, opts or {})
  
  -- Validate configuration
  M.validate_config(config)
  
  M.config = config
  
  -- Apply font feature configuration for GUI Neovim
  if utils.is_gui() then
    M.apply_gui_features()
  end
  
  -- Apply style mappings (existing functionality)
  M.apply_style_mappings()
end

-- Separate function to avoid circular dependency
M.apply_style_mappings = function()
  local highlights = require("mona.highlights")
  highlights.apply_styles(M.config.style_map)
end

M.apply_gui_features = function()
  local features = {}
  local cfg = M.config.font_features
  
  if cfg.texture_healing then
    table.insert(features, "calt")
  end
  
  if cfg.ligatures.enable then
    table.insert(features, "liga")
    for set, enabled in pairs(cfg.ligatures.stylistic_sets) do
      if enabled then
        local ss_map = {
          equals = "ss01", comparison = "ss02", arrows = "ss03",
          markup = "ss04", fsharp = "ss05", repeating = "ss06",
          colons = "ss07", dots = "ss08", comparison_alt = "ss09",
          tags = "ss10"
        }
        table.insert(features, ss_map[set])
      end
    end
  end
  
  -- Apply character variants
  for variant, value in pairs(cfg.character_variants) do
    if value > 0 then
      local cv_map = {
        zero_style = "cv01", one_serif = "cv02",
        asterisk_height = "cv30", asterisk_style = "cv31",
        comparison_style = "cv32", force_arrow_style = "cv60",
        closed_brackets = "cv61", at_underscore = "cv62"
      }
      table.insert(features, string.format("%s %d", cv_map[variant], value))
    end
  end
  
  -- Set GUI font with features
  if #features > 0 then
    vim.o.guifont = vim.o.guifont .. ":h12:" .. table.concat(features, ",")
  end
end

return M 