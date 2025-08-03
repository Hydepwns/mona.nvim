local M = {}
local utils = require("mona.utils")
local cache = require("mona.cache")

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
M.check_installation = function(use_cache)
  use_cache = use_cache ~= false -- default to using cache
  
  -- Try to get from cache first
  if use_cache then
    local cached_status = cache.get(cache.keys.font_installed())
    if cached_status then
      return cached_status
    end
  end
  
  local install_path = M.get_install_path()
  local status = {}
  
  for _, family in ipairs(M.config.font_families) do
    local found = false
    -- Check for different font file extensions
    for _, ext in ipairs({ "otf", "ttf", "woff2" }) do
      local font_file = vim.fn.glob(install_path .. "/Monaspace" .. utils.format_font_family(family) .. "*." .. ext)
      if font_file ~= "" then
        found = true
        -- Cache the font file paths
        local files = vim.fn.glob(install_path .. "/Monaspace" .. utils.format_font_family(family) .. "*." .. ext, false, true)
        cache.set(cache.keys.font_files(family), files, 600) -- 10 minute TTL
        break
      end
    end
    status[family] = found
  end
  
  -- Cache the status
  cache.set(cache.keys.font_installed(), status, 300) -- 5 minute TTL
  
  return status
end

-- Download file from URL (async version)
M.download_file_async = function(url, filepath, progress_callback, complete_callback)
  -- Wrap the download in retry logic
  utils.with_retry_async(function(retry_callback)
    local curl_cmd = string.format('curl -L --progress-bar -o "%s" "%s"', filepath, url)
    
    if progress_callback then
      progress_callback("Downloading " .. url)
    end
    
    local stdout = {}
    local stderr = {}
    
    vim.fn.jobstart(curl_cmd, {
      on_stdout = function(_, data, _)
        vim.list_extend(stdout, data)
      end,
      on_stderr = function(_, data, _)
        vim.list_extend(stderr, data)
        -- Parse progress from curl
        for _, line in ipairs(data) do
          if line:match("%d+%%") then
            local percent = line:match("(%d+)%%")
            if progress_callback then
              progress_callback(string.format("Downloading... %s%%", percent))
            end
          end
        end
      end,
      on_exit = function(_, exit_code, _)
        if exit_code == 0 then
          retry_callback(true, filepath)
        else
          retry_callback(false, table.concat(stderr, "\n"))
        end
      end
    })
  end, {
    max_attempts = 3,
    delay = 2000,
    should_retry = function(err)
      -- Retry on network errors
      return err:match("curl") or err:match("timeout") or err:match("Could not resolve")
    end
  }, complete_callback)
end

-- Download file from URL (sync version for compatibility)
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
M.get_latest_release = function(use_cache)
  use_cache = use_cache ~= false -- default to using cache
  
  -- Try to get from cache first
  if use_cache then
    local cached_release = cache.get(cache.keys.font_version())
    if cached_release then
      return cached_release
    end
  end
  
  -- Use retry logic for network request
  local release_info = utils.with_retry(function()
    local curl_cmd = string.format('curl -s "%s"', M.config.github_api)
    local result = vim.fn.system(curl_cmd)
    
    if vim.v.shell_error ~= 0 then
      error(string.format("Failed to fetch release info: %s", result))
    end
    
    -- Parse JSON response properly
    local ok, release_data = pcall(vim.fn.json_decode, result)
    if not ok then
      error("Failed to parse release JSON response")
    end
    
    -- Find the appropriate asset for the current OS
    local download_url = nil
    if release_data.assets then
      for _, asset in ipairs(release_data.assets) do
        if asset.browser_download_url and asset.browser_download_url:match("%.zip$") then
          download_url = asset.browser_download_url
          break
        end
      end
    end
    
    return {
      version = release_data.tag_name,
      download_url = download_url,
      published_at = release_data.published_at
    }
  end, {
    max_attempts = 3,
    delay = 2000,
    should_retry = function(err)
      -- Retry on network errors
      return err:match("Failed to fetch") or err:match("curl") or err:match("timeout")
    end
  })
  
  -- Cache the release info for 1 hour
  cache.set(cache.keys.font_version(), release_info, 3600)
  
  return release_info
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
  
  -- Copy font files (support multiple formats)
  local font_extensions = { "ttf", "otf", "woff2" }
  local copied = false
  
  for _, ext in ipairs(font_extensions) do
    -- Find font files recursively in temp directory
    local find_cmd = string.format('find "%s" -name "*.%s" -type f', temp_dir, ext)
    local font_files = vim.fn.systemlist(find_cmd)
    
    if #font_files > 0 then
      for _, font_file in ipairs(font_files) do
        local filename = vim.fn.fnamemodify(font_file, ":t")
        local dest_file = install_path .. "/" .. filename
        local copy_cmd = string.format('cp "%s" "%s"', font_file, dest_file)
        local result = vim.fn.system(copy_cmd)
        
        if vim.v.shell_error ~= 0 then
          utils.warn(string.format("Failed to copy %s: %s", filename, result))
        else
          copied = true
          progress(string.format("Installed: %s", filename))
        end
      end
    end
  end
  
  if not copied then
    utils.error("No font files found to install")
  end
  
  -- Refresh font cache
  M.refresh_font_cache()
  
  -- Cleanup
  utils.safe_delete(temp_dir)
  
  -- Invalidate installation cache
  cache.delete(cache.keys.font_installed())
  
  progress("Font installation completed successfully!")
