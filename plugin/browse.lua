local browse = require("browse")

--- Executes a command for a subcommand if found in providers.
--- @param subcommand string|nil The optional subcommand.
--- @param callback function The callback to run when the subcommand matches.
local function execute_command(subcommand, callback)
  local providers = require("browse.providers").providers

  -- If no subcommand is provided, run the default callback.
  if not subcommand then
    return callback()
  end

  -- Use pcall to safely execute the callback if the subcommand is valid.
  local success, result = pcall(function()
    for _, child in ipairs(providers) do
      if child.name == subcommand then
        return callback(subcommand)
      end
    end
    -- Return a custom error message if no matching subcommand is found.
    return error("Unknown subcommand: " .. subcommand)
  end)

  -- Handle the result of pcall.
  if not success then
    --- @diagnostic disable-next-line
    vim.notify(result, vim.log.levels.ERROR) -- Display the error message.
  end
end

--- Creates the "Browse" user command.
vim.api.nvim_create_user_command("Browse", function(opts)
  local subcommand = opts.args:match("%S+") -- Extract the first argument as the subcommand.

  -- Execute the appropriate action for the subcommand.
  execute_command(subcommand, browse.run_action)
end, {
  nargs = "?", -- The argument is optional.
  range = true, -- Allow range.
  complete = function()
    -- Dynamic completion from browse.providers
    local providers = require("browse.providers").providers
    local completions = {}

    for _, child in ipairs(providers) do
      table.insert(completions, child.name)
    end

    -- Return custom completions or static completions
    return #completions > 0 and completions
      or { "input", "mdn", "devdocs", "devdocs_file", "bookmarks" }
  end,
})
