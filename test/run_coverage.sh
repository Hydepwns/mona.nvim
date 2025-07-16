#!/bin/bash

# Coverage runner script for mona.nvim
set -e

echo "Setting up environment..."
eval "$(luarocks path --bin)"

echo "Setting up package path..."
export LUA_PATH="lua/?.lua;lua/?/init.lua;;"

echo "Running tests with coverage..."
lua -lluacov test/test_config.lua
lua -lluacov test/test_utils.lua
lua -lluacov test/test_highlights.lua
lua -lluacov test/test_preview.lua
lua -lluacov test/test_health.lua
lua -lluacov test/test_terminal.lua
lua -lluacov test/test_installer.lua
lua -lluacov test/test_init.lua

echo "Generating coverage report..."
luacov

echo "Coverage report generated: luacov.report.out"
ls -la *.out 