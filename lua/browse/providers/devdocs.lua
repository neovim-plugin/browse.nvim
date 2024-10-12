local utils = require("browse.utils")

--- @param visual_text string?
local function search(visual_text)
  visual_text = visual_text or utils.get_visual_selection()
  utils.search({
    prompt = utils.generate_title("devdocs.io filetype search", ""),
    visual_text = visual_text,
    formatter = "https://devdocs.io/#q=%s",
  })
end

require("browse.providers").register({
  name = "devdocs",
  description = utils.generate_title("devdocs.io query search", "󰧮"),
  search = function(visual_text)
    --- @cast visual_text string
    visual_text = visual_text or utils.get_visual_selection()
    search(visual_text)
  end,
})

return search
