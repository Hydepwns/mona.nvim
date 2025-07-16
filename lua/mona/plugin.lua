-- Plugin specification for lazy.nvim
return {
  "hydepwns/mona.nvim",
  name = "mona",
  lazy = false,
  build = ":MonaInstall variable all",
  opts = {
    -- Default configuration
    use_default = true,
    style_map = {
      bold = {
        Comment = true,
        ["@comment.documentation"] = true,
      },
      italic = {
        ["@markup.link"] = true,
      },
      bold_italic = {
        DiagnosticError = true,
        StatusLine = true,
      },
    },
    
    font_features = {
      texture_healing = true,
      ligatures = {
        enable = true,
        stylistic_sets = {
          equals = true,
          comparison = true,
          arrows = true,
          markup = true,
          fsharp = false,
          repeating = true,
          colons = true,
          dots = true,
          comparison_alt = true,
          tags = true,
        }
      },
      character_variants = {
        zero_style = 2,
        one_serif = false,
        asterisk_height = 0,
        asterisk_style = 0,
        comparison_style = 0,
        force_arrow_style = false,
        closed_brackets = false,
        at_underscore = false,
      }
    },
    
    terminal_config = {
      auto_generate = false,
      terminals = { "alacritty", "kitty", "wezterm", "ghostty" }
    },
    
    preview = {
      sample_text = [[
// Texture healing example: mi, il, rn
function example() {
  const result = items.filter(item => item !== null);
  return result || [];
}
/* Documentation looks better in slab serif */
-- TODO: Handwritten style for comments
]],
      window_opts = {
        width = 80,
        height = 20,
        border = "rounded"
      }
    }
  },
  
  config = function(_, opts)
    require("mona").setup(opts)
  end,
  
  keys = {
    { "<leader>mf", "<cmd>MonaPreview<cr>", desc = "Mona Font Preview" },
    { "<leader>mi", "<cmd>MonaInstall<cr>", desc = "Mona Install Fonts" },
    { "<leader>ms", "<cmd>MonaStatus<cr>", desc = "Mona Status" },
    { "<leader>mh", "<cmd>MonaHealth<cr>", desc = "Mona Health Check" },
  },
  
  cmd = {
    "MonaInstall",
    "MonaUpdate", 
    "MonaUninstall",
    "MonaPreview",
    "MonaExportConfig",
    "MonaLoad",
    "MonaStatus",
    "MonaHealth",
  },
} 