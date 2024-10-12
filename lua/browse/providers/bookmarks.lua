local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local themes = require("telescope.themes")
local action_state = require("telescope.actions.state")

local utils = require("browse.utils")
local config = require("browse.config")

--- @param bookmarks Bookmarks
local function fixed_bookmarks(bookmarks)
  if type(bookmarks) ~= "table" then
    error("Input must be a table")
  end
  local new_tbl = {}

  for key, bookmark in pairs(bookmarks) do
    if type(bookmark) == "table" then
      -- Create a new table for this bookmark
      local new_bookmark = {}

      -- Copy the original table content and apply transformations
      for k, v in pairs(bookmark) do
        new_bookmark[k] = v -- Copy the value directly
      end

      -- Generate a name if it doesn't exist
      if not new_bookmark.name then
        --- @diagnostic disable-next-line
        new_bookmark.name = utils.capitalize_first_letter(key)
      end

      -- Recursively fix bookmarks in case of nested tables
      new_tbl[key] = fixed_bookmarks(new_bookmark) -- Store the transformed bookmark
    else
      -- Directly assign non-table values
      new_tbl[key] = bookmark
    end
  end

  return new_tbl
end

--- @param options Browse.Bookmarks.Options
local function bookmark_search(options)
  options = options or {}
  local icons = options.icons or config.icons or {}
  local persist_grouped_bookmarks_query = options.persist_grouped_bookmarks_query
    or config.persist_grouped_bookmarks_query
    or false
  local bookmarks = options.bookmarks or config.bookmarks or {}
  bookmarks = fixed_bookmarks(bookmarks)

  local visual_text = options.visual_text or utils.get_visual_selection()
  local theme = themes.get_dropdown()

  --- @type Browse.Bookmarks.Options
  --- @diagnostic disable-next-line
  local picker_opts = vim.tbl_deep_extend("force", options, theme or {})

  local bookmarks_list = {}
  for k, v in pairs(bookmarks) do
    if type(k) == "string" then
      table.insert(bookmarks_list, { k, v })
    else
      table.insert(bookmarks_list, v)
    end
  end

  --- Creates an entry for each bookmark.
  --- @param bookmark_entry any The bookmark entry to process.
  --- @return table entry The formatted bookmark entry.
  local function entry_maker(bookmark_entry)
    local bookmark_value, display_text, search_ordinal

    if type(bookmark_entry) == "string" then
      bookmark_value = bookmark_entry
      display_text = bookmark_entry
      search_ordinal = bookmark_entry
    else
      bookmark_value = bookmark_entry[2]
      if type(bookmark_entry[2]) == "table" then
        display_text =
          utils.generate_title(bookmark_entry[2].name, bookmark_entry[2].icon)
      else
        display_text = bookmark_entry[1]
      end

      if type(bookmark_entry[2]) ~= "table" then
        display_text = string.format(
          "%s %s %s",
          display_text,
          icons.bookmark_alias,
          bookmark_value
        )
        search_ordinal = bookmark_entry[1] .. bookmark_entry[2]
      else
        display_text = display_text .. " " .. icons.grouped_bookmarks
        search_ordinal = bookmark_entry[1]

        for sub_key, sub_value in pairs(bookmark_entry[2]) do
          if sub_key ~= "name" and sub_key ~= "icon" then
            search_ordinal = search_ordinal .. sub_key .. sub_value
            display_text = display_text
              .. " "
              .. (
                type(sub_key) == "string" and sub_key
                or utils.get_domain(sub_value)
              )
          end
        end
      end
    end

    return {
      value = bookmark_value,
      display = display_text,
      ordinal = search_ordinal,
    }
  end

  --- Creates a finder for the bookmarks.
  --- @return table finder  The Telescope finder.
  local function create_finder()
    return finders.new_table({
      results = bookmarks_list,
      entry_maker = entry_maker,
    })
  end

  pickers
    .new(picker_opts, {
      prompt_title = picker_opts.title
        or utils.generate_title("Bookmark Search", icons.bookmark_prompt),
      finder = create_finder(),
      sorter = conf.generic_sorter(picker_opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)

          local selection = action_state.get_selected_entry()

          if not selection then
            return
          end

          local value = selection.value

          if type(value) == "table" then
            -- copy table to avoid mutation
            local tbl_copy = vim.deepcopy(value)
            local title = tbl_copy.name
            local icon = tbl_copy.icon

            local list = utils.remove_element_from_table(tbl_copy, "name")
            list = utils.remove_element_from_table(list, "icon")

            local search_bookmarks_opts = {
              bookmarks = list,
              visual_text = visual_text,
            }

            if persist_grouped_bookmarks_query then
              local query = action_state.get_current_line()

              search_bookmarks_opts.visual_text = query
            end

            search_bookmarks_opts.title = title
                and utils.generate_title(title, icon) .. " Bookmark"
              or "Bookmark"

            -- search bookmarks with the new list
            bookmark_search(search_bookmarks_opts)
          elseif type(value) == "string" then
            -- checking for `%` in the url
            if string.match(value, "%%") then
              utils.search({
                prompt = "Enter query: ",
                visual_text = visual_text,
                formatter = value,
              })
            else
              utils.search(value)
              vim.notify(string.format("Opening '%s'", value))
            end
          else
            -- handle other types
            print("else", value)
          end
        end)

        return true
      end,
    })
    :find()
end

--- @opts opts Browse.Bookmarks.Options
local function search(opts)
  --- @type Browse.Bookmarks.Options
  --- @diagnostic disable-next-line
  opts = vim.tbl_deep_extend("force", config.get_config(), opts or {})
  opts.visual_text = conf.visual_text or utils.get_visual_selection()
  bookmark_search(opts)
end

require("browse.providers").register({
  name = "bookmarks",
  description = utils.generate_title("bookmarks search", ""),
  search = search,
})

return search
