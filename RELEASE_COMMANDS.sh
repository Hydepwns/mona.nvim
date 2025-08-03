#!/bin/bash
# Commands to release mona.nvim v0.1.3

# 1. Add all changes
git add .

# 2. Commit with detailed message
git commit -m "chore: release v0.1.3

- Add font cache management system for improved performance
- Implement async font installation with progress reporting
- Add command completion for all commands
- Add terminal detection with capabilities mapping
- Add retry logic for network operations
- Fix JSON parsing vulnerability
- Support .ttf, .otf, and .woff2 formats
- Add new commands: MonaCacheClear, MonaCacheStats, MonaDetectTerminal
- Improve error handling consistency
- Update documentation with new features"

# 3. Create annotated tag
git tag -a v0.1.3 -m "Release version 0.1.3

Major improvements:
- Cache management system
- Async operations
- Enhanced terminal detection
- Retry logic with exponential backoff
- Better error handling

See CHANGELOG.md for full details."

# 4. Push to GitHub
git push origin main --tags

# 5. After GitHub release is created, upload to LuaRocks
echo "After creating GitHub release, run:"
echo "luarocks upload mona.nvim-0.1.3-1.rockspec"