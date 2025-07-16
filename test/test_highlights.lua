-- Highlight logic tests for mona.nvim
-- Add current directory to package path for testing
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Mock vim.api for testing
vim = vim or {}
vim.api = vim.api or {}
local set_hl_calls = {}
local get_hl_calls = {}
vim.api.nvim_set_hl = function(ns, group, hl)
  table.insert(set_hl_calls, { ns = ns, group = group, hl = hl })
end
vim.api.nvim_get_hl = function(ns, opts)
  table.insert(get_hl_calls, { ns = ns, opts = opts })
  return {}
end
vim.cmd = function(cmd)
  print("[vim.cmd] " .. cmd)
end

local highlights = require("mona.highlights")

local function test_apply_styles()
  print("Testing apply_styles...")
  highlights.apply_styles({
    bold = { Comment = true },
    italic = { Todo = true },
    bold_italic = { Error = true }
  })
  assert(#set_hl_calls > 0, "nvim_set_hl should be called")
  print("✓ apply_styles tested")
end

local function test_apply_style_to_group()
  print("Testing apply_style_to_group...")
  highlights.apply_style_to_group("Comment", "bold")
  highlights.apply_style_to_group("Todo", "italic")
  highlights.apply_style_to_group("Error", "bold_italic")
  assert(#set_hl_calls > 0, "nvim_set_hl should be called for style_to_group")
  print("✓ apply_style_to_group tested")
end

local function test_load()
  print("Testing load...")
  highlights.load()
  print("✓ load tested")
end

local function test_clear()
  print("Testing clear...")
  highlights.clear()
  print("✓ clear tested")
end

print("Running mona.nvim highlights tests...")
test_apply_styles()
test_apply_style_to_group()
test_load()
test_clear()
print("All highlights tests passed!") 