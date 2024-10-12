local utils = require("browse.utils")
local providers = require("browse.providers")

local DEFAULT_ICON = ""

--- @type table<SearchEngineName, Browse.Provider.Input.SearchEngine>
local engines = {
  bing = {
    url = "https://%s.com/search?q=%s",
    icon = "󰂤",
  },
  brave = {
    url = "https://search.%s.com/search?q=%s",
    icon = "",
  },
  duckduckgo = {
    url = "https://%s.com/?q=%s",
    icon = "󰇥",
    name = "DuckDuckGo",
  },
  ecosia = {
    url = "https://%s.org/search?q=",
    icon = "",
  },
  google = {
    url = "https://%s.com/search?q=%s",
    icon = "",
  },
  perplexity = {
    url = "https://%s.ai/search?q=%s",
    icon = "",
  },
  startpage = {
    url = "https://%s.com/sp/search?query=%s",
    icon = "",
  },
  yahoo = {
    url = "https://search.%s.com/search?q=%s",
    icon = "",
  },
}

--- Searches for the engine key or name that contains the given substring
--- @param selected_engine string The user selection (e.g., " Google")
--- @return string|nil The key of the matched engine or nil if not found
local function find_matching_engine_key(selected_engine)
  -- Loop through all engines
  for engine_key, engine in pairs(engines) do
    local engine_name = engine.name or utils.capitalize_first_letter(engine_key)

    -- Check if the selection contains either the key or the name
    if
      selected_engine:lower():find(engine_key:lower())
      or selected_engine:lower():find(engine_name:lower())
    then
      return engine_key -- Return the engine key if found
    end
  end

  -- If no match is found, return nil
  return nil
end

--- @return string[] engines A sorted array of engine icons and names
local function get_sorted_engine_list()
  -- Create an array from engines
  local engines_list = {}

  for engine_key, engine in pairs(engines) do
    -- Use the engine's name if it exists, otherwise capitalize the key
    local engine_name = engine.name or utils.capitalize_first_letter(engine_key)
    -- Include the icon if it exists
    local engine_entry =
      utils.generate_title(engine_name, engine.icon or DEFAULT_ICON)
    table.insert(engines_list, { name = engine_name, entry = engine_entry })
  end

  -- Sort the array alphabetically by engine name
  table.sort(engines_list, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  -- Extract only the entry (icon + name) from the sorted array
  local sorted_engine_entries = {}
  for _, engine in ipairs(engines_list) do
    table.insert(sorted_engine_entries, engine.entry)
  end

  return sorted_engine_entries
end

--- Executes a search using the specified search engine and input text.
--- @param engine_key SearchEngineName The key of the search engine to use.
--- @param search_text string? The text to search for.
local function perform_search(engine_key, search_text)
  local engine = engines[engine_key]

  if not engine then
    vim.notify("Search engine not found: " .. engine_key, vim.log.levels.ERROR)
    return
  end

  -- Get the display name of the engine (either the name or capitalized key)
  local engine_name = engine.name or utils.capitalize_first_letter(engine_key)
  local engine_entry =
    utils.generate_title(engine_name, engine.icon or DEFAULT_ICON)

  return utils.search({
    prompt = "Search with " .. engine_entry,
    visual_text = search_text,
    formatter = function(str)
      return string.format(engine.url, engine_name, str)
    end,
  })
end

--- Prompts the user to select a search engine and executes a search.
--- @param input_text string? The input text to search for, or nil to get visual selection.
local function search(input_text)
  local search_text = input_text or utils.get_visual_selection()
  vim.ui.select(get_sorted_engine_list(), {
    prompt = "Select Search Engine",
  }, function(selected_engine)
    if selected_engine then
      -- Find the engine key based on the selected string
      local engine_key = find_matching_engine_key(selected_engine)
      if engine_key then
        perform_search(engine_key, search_text)
      else
        vim.notify(
          "Invalid selection. Please select a valid search engine.",
          vim.log.levels.WARN
        )
      end
    end
  end)
end

require("browse.providers").register({
  name = "input",
  description = utils.generate_title("input search", ""),
  search = search,
})

return search
