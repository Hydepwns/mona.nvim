# Changelog

All notable changes to mona.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2025-08-03

### Added

- Font cache management system for improved performance
- Async font installation with progress reporting
- Command completion for all commands
- Terminal detection with capabilities mapping
- Retry logic for network operations with exponential backoff
- New commands: `MonaCacheClear`, `MonaCacheStats`, `MonaDetectTerminal`
- Non-throwing error notification function (`notify_error`)

### Changed

- JSON parsing now uses `vim.fn.json_decode()` instead of regex parsing
- Font file matching now supports `.ttf`, `.otf`, and `.woff2` formats
- Error handling is now consistent throughout the codebase
- Safe file operations now have optional critical parameter

### Fixed

- JSON parsing vulnerability in GitHub API responses
- Incomplete font format support
- Inconsistent error handling behavior
- Test environment compatibility issues

### Removed

- Misplaced `lua/mona/plugin.lua` file (was example configuration)

## [0.1.2] - 2025-07-16

### Fixed

- Fixed Codecov coverage reporting issues by converting luacov format to lcov format
- Improved CI reliability with better error handling and debugging
- Resolved "Unusable report" errors in Codecov uploads

## [0.1.4] - 2025-01-27

### Added

- Automated releases via GitHub Actions
- Dependabot integration for dependency updates

## [Unreleased]

### Added

- Automated releases via GitHub Actions
- Dependabot integration for dependency updates

## [0.1.1] - 2025-07-16

### Added

- LuaRocks rockspec (`mona-scm-1.rockspec`) for easy installation and distribution.

### Fixed

- CI workflow now uses the bundled `plenary.nvim` instead of installing via luarocks, ensuring consistent test results between local and CI environments.
- Fixed GitHub Actions CI failures by adding Lua development headers (`lua*-dev` packages)
- Added debug output and fallback handling for luarocks installation issues
- Resolved "Failed finding Lua header files" error in CI pipeline

## [0.1.0] - 2025-07-16

### Added

- Initial release of mona.nvim
- Font installation and management commands (`:MonaInstall`, `:MonaUpdate`, `:MonaUninstall`)
- Font feature configuration (texture healing, ligatures, character variants)
- Terminal configuration generator for Alacritty, Kitty, WezTerm, and Ghostty
- Font preview system (`:MonaPreview`)
- Health check diagnostics (`:MonaHealth`)
- Cross-platform support (macOS, Linux, Windows)
- Key mappings for common operations (`<leader>mf`, `<leader>mi`, `<leader>ms`, `<leader>mh`)
- Style mapping for font mixing (Neon, Argon, Xenon, Radon, Krypton)
- Comprehensive test suite with ~80% coverage
- Integration tests using plenary.nvim
- Validation script for plugin structure
- GitHub Actions CI/CD pipeline
- Codecov integration for coverage reporting
- Multi-version testing (Lua 5.1-5.4, Neovim 0.9.0-0.10.0, nightly)
- Automated linting with luacheck
- Development scripts for local testing
- Makefile for build automation

### Changed

- Improved error handling and validation across all modules
- Standardized code style and patterns
- Enhanced README with comprehensive documentation and examples
- Added hyperlink to original Monaspace repository
- Organized project structure for better maintainability

### Fixed

- Circular dependencies in module loading
- Inconsistent error handling patterns
- Configuration validation issues
- Test environment setup and execution
- Package path resolution in test files
