#!/bin/bash

# Development script for mona.nvim
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "lua/mona/init.lua" ]; then
    print_error "Please run this script from the mona.nvim root directory"
    exit 1
fi

# Function to setup local environment
setup_env() {
    print_status "Setting up local development environment..."
    
    # Install luacov locally if not present
    if ! luarocks list | grep -q luacov; then
        print_status "Installing luacov..."
        luarocks install --local luacov
    fi
    
    # Install plenary.nvim if not present
    if [ ! -d "test/plenary.nvim" ]; then
        print_status "Installing plenary.nvim..."
        git clone https://github.com/nvim-lua/plenary.nvim.git test/plenary.nvim
    fi
    
    # Setup environment variables
    eval "$(luarocks path --bin)"
    
    print_status "Environment setup complete!"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    make test
}

# Function to run tests with coverage
run_coverage() {
    print_status "Running tests with coverage..."
    make coverage
    
    # Show coverage summary
    if [ -f "luacov.report.out" ]; then
        print_status "Coverage report generated: luacov.report.out"
        print_status "Coverage summary:"
        tail -n 20 luacov.report.out | grep -E "(Total|Summary)" || true
    fi
}

# Function to run linting
run_lint() {
    print_status "Running luacheck..."
    if command -v luacheck >/dev/null 2>&1; then
        luacheck lua/ test/ validate.lua --no-max-line-length
    else
        print_warning "luacheck not found. Install with: luarocks install --local luacheck"
    fi
}

# Function to clean up
cleanup() {
    print_status "Cleaning up..."
    make clean
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup     - Setup local development environment"
    echo "  test      - Run all tests"
    echo "  coverage  - Run tests with coverage"
    echo "  lint      - Run luacheck linting"
    echo "  clean     - Clean up test artifacts"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 test"
    echo "  $0 coverage"
}

# Main script logic
case "${1:-help}" in
    setup)
        setup_env
        ;;
    test)
        setup_env
        run_tests
        ;;
    coverage)
        setup_env
        run_coverage
        ;;
    lint)
        run_lint
        ;;
    clean)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 