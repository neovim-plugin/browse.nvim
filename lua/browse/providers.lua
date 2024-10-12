local M = {}

--- @type Browse.Provider[]
local providers = {}
M.providers = providers

local id_cnt = 0

--- @param provider Browse.RegisterProvider
function M.register(provider)
  if not provider.search or type(provider.search) ~= "function" then
    vim.notify(
      string.format(
        "error: provider %s does not provide a search function",
        provider.name or "NA"
      ),
      vim.log.levels.ERROR
    )
    return
  end

  --- @cast provider Browse.Provider
  provider.id = id_cnt
  id_cnt = id_cnt + 1

  providers[#providers + 1] = provider
end

--- @param provider_name string?
--- @return Browse.Provider?
function M.get(provider_name)
  if not provider_name then
    return nil
  end
  for _, child in ipairs(providers) do
    if child.name == provider_name then
      return child
    end
  end
  return nil -- Return nil if no matching entry is found
end

return M
