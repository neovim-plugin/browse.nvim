local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")

local config = require("browse.config")
local utils = require("browse.utils")

local initialised = false
local M = {}

local function init()
  if initialised then
    return
  end
  initialised = true

  -- Use pcall to safely call the config's init function
  local success, result = pcall(function()
    if config and type(config.init) == "function" then
      config.init()
    end
  end)

  if not success then
    vim.notify("Error during initialization: " .. result, vim.log.levels.ERROR)
  end
end

--- Opens a Telescope picker for browsing available search options.
--- @param browse_options Browse.Options.Optional?
local function browse(browse_options)
  local theme = themes.get_dropdown()

  local merged_opts = vim.tbl_deep_extend(
    "force",
    config.get_config(),
    theme,
    browse_options or {}
  )

  local merged_bookmarks = merged_opts.bookmarks

  local visual_text = utils.get_visual_selection()
  local providers = require("browse.providers").providers

  local function create_finder()
    local finder = {
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],
          ordinal = entry[2],
        }
      end,
      results = {},
    }

    local provider_copy = vim.deepcopy(providers)
    table.sort(provider_copy, function(a, b)
      return a.name < b.name
    end)

    for _, provider in ipairs(provider_copy) do
      finder.results[#finder.results + 1] =
        { provider.description, provider.name }
    end

    return finders.new_table(finder)
  end

  -- Safely open the picker with a pcall
  local success, err = pcall(function()
    pickers
      .new(merged_opts, {
        prompt_title = utils.generate_title("browse.nvim", ""),
        finder = create_finder(),
        sorter = conf.generic_sorter(merged_opts),

        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)

            local selected_entry = action_state.get_selected_entry()
            local browse_selection = selected_entry["ordinal"]

            if browse_selection == "bookmarks" then
              M.run_action("bookmarks", {
                bookmarks = merged_bookmarks,
                visual_text = visual_text,
              })
            else
              M.run_action(browse_selection, visual_text)
            end
          end)
          return true
        end,
      })
      :find()
  end)

  if not success then
    vim.notify("Error opening picker: " .. err, vim.log.levels.ERROR)
  end
end

--- @param opts Browse.Configurations.Optional?
function M.setup(opts)
  config.merge_with(opts)
  init()
end

--- @param provider Browse.RegisterProvider
function M.register(provider)
  local success, err = pcall(function()
    require("browse.providers").register(provider)
  end)
  if not success then
    vim.notify("Error registering provider: " .. err, vim.log.levels.ERROR)
  end
end

--- Executes an action for a given provider.
--- @param provider_name string?
--- @vararg string | table | Browse.Options.Optional Additional arguments passed to the provider's search function.
function M.run_action(provider_name, ...)
  init()

  -- Wrap the function with varargs inside pcall
  local success, err = pcall(function(provider_n, ...)
    local provider = require("browse.providers").get(provider_n)

    if provider and type(provider.search) == "function" then
      -- Pass varargs to provider.search
      provider.search(...)
    else
      -- If provider doesn't exist, fallback to browse
      browse(...)
    end
  end, provider_name, ...) -- Pass provider_name and varargs into pcall

  if not success then
    vim.notify("Error running action: " .. err, vim.log.levels.ERROR)
  end
end

return M
