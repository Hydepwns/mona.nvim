local M = {}
local utils = require("mona.utils")

M.preview_buffer = nil
M.preview_window = nil

M.show = function()
  -- Create preview buffer
  M.preview_buffer = vim.api.nvim_create_buf(false, true)

  -- Set content
  local lines = vim.split(require("mona.config").config.preview.sample_text, "\n")
  vim.api.nvim_buf_set_lines(M.preview_buffer, 0, -1, false, lines)

  -- Create floating window
  local opts = require("mona.config").config.preview.window_opts
  opts.relative = "editor"
  opts.row = math.floor((vim.o.lines - opts.height) / 2)
  opts.col = math.floor((vim.o.columns - opts.width) / 2)

  M.preview_window = vim.api.nvim_open_win(M.preview_buffer, true, opts)

  -- Apply syntax highlighting
  vim.api.nvim_buf_set_option(M.preview_buffer, "filetype", "javascript")

  -- Apply highlight groups to demonstrate font mixing
  M.apply_preview_highlights()

  -- Key mappings
  vim.api.nvim_buf_set_keymap(M.preview_buffer, "n", "q", ":q<CR>", { noremap = true })
  vim.api.nvim_buf_set_keymap(M.preview_buffer, "n", "<Esc>", ":q<CR>", { noremap = true })

  -- Add title
  vim.api.nvim_buf_set_option(M.preview_buffer, "modifiable", false)

  -- Set buffer name
  vim.api.nvim_buf_set_name(M.preview_buffer, "Mona Font Preview")
end

M.apply_preview_highlights = function()
  -- Apply different highlight groups to demonstrate fonts
  vim.api.nvim_buf_add_highlight(M.preview_buffer, -1, "Comment", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(M.preview_buffer, -1, "Function", 1, 0, -1)
  vim.api.nvim_buf_add_highlight(M.preview_buffer, -1, "Keyword", 2, 0, -1)
  vim.api.nvim_buf_add_highlight(M.preview_buffer, -1, "String", 3, 0, -1)
  vim.api.nvim_buf_add_highlight(M.preview_buffer, -1, "Comment", 4, 0, -1)
  vim.api.nvim_buf_add_highlight(M.preview_buffer, -1, "Todo", 5, 0, -1)
end

M.cycle_fonts = function(style)
  -- Cycle through different font assignments for a style
  local fonts = { "Neon", "Argon", "Xenon", "Radon", "Krypton" }
  -- Implementation to cycle and update terminal config
  utils.info("Font cycling not yet implemented")
end

-- Close preview window
M.close = function()
  if M.preview_window and vim.api.nvim_win_is_valid(M.preview_window) then
    vim.api.nvim_win_close(M.preview_window, true)
  end
  if M.preview_buffer and vim.api.nvim_buf_is_valid(M.preview_buffer) then
    vim.api.nvim_buf_delete(M.preview_buffer, { force = true })
  end
  M.preview_window = nil
  M.preview_buffer = nil
end

return M
