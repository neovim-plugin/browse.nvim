local config = require("browse.config")

vim.loop = vim.uv or vim.loop

local M = {}

M.sep = package.config:sub(1, 1)

-- get os name
local function get_os_name()
  local os = vim.loop.os_uname()
  local os_name = os.sysname
  return os_name
end

-- WSL
local function is_wsl()
  local output = vim.fn.systemlist("uname -r")
  return not not string.find(output[1] or "", "WSL")
end

-- get open cmd
local function get_open_cmd()
  local os_name = get_os_name()

  local open_cmd = nil
  if os_name == "Windows_NT" or os_name == "Windows" then
    open_cmd = { "cmd", "/c", "start" }
  elseif os_name == "Darwin" then
    open_cmd = { "open" }
  else
    if is_wsl() then
      open_cmd = { "wslview" }
    else
      open_cmd = { "xdg-open" }
    end
  end
  return open_cmd
end

--- @param target string
local function escape_target(target)
  local escapes = {
    [" "] = "%20",
    ["<"] = "%3C",
    [">"] = "%3E",
    ["#"] = "%23",
    ["%"] = "%25",
    ["+"] = "%2B",
    ["{"] = "%7B",
    ["}"] = "%7D",
    ["|"] = "%7C",
    ["\\"] = "%5C",
    ["^"] = "%5E",
    ["~"] = "%7E",
    ["["] = "%5B",
    ["]"] = "%5D",
    ["‘"] = "%60",
    [";"] = "%3B",
    ["/"] = "%2F",
    ["?"] = "%3F",
    [":"] = "%3A",
    ["@"] = "%40",
    ["="] = "%3D",
    ["&"] = "%26",
    ["$"] = "%24",
  }

  return target:gsub(".", escapes)
end

-- start the browser job
local function open_browser(target)
  target = vim.fn.trim(target)
  local open_cmd = vim.fn.extend(get_open_cmd(), { target })

  vim.fn.jobstart(open_cmd, { detach = true })
end

--- @param opts Browse.Search.Options
--- @overload fun(input: string)
function M.search(opts)
  if type(opts) == "string" then
    open_browser(opts)
  else
    local prompt = opts.prompt or "Search String:"
    local default = opts.visual_text or ""
    local formatter = opts.formatter or function(str)
      return str
    end

    vim.ui.input(
      { prompt = prompt, default = default, kind = "browse" },
      function(input)
        if input == nil or input == "" then
          return
        end

        local escaped_input = escape_target(vim.fn.trim(input))
        local path = type(formatter) == "string"
            and string.format(formatter, escaped_input)
          or formatter(escaped_input)
        open_browser(path)
      end
    )
  end
end

--Get the domain of a URL
--Example: https://obsidian.md => obsidian.md
---@param url string: URL to which your domain will be extracted
---@return string: Domain from the URL
function M.get_domain(url)
  return string.match(url, "https?://([^/]+)")
end

--- Remove an element from a table by key
--- @param tbl table
--- @param key_to_remove any
--- @return table
function M.remove_element_from_table(tbl, key_to_remove)
  local updated_table = {}
  for key, value in pairs(tbl) do
    if key ~= key_to_remove then
      updated_table[key] = value
    end
  end
  return updated_table
end

--- Capitalize first letter of input string
--- @param input string String that you want to capitalize the first letter of
--- @return string output
function M.capitalize_first_letter(input)
  return input:sub(1, 1):upper() .. input:sub(2)
end

--- @param title string
--- @param icon string
--- @return string
function M.generate_title(title, icon)
  return (config.use_icon and icon .. " " or "") .. title
end

--- Retrieves the visual selection using getregion for improved speed.
--- @return string | nil
function M.get_visual_selection()
  vim.api.nvim_exec2("exec \"silent normal! \\<esc>\"", {})

  --- @type boolean, string[]
  local ok, region

  if config.debug then
    ok, region = xpcall(function()
      return vim.fn.getregion(
        vim.fn.getcharpos("'<"),
        vim.fn.getcharpos("'>"),
        { exclusive = false, type = vim.fn.visualmode() }
      )
    end, function(err)
      print("Error caught: " .. err)
      return nil -- Return nil on error
    end)
  else
    ok, region = pcall(
      vim.fn.getregion,
      vim.fn.getcharpos("'<"),
      vim.fn.getcharpos("'>"),
      { exclusive = false, type = vim.fn.visualmode() }
    )
  end

  if ok then
    local cleaned_lines = {}
    for _, line in ipairs(region) do
      local cleaned_line = line:gsub("%s+", "")
      if cleaned_line ~= "" then
        table.insert(cleaned_lines, cleaned_line)
      end
    end

    vim.api.nvim_exec2("delmarks < >", {})

    return #cleaned_lines > 0 and table.concat(cleaned_lines, " ") or nil
  end
  return nil
end

return M
