# mona.nvim

[![CI](https://github.com/hydepwns/mona.nvim/workflows/CI/badge.svg)](https://github.com/hydepwns/mona.nvim/actions)
[![LuaRocks](https://img.shields.io/luarocks/v/hydepwns/mona.nvim?color=blue)](https://luarocks.org/modules/hydepwns/mona.nvim)

Enhanced Monaspace font management for Neovim with automated installation, preview, and terminal config generation.

> Monaspace is a next-generation font family from GitHub Next, designed for code with ligatures, texture healing, and beautiful style mixing.
> [Learn more](https://github.com/githubnext/monaspace)

**💡 Preview fonts:** [monaspace.githubnext.com](https://monaspace.githubnext.com/)  
**📦 Install:** `luarocks install mona.nvim`

## Quick Start

```bash
# Install plugin
luarocks install mona.nvim

# In Neovim
:MonaInstall variable all  # Install fonts
:MonaPreview              # Preview fonts
:MonaStatus               # Check status
```

## Features

- **Automated Font Installation** - Install Monaspace fonts directly from Neovim
- **Async Operations** - Non-blocking font installation with progress reporting
- **Font Preview System** - Preview different font combinations side-by-side
- **Terminal Config Generator** - Generate configs for Alacritty, Kitty, WezTerm, Ghostty
- **Terminal Detection** - Automatically detect terminal capabilities
- **Font Feature Control** - Texture healing, ligatures, character variants
- **Cache Management** - Fast operations with persistent caching
- **Health Check System** - Diagnose installation and configuration issues
- **Smart Retry Logic** - Automatic retry with exponential backoff for network operations
- **Cross-platform** - macOS, Linux, Windows

## Installation

### LuaRocks

```bash
luarocks install mona.nvim
```

### lazy.nvim

```lua
{
  "hydepwns/mona.nvim",
  lazy = false,
  build = ":MonaInstall variable all",
  opts = {
    style_map = {
      bold = { Comment = true, ["@comment.documentation"] = true },
      italic = { ["@markup.link"] = true },
      bold_italic = { DiagnosticError = true, StatusLine = true },
    },
    font_features = {
      texture_healing = true,
      ligatures = { enable = true, stylistic_sets = { equals = true, arrows = true } },
      character_variants = { zero_style = 2 }
    },
    terminal_config = { auto_generate = true, terminals = { "alacritty" } }
  }
}
```

### packer

```lua
use {
  "hydepwns/mona.nvim",
  run = ":MonaInstall variable all",
  config = function()
    require("mona").setup({ -- Your configuration here })
  end
}
```

## Commands

| Command | Description |
|---------|-------------|
| `:MonaInstall [type] [families]` | Install fonts (`type`: otf/variable/frozen, `families`: all or neon,argon,xenon) |
| `:MonaUpdate` | Update fonts to latest version |
| `:MonaUninstall [families]` | Remove fonts |
| `:MonaStatus` | Show installation status |
| `:MonaPreview` | Show font preview window |
| `:MonaExportConfig <terminal> [filepath]` | Generate terminal config (alacritty/kitty/wezterm/ghostty) |
| `:MonaLoad` | Load default font style mappings |
| `:MonaHealth` | Run health check diagnostics |
| `:MonaCacheClear` | Clear font cache |
| `:MonaCacheStats` | Show cache statistics |
| `:MonaDetectTerminal` | Detect current terminal and show capabilities |

## Key Mappings

- `<leader>mf` - Font preview (`:MonaPreview`)
- `<leader>mi` - Install fonts (`:MonaInstall`)
- `<leader>ms` - Show status (`:MonaStatus`)
- `<leader>mh` - Health check (`:MonaHealth`)

## Configuration

### Font Features

```lua
require("mona").setup({
  font_features = {
    texture_healing = true,    -- Enable texture healing (calt)
    ligatures = {
      enable = true,          -- Enable ligatures (liga)
      stylistic_sets = {      -- Stylistic sets (ss01-ss10)
        equals = true,        -- ss01: == ligatures
        comparison = true,    -- ss02: !=, <=, >= ligatures
        arrows = true,        -- ss03: ->, <- ligatures
        markup = true,        -- ss04: </> ligatures
        fsharp = false,       -- ss05: F# style ligatures
        repeating = true,     -- ss06: Repeating characters
        colons = true,        -- ss07: :: ligatures
        dots = true,          -- ss08: ... ligatures
        comparison_alt = true,-- ss09: Alternative comparisons
        tags = true,          -- ss10: Tag ligatures
      }
    },
    character_variants = {
      zero_style = 2,         -- cv01: 0 style (1=plain, 2=slash, 3=reverse slash, 4=cutout)
      one_serif = false,      -- cv02: 1 with serif
      asterisk_height = 0,    -- cv30: Asterisk height (0=default, 1=top aligned)
      asterisk_style = 0,     -- cv31: Asterisk style (0=default, 1=six-pointed)
      comparison_style = 0,   -- cv32: Comparison style (0=default, 1=angled)
      force_arrow_style = false, -- cv60: Force arrow style
      closed_brackets = false,   -- cv61: Closed bracket style
      at_underscore = false,     -- cv62: @ with underscore
    }
  }
})
```

### Style Mapping

```lua
require("mona").setup({
  style_map = {
    bold = { -- Uses Xenon (slab serif)
      Comment = true,
      ["@comment.documentation"] = true,
      ["@text.literal"] = true,
    },
    italic = { -- Uses Radon (handwritten)
      ["@markup.link"] = true,
      ["@text.uri"] = true,
      Todo = true,
    },
    bold_italic = { -- Uses Krypton (display)
      DiagnosticError = true,
      StatusLine = true,
      ["@text.title"] = true,
    },
  }
})
```

### Terminal Configuration

```lua
require("mona").setup({
  terminal_config = {
    auto_generate = true,
    terminals = { "alacritty", "kitty", "wezterm", "ghostty" }
  }
})
```

## Advanced Features

### Async Installation

Font installation runs asynchronously without blocking Neovim:

```lua
-- The installation happens in the background
:MonaInstall variable all
```

### Cache Management

The plugin caches font information for faster operations:

```bash
:MonaCacheStats    # View cache statistics
:MonaCacheClear    # Clear all cached data
```

### Terminal Detection

Automatically detect your terminal and its capabilities:

```bash
:MonaDetectTerminal
# Output:
# Terminal Detection:
#   Detected: alacritty
#   Font mixing: ✓
#   Ligatures: ✓
#   Variable fonts: ✓
```

## Font Families

| Family | Style | Use Case |
|--------|-------|----------|
| **Neon** | Monospace | Default coding |
| **Argon** | Monospace (rounded) | Softer appearance |
| **Xenon** | Slab serif | Bold emphasis |
| **Radon** | Handwritten | Italic emphasis |
| **Krypton** | Display | Headers/titles |

## Troubleshooting

### Health Check

Run `:MonaHealth` or `lua validate.lua` to diagnose:

- Font installation status
- Terminal compatibility  
- Required tools availability
- Configuration validation

### Common Issues

1. **Fonts not showing** → Run `:MonaInstall`
2. **Terminal not supported** → Check `:MonaHealth`
3. **Font features not working** → Ensure GUI Neovim

## Development

```bash
# Quick validation
lua validate.lua

# Run tests
make test

# Individual test types
make test-unit          # Unit tests
make test-integration   # Integration tests
make validate           # Validation script
make clean              # Clean artifacts
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Monaspace](https://github.com/githubnext/monaspace) - The beautiful font family
- [monaspace.nvim](https://github.com/jackplus-xyz/monaspace.nvim) - Original font mixing plugin
