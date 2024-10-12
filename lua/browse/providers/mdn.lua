local utils = require("browse.utils")

--- @param visual_text string?
local function search(visual_text)
  visual_text = visual_text or utils.get_visual_selection()
  utils.search({
    prompt = utils.generate_title("Search MDN", ""),
    visual_text = visual_text,
    formatter = "https://developer.mozilla.org/en-US/search?q=%s",
  })
end

require("browse.providers").register({
  name = "mdn",
  description = utils.generate_title("mdn search", ""),
  search = search,
})

return search
