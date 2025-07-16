# mona.nvim

[![CI](https://github.com/hydepwns/mona.nvim/workflows/CI/badge.svg)](https://github.com/hydepwns/mona.nvim/actions)

Enhanced monospaced font management and configuration for Neovim.

>Monaspace is a next-generation font family from GitHub Next, designed for code: ligatures, texture healing, and beautiful style mixing. [Learn more](https://github.com/githubnext/monaspace)

**💡 tldr; Want to see the fonts side by side?** Visit [monaspace.githubnext.com](https://monaspace.githubnext.com/) for an interactive font preview!

## Features

- **Automated Font Installation**: Install Monaspace fonts directly from Neovim
- **Font Feature Configuration**: Control texture healing, ligatures, and character variants
- **Terminal Configuration Generator**: Generate configs for Alacritty, Kitty, WezTerm, and Ghostty
- **Font Preview System**: Preview different font combinations
- **Health Check System**: Diagnose installation and configuration issues
- **Cross-platform Support**: Works on macOS, Linux, and Windows

## Installation

### Using lazy.nvim

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

### Using packer

```lua
use {
  "hydepwns/mona.nvim",
  run = ":MonaInstall variable all",
  config = function()
    require("mona").setup({ -- Your configuration here })
  end
}
```

## Quick Start

1. **Install plugin** using your preferred package manager
2. **Install fonts**: `:MonaInstall variable all`
3. **Check status**: `:MonaStatus`
4. **Preview fonts**: `:MonaPreview`
5. **Generate config**: `:MonaExportConfig alacritty ~/.config/alacritty/fonts.toml`

## Commands

### Font Management

- `:MonaInstall [type] [families]` - Install fonts (`type`: otf/variable/frozen, `families`: all or neon,argon,xenon)
- `:MonaUpdate` - Update fonts to latest version
- `:MonaUninstall [families]` - Remove fonts
- `:MonaStatus` - Show installation status

### Configuration

- `:MonaPreview` - Show font preview window
- `:MonaExportConfig <terminal> [filepath]` - Generate terminal config (alacritty/kitty/wezterm/ghostty)
- `:MonaLoad` - Load default font style mappings
- `:MonaHealth` - Run health check diagnostics

## Key Mappings

- `<leader>mf` - Open font preview (`:MonaPreview`)
- `<leader>mi` - Install fonts (`:MonaInstall`)
- `<leader>ms` - Show status (`:MonaStatus`)
- `<leader>mh` - Health check (`:MonaHealth`)

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

## Font Families

- **Neon** - Monospace (default)
- **Argon** - Monospace with rounded corners
- **Xenon** - Slab serif
- **Radon** - Handwritten style
- **Krypton** - Display style

**🎨 See all fonts in action:** [monaspace.githubnext.com](https://monaspace.githubnext.com/)

## CI/CD

This project uses GitHub Actions for continuous integration:

- **Multi-version testing**: Lua 5.1-5.4 and Neovim 0.9.0, 0.10.0, nightly
- **Linting**: Automated code quality checks with luacheck
- **Automated releases**: Tag-based releases with changelog generation

## Testing

```bash
# Quick Validation
lua validate.lua

# Optional entrypoints
# Unit tests
lua test/test_config.lua
lua test/test_utils.lua
lua test/test_highlights.lua
# Integration tests
nvim --headless -u test/minimal_init.lua -c "lua require('plenary.busted').run('test/plugin')"
# Run all tests
make test
# Individual test types
make test-unit          # Unit tests only
make test-integration   # Integration tests only
make validate           # Validation script

make clean              # Clean test artifacts
```

## Troubleshooting

### Health Check

Run `:MonaHealth` or `lua validate.lua` to diagnose:

- Font installation status
- Terminal compatibility
- Required tools availability
- Configuration validation

### Common Issues

1. **Fonts not showing**: Run `:MonaInstall`
2. **Terminal not supported**: Check `:MonaHealth`
3. **Font features not working**: Ensure GUI Neovim for full support

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Monaspace](https://github.com/githubnext/monaspace) - The beautiful font family
- [monaspace.nvim](https://github.com/jackplus-xyz/monaspace.nvim) - Original font mixing plugin
