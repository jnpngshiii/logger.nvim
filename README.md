# logger.nvim

A simple logging system for Neovim plugins.

## :star2: Features

- Easy to integrate with existing Neovim plugins
- Support for multiple log sources within a plugin
- Structured logging with support for content, cause, action, and extra information

## :electric_plug: Requirements

- Neovim >= v0.10.0

## :package: Installation

Install via your favorite package manager. For example, using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jnpngshiii/logger.nvim",
}
```

Or, using [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim):

```vim
:Rocks install logger.nvim
```

## :books: Usage

There are two ways to use `logger.nvim` in your plugin:

### Single file usage

1. Copy the `Logger.lua` file to your plugin directory.
2. Modify the return statement at the end of `Logger.lua`:

```lua
return Logger:new("your_awesome_plugin", vim.log.levels.INFO)
```

3. In your plugin files (e.g, `database.lua`), add:

```lua
local logger = require("your_awesome_plugin.Logger"):register_source("Database")
logger.info("hello world")
-- This will produce a log entry like:
-- 2024-07-04 13:51:33 [INFO] <Database> hello world.
```

### Plugin usage

1. Install via your favorite package manager.
2. In your plugin files (e.g, `utils.lua`), add:

```lua
local Logger = require("logger").register_plugin("your_awesome_plugin", vim.log.levels.INFO)
Logger:debug("Utils", "hello world")
-- whoops, no output at all...
Logger:info("Utils", "hello world")
-- 2024-07-04 13:52:42 [INFO] <Utils> hello world.

-- If you do not want to write "Utils" every time, you can use `register_source`.
local logger = Logger:register_source("Utils")
logger.warn("I don't have to write 'Utils' anymore")
-- 2024-07-04 13:52:43 [WARN] <Utils> I don't have to write 'Utils' anymore.

-- If you want to use `logger.trace` to debug this utils file,
-- but you do not want to set the global log level to trace to avoid `logger.trace` contamination from other files,
-- you can set a localized log level.
local logger = Logger:register_source("Utils", vim.log.levels.TRACE)
logger.warn("I am running...")
-- 2024-07-04 13:52:43 [Trace] <Utils> I am running...
```

## :clipboard: Examples

Here are some examples of how to use `logger.nvim` in your plugin:

```lua
local logger = require("logger").register_plugin("your_awesome_plugin"):register_source("Database")

-- Basic usage
logger.info("successfully connected to database")
-- 2024-07-04 13:53:39 [INFO] <Database> successfully connected to database.

-- Advanced usage with additional information
logger.warn({
  content = "failed to save database",
  cause = "the `save_path` is not specified",
  action = "use the default path instead",
  extra_info = {
    user = "root",
    time = os.time(),
    file_path = "default/path/to/save/database",
    mode = "w",
  },
})
-- 2024-07-04 13:53:39 [WARN] <Database> failed to save database: the `save_path` is not specified, use the default path instead.
-- Extra info: mode = "w"
-- Extra info: user = "root"
-- Extra info: file_path = "default/path/to/save/database"
-- Extra info: time = 1720072419

-- Logging complex data structures
local item = {
  a_string_field = "string",
  a_number_field = 100,
  a_table_field = { 1, 2, 3 },
  a_function_field = function() return "function" end,
  a_wrong_field = "this is a wrong field",
}
logger.error({
  content = "failed to add item",
  cause = "health check failed",
  extra_info = {
    user = "foo",
    time = os.time(),
    the_item = item,
  },
})
-- 2024-07-04 13:53:39 [ERROR] <Database> failed to add item: health check failed.
-- Extra info: the_item = {
--   a_function_field = <function 1>,
--   a_number_field = 100,
--   a_string_field = "string",
--   a_table_field = { 1, 2, 3 },
--   a_wrong_field = "this is a wrong field"
-- }
-- Extra info: user = "foo"
-- Extra info: time = 1720072419
```

## :dart: Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## :wave: Credits

Created by [jnpngshiii](https://github.com/jnpngshiii).

## :page_with_curl: License

GNU General Public License v3.0
