-- Luacheck configuration for mona.nvim
-- Configure luacheck for Neovim plugin development

-- Global variables available in Neovim
globals = {
    -- Neovim API
    "vim",
    "jit",
    "_VERSION",
    
    -- Test framework globals
    "describe",
    "it",
    "before_each",
    "after_each",
    "pending",
    "assert",
    
    -- Plenary test globals
    "helpers",
    "eq",
    
    -- Coverage
    "luacov",
}

-- Read globals from other modules
read_globals = {
    "vim",
}

-- Exclude files that shouldn't be linted
exclude_files = {
    "test/plenary.nvim/**",
}

-- Allow unused variables in test files (they're often used for mocking)
unused = false

-- Allow redefined variables in test files
redefined = false

-- Allow unused arguments in test files (they're often used for mocking)
unused_args = false

-- Allow trailing whitespace in some cases
no_trailing = false

-- Allow empty lines with whitespace
no_whitespace = false

-- Maximum line length (disabled for now)
max_line_length = false 