end

-- Download and install fonts (async version)
M.install_async = function(opts, callback)
  opts = vim.tbl_deep_extend("force", {
    font_type = "variable",
    families = { "all" },
    force = false,
    progress_callback = nil
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
    if callback then callback(true, "Already installed") end
    return
  end
  
  progress("Installing fonts: " .. table.concat(need_install, ", "))
  
  -- Get latest release
  local release = M.get_latest_release()
  if not release.download_url then
    utils.notify_error("Could not find download URL in release info")
    if callback then callback(false, "No download URL") end
    return
  end
  
  -- Create temporary directory
  local temp_dir = vim.fn.tempname()
  utils.safe_mkdir(temp_dir)
  
  -- Download and extract asynchronously
  local archive_path = temp_dir .. "/monaspace.zip"
  
  M.download_file_async(release.download_url, archive_path, progress, function(success, result)
    if not success then
      utils.notify_error("Download failed: " .. result)
      utils.safe_delete(temp_dir, false)
      if callback then callback(false, result) end
      return
    end
    
    -- Extract in a separate job
    local extract_cmd
    if archive_path:match("%.zip$") then
      extract_cmd = string.format('unzip -q "%s" -d "%s"', archive_path, temp_dir)
    elseif archive_path:match("%.tar%.gz$") then
      extract_cmd = string.format('tar -xzf "%s" -C "%s"', archive_path, temp_dir)
    else
      utils.notify_error("Unsupported archive format")
      utils.safe_delete(temp_dir, false)
      if callback then callback(false, "Unsupported archive") end
      return
    end
    
    progress("Extracting archive...")
    
    vim.fn.jobstart(extract_cmd, {
      on_exit = function(_, exit_code, _)
        if exit_code ~= 0 then
          utils.notify_error("Failed to extract archive")
          utils.safe_delete(temp_dir, false)
          if callback then callback(false, "Extract failed") end
          return
        end
        
        -- Install fonts
        local install_path = M.get_install_path()
        utils.safe_mkdir(install_path)
        
        progress("Installing fonts to: " .. install_path)
        
        -- Copy font files
        local font_extensions = { "ttf", "otf", "woff2" }
        local copied = false
        
        for _, ext in ipairs(font_extensions) do
          local find_cmd = string.format('find "%s" -name "*.%s" -type f', temp_dir, ext)
          local font_files = vim.fn.systemlist(find_cmd)
          
          if #font_files > 0 then
            for _, font_file in ipairs(font_files) do
              local filename = vim.fn.fnamemodify(font_file, ":t")
              local dest_file = install_path .. "/" .. filename
              local copy_cmd = string.format('cp "%s" "%s"', font_file, dest_file)
              local result = vim.fn.system(copy_cmd)
              
              if vim.v.shell_error == 0 then
                copied = true
                progress(string.format("Installed: %s", filename))
              end
            end
          end
        end
        
        if not copied then
          utils.notify_error("No font files found to install")
          utils.safe_delete(temp_dir, false)
          if callback then callback(false, "No fonts found") end
          return
        end
        
        -- Refresh font cache
        M.refresh_font_cache()
        
        -- Cleanup
        utils.safe_delete(temp_dir, false)
        
        -- Invalidate installation cache
        cache.delete(cache.keys.font_installed())
        
        progress("Font installation completed successfully!")
        if callback then callback(true, "Installation complete") end
      end
    })
  end)
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