local M = {}

-- Default style mappings
M.default_style_map = {
  bold = {
    Comment = true,
    ["@comment.documentation"] = true,
  },
  italic = {
    ["@markup.link"] = true,
  },
  bold_italic = {
    DiagnosticError = true,
    StatusLine = true,
  },
}

-- Apply style mappings to highlight groups
M.apply_styles = function(style_map)
  style_map = style_map or M.default_style_map

  for style, groups in pairs(style_map) do
    for group, enabled in pairs(groups) do
      if enabled then
        M.apply_style_to_group(group, style)
      end
    end
  end
end

-- Apply a specific style to a highlight group
M.apply_style_to_group = function(group, style)
  local hl_group = vim.api.nvim_get_hl(0, { name = group })

  if style == "bold" then
    hl_group.bold = true
  elseif style == "italic" then
    hl_group.italic = true
  elseif style == "bold_italic" then
    hl_group.bold = true
    hl_group.italic = true
  end

  vim.api.nvim_set_hl(0, group, hl_group)
end

-- Load default styles
M.load = function()
  M.apply_styles(M.default_style_map)
end

-- Clear all style mappings
M.clear = function()
  -- Reset all highlight groups to default
  vim.cmd("highlight clear")
end

return M
