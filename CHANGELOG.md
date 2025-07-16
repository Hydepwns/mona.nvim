# Changelog

All notable changes to mona.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Automated releases via GitHub Actions
- Dependabot integration for dependency updates

## [0.1.1] - 2024-06-13

### Added
- LuaRocks rockspec (`mona-scm-1.rockspec`) for easy installation and distribution.

### Fixed
- CI workflow now uses the bundled `plenary.nvim` instead of installing via luarocks, ensuring consistent test results between local and CI environments.

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
