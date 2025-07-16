local M = {}
local utils = require("mona.utils")

M.config = {
  install_path = {
    Darwin = "~/Library/Fonts",
    Linux = "~/.local/share/fonts",
    Windows = "C:\\Windows\\Fonts"
  },
  github_api = "https://api.github.com/repos/githubnext/monaspace/releases/latest",
  font_types = { "otf", "variable", "frozen" },
  font_families = { "neon", "argon", "xenon", "radon", "krypton" }
}

-- Get OS-specific install path
M.get_install_path = function()
  local os_name = utils.get_os()
  local path = M.config.install_path[os_name]
  if not path then
    utils.error(string.format("Unsupported OS: %s", os_name))
  end
  return vim.fn.expand(path)
end

-- Check if Monaspace fonts are installed
M.check_installation = function()
  local install_path = M.get_install_path()
  local status = {}
  
  for _, family in ipairs(M.config.font_families) do
    local found = false
    -- Check for different font file extensions
    for _, ext in ipairs({ "otf", "ttf", "woff2" }) do
      local font_file = vim.fn.glob(install_path .. "/Monaspace" .. utils.format_font_family(family) .. "*." .. ext)
      if font_file ~= "" then
        found = true
        break
      end
    end
    status[family] = found
  end
  
  return status
end

-- Download file from URL
M.download_file = function(url, filepath, progress_callback)
  local curl_cmd = string.format('curl -L -o "%s" "%s"', filepath, url)
  
  if progress_callback then
    progress_callback("Downloading " .. url)
  end
  
  local result = vim.fn.system(curl_cmd)
  if vim.v.shell_error ~= 0 then
    utils.error(string.format("Failed to download: %s", result))
  end
  
  return filepath
end

-- Extract archive
M.extract_archive = function(archive_path, extract_path, progress_callback)
  if progress_callback then
    progress_callback("Extracting archive...")
  end
  
  local result
  if archive_path:match("%.zip$") then
    result = vim.fn.system(string.format('unzip -q "%s" -d "%s"', archive_path, extract_path))
  elseif archive_path:match("%.tar%.gz$") then
    result = vim.fn.system(string.format('tar -xzf "%s" -C "%s"', archive_path, extract_path))
  else
    utils.error("Unsupported archive format")
  end
  
  if vim.v.shell_error ~= 0 then
    utils.error(string.format("Failed to extract archive: %s", result))
  end
end

-- Refresh font cache
M.refresh_font_cache = function()
  local os_name = utils.get_os()
  local result
  
  if os_name == "Linux" then
    result = vim.fn.system("fc-cache -f -v")
  elseif os_name == "Darwin" then
    -- macOS doesn't need explicit cache refresh
    result = ""
  else
    -- Windows doesn't need explicit cache refresh
    result = ""
  end
  
  if vim.v.shell_error ~= 0 then
    utils.warn(string.format("Font cache refresh failed: %s", result))
  end
end

-- Get latest release info from GitHub
M.get_latest_release = function()
  local curl_cmd = string.format('curl -s "%s"', M.config.github_api)
  local result = vim.fn.system(curl_cmd)
  
  if vim.v.shell_error ~= 0 then
    utils.error(string.format("Failed to fetch release info: %s", result))
  end
  
  -- Parse JSON response (simplified - in production you'd use a JSON parser)
  local version = result:match('"tag_name"%s*:%s*"([^"]+)"')
  local download_url = result:match('"browser_download_url"%s*:%s*"([^"]+)"')
  
  return {
    version = version,
    download_url = download_url
  }
end

-- Download and install fonts
M.install = function(opts)
  opts = vim.tbl_deep_extend("force", {
    font_type = "variable", -- "otf", "variable", or "frozen"
    families = { "all" },   -- or specific: {"neon", "argon"}
    force = false,          -- Overwrite existing
    progress_callback = nil -- Function to report progress
  }, opts or {})
  
  local progress = opts.progress_callback or function(msg)
    utils.info(msg)
  end
  
  -- Check if fonts are already installed
  local installation = M.check_installation()
  local to_install = {}
  
  if opts.families[1] == "all" then
    to_install = M.config.font_families
  else
    to_install = opts.families
  end
  
  -- Check which fonts need installation
  local need_install = {}
  for _, family in ipairs(to_install) do
    if not installation[family] or opts.force then
      table.insert(need_install, family)
    end
  end
  
  if #need_install == 0 then
    progress("All requested fonts are already installed")
    return
  end
  
  progress("Installing fonts: " .. table.concat(need_install, ", "))
  
  -- Get latest release
  local release = M.get_latest_release()
  if not release.download_url then
    utils.error("Could not find download URL in release info")
  end
  
  -- Create temporary directory
  local temp_dir = vim.fn.tempname()
  utils.safe_mkdir(temp_dir)
  
  -- Download and extract
  local archive_path = temp_dir .. "/monaspace.zip"
  M.download_file(release.download_url, archive_path, progress)
  M.extract_archive(archive_path, temp_dir, progress)
  
  -- Install fonts
  local install_path = M.get_install_path()
  utils.safe_mkdir(install_path)
  
  progress("Installing fonts to: " .. install_path)
  
  -- Copy font files (simplified - would need more sophisticated file matching)
  local copy_cmd = string.format('cp "%s"/*.ttf "%s"/', temp_dir, install_path)
  local result = vim.fn.system(copy_cmd)
  
  if vim.v.shell_error ~= 0 then
    utils.error(string.format("Failed to copy fonts: %s", result))
  end
  
  -- Refresh font cache
  M.refresh_font_cache()
  
  -- Cleanup
  utils.safe_delete(temp_dir)
  
  progress("Font installation completed successfully!")
end

-- Update fonts to latest version
M.update = function()
  local progress = function(msg)
    utils.info(msg)
  end
  
  progress("Checking for updates...")
  
  -- Check current installation
  local installation = M.check_installation()
  local installed_families = {}
  
  for family, installed in pairs(installation) do
    if installed then
      table.insert(installed_families, family)
    end
  end
  
  if #installed_families == 0 then
    progress("No fonts installed. Run :MonaInstall first.")
    return
  end
  
  -- Install with force flag to update
  M.install({
    families = installed_families,
    force = true,
    progress_callback = progress
  })
end

-- Remove fonts
M.uninstall = function(families)
  local install_path = M.get_install_path()
  local to_remove
  if families == nil then
    to_remove = M.config.font_families
  elseif type(families) == "string" then
    to_remove = { families }
  else
    to_remove = families
  end

  for _, family in ipairs(to_remove) do
    local pattern = install_path .. "/Monaspace" .. utils.format_font_family(family) .. "*"
    local files = vim.fn.glob(pattern, false, true)

    for _, file in ipairs(files) do
      utils.safe_delete(file)
      utils.info("Removed: " .. vim.fn.fnamemodify(file, ":t"))
    end
  end

  M.refresh_font_cache()
  utils.info("Font uninstallation completed")
end

return M 