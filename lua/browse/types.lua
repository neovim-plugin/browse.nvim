--- @alias Bookmark BookmarkGroup | BookmarkAlias | SimpleBookmark

--- @alias Bookmarks table<Bookmark> A table of bookmark
---
--- @class BookmarkBase
--- @field [string] string A table of URLs, aliases, or queries (strict)

--- @class BookmarkGroup : BookmarkBase
--- @field name string The name of the bookmark group (required)
--- @field icon string? The icon of the bookmark group (optional)

--- @class BookmarkAlias : BookmarkBase
--- @field [string] string An alias for a specific URL (optional)

--- @class SimpleBookmark
--- @field url string The URL (required)

--- @class Browse.Options.Icons
--- @field bookmark_alias string? The icon for the bookmark alias
--- @field bookmark_prompt string? The icon for bookmark prompt
--- @field grouped_bookmarks string? The icon for grouped bookmarks

--- @class Browse.Options.Optional
--- @field bookmarks Bookmarks?
--- @field icons Browse.Options.Icons? A table of icons
--- @field persist_grouped_bookmarks_query boolean? Flag to persist grouped bookmarks query

--- @class Browse.Bookmarks.Options : Browse.Options.Optional
--- @field visual_text string? Selection text
--- @field title string? Picker title

--- @class Browse.Configurations.Icons : Browse.Options.Icons
--- @field bookmark_alias string The icon for the bookmark alias
--- @field bookmark_prompt string The icon for bookmark prompt
--- @field grouped_bookmarks string The icon for grouped bookmarks

--- @class Browse.Configurations.Optional : Browse.Options.Optional
--- @field bookmarks Bookmarks? A table of bookmarks
--- @field icons Browse.Configurations.Icons?
--- @field debug boolean? Debug the plugin
--- @field persist_grouped_bookmarks_query boolean? Flag to persist grouped bookmarks query
--- @field use_icon boolean? If we use icons on prompt
--- @field init function?

--- @class Browse.Configurations : Browse.Configurations.Optional
--- @field bookmarks Bookmarks A table of bookmarks
--- @field icons Browse.Configurations.Icons A table of icons
--- @field persist_grouped_bookmarks_query boolean Flag to persist grouped bookmarks query
--- @field debug boolean Debug the plugin
--- @field use_icon boolean If we use icons on prompt
--- @field init function

--- @class Browse.Search.Options
--- @field prompt string?
--- @field visual_text string?
--- @field formatter ((fun(str: string): string) | string)?  -- The formatter can be a function or nil

--- @alias SearchFunction fun(virtual_text: string?) | fun(opt: table)
--- @overload fun(opt: table)

--- @class Browse.RegisterProvider
--- @field name string
--- @field search SearchFunction
--- @field description string

--- @class Browse.Provider : Browse.RegisterProvider
--- @field id number

--- @class Browse.Provider.Input.SearchEngine
--- @field url string
--- @field icon string?
--- @field name string?

--- @alias SearchEngineName 'bing' | 'brave' | 'duckduckgo' | 'ecosia' | 'google' | 'perplexity' | 'startpage' | 'yahoo'
