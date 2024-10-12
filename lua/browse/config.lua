local M = {}

--- @type Browse.Configurations
local config = {
  bookmarks = {},
  icons = {
    bookmark_alias = "->",
    bookmark_prompt = "",
    grouped_bookmarks = "->",
  },
  persist_grouped_bookmarks_query = false,
  debug = false,
  use_icon = true,
  init = function()
    require("browse.providers.input")
    require("browse.providers.bookmarks")
    require("browse.providers.devdocs")
    require("browse.providers.mdn")
    require("browse.providers.devdocs_file")
  end,
}

--- @param configuration Browse.Configurations.Optional?
function M.merge_with(configuration)
  config = vim.tbl_deep_extend("force", config, configuration or {})
end

function M.get_config()
  return config
end

return setmetatable(M, {
  __index = function(_, k)
    return config[k]
  end,
})
