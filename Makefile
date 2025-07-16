.PHONY: test test-unit test-integration validate clean coverage help

# Default target
help:
	@echo "Available commands:"
	@echo "  test          - Run all tests"
	@echo "  test-unit     - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  validate      - Run validation script"
	@echo "  coverage      - Run tests with coverage report"
	@echo "  clean         - Clean up test artifacts"

# Run all tests
test: test-unit test-integration validate

# Run unit tests
test-unit:
	@echo "Running unit tests..."
	@lua test/test_config.lua
	@lua test/test_utils.lua
	@lua test/test_highlights.lua
	@lua test/test_preview.lua
	@lua test/test_health.lua
	@lua test/test_terminal.lua
	@lua test/test_installer.lua
	@lua test/test_init.lua
	@echo "✓ All unit tests passed"

# Run integration tests
test-integration:
	@echo "Running integration tests..."
	@nvim --headless -u test/minimal_init.lua -c "lua require('plenary.busted').run('test/plugin/integration_spec.lua')"
	@echo "✓ Integration tests completed"

# Run validation
validate:
	@echo "Running validation..."
	@lua validate.lua
	@echo "✓ Validation completed"

# Run tests with coverage
coverage:
	@echo "Running tests with coverage..."
	@lua -lluacov test/test_config.lua
	@lua -lluacov test/test_utils.lua
	@lua -lluacov test/test_highlights.lua
	@lua -lluacov test/test_preview.lua
	@lua -lluacov test/test_health.lua
	@lua -lluacov test/test_terminal.lua
	@lua -lluacov test/test_installer.lua
	@lua -lluacov test/test_init.lua
	@luacov
	@echo "Coverage report generated: luacov.report.out"

# Clean up test artifacts
clean:
	@echo "Cleaning up..."
	@rm -f luacov.report.out luacov.stats.out
	@echo "✓ Cleanup completed" 