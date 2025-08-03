# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development & Testing
```bash
# Run all tests (unit + integration + validation)
make test

# Run specific test types
make test-unit          # Unit tests only
make test-integration   # Integration tests only
make validate           # Validation script

# Linting
make lint               # Run luacheck

# Individual unit tests
lua test/test_config.lua
lua test/test_utils.lua
lua test/test_highlights.lua
lua test/test_preview.lua
lua test/test_health.lua
lua test/test_terminal.lua
lua test/test_installer.lua
lua test/test_init.lua
```

### LuaRocks Distribution
```bash
# Install locally
luarocks install mona.nvim

# Build rockspec
luarocks make mona.nvim-0.1.3-1.rockspec
```

## Architecture

### Module Organization
The plugin follows a modular architecture with clear separation:

- **lua/mona/init.lua** - Main API entry point, exposes public functions
- **lua/mona/config.lua** - Configuration management with comprehensive validation
- **lua/mona/utils.lua** - Cross-platform utilities and OS detection
- **plugin/mona.lua** - Neovim command definitions

### Feature Modules
- **installer.lua** - Font download/installation from GitHub releases
- **terminal.lua** - Terminal config generation (Alacritty, Kitty, WezTerm, Ghostty)
- **preview.lua** - Floating window font preview system
- **highlights.lua** - Font style mixing with highlight groups
- **health.lua** - Neovim health check integration

### Key Patterns

**Module Structure**: All modules use `local M = {}` pattern with explicit exports.

**Configuration Validation**: Uses deep validation with type checking in config.lua. Always validate user input before use.

**Cross-platform Support**: Use `utils.get_os()` and `utils.get_font_path()` for OS-specific logic. Never hardcode paths.

**Error Handling**: Use consistent `[mona.nvim]` prefix for all error messages.

**Font Features**: Complex feature configuration (ligatures, texture healing, character variants) mapped to OpenType features.

### Testing Strategy
- **Unit Tests**: Each module has corresponding test_*.lua file
- **Test Framework**: Uses bundled Plenary.nvim in test/plenary.nvim/
- **Coverage**: luacov integration with lcov conversion support
- **Validation**: Standalone validate.lua checks structure integrity

### Monaspace Font Families
- **Neon**: Default monospace
- **Argon**: Rounded monospace
- **Xenon**: Slab serif (used for bold)
- **Radon**: Handwritten (used for italic)
- **Krypton**: Display (used for bold italic)

### Terminal Config Generation
Each terminal has specific font family name mappings:
- Alacritty: "Monaspace Neon"
- Kitty: "MonaspaceNeon"
- WezTerm: "Monaspace Neon"
- Ghostty: "Monaspace Neon"