---Author: jnpngshiii
---Description: A simple logger for Neovim.
---License: GNU General Public License v3.0
---Source: github.com/jnpngshiii/logger.nvim
---
---Requirements:
---  - Neovim 0.10.0 or later
---
---Usage:
---  Suppose you are developing a plugin named `your_awesome_plugin`.
---  ```bash
---  > cd path/to/your_awesome_plugin
---  > tree
---  .
---  |-- database.lua
---  |-- init.lua
---  `-- utils.lua
---  ```
---
---  1. Single file usage:
---
---  1.1. Copy and paste this file to your plugin directory,
---  ```bash
---  > cd path/to/your_awesome_plugin
---  > tree
---  .
---  |-- database.lua
---  |-- init.lua
---  |-- utils.lua
---  `-- Logger.lua # <- copy and paste this file
---  ```
---
---  1.2. Then, modify the return statement at the end of this file.
---  ```lua
---  return Logger:new("your_awesome_plugin", vim.log.levels.INFO)
---  ```
---
---  1.3. Next, add the following code at the beginning of your plugin files.
---  For example, in `database.lua`:
---  ```lua
---  local logger = require("your_awesome_plugin.Logger"):register_source("Database")
---  ```
---  Now, you can use `logger` to log events in your plugin.
---  ```lua
---  logger.info("Hello, world!")
---  ```
---
---  2. Plugin usage:
---
---  2.1. Install this plugin using your favorite plugin manager.
---  For example, using `lazy.nvim`:
---  ```lua
---  {
---    "jnpngshiii/logger.nvim",
---  }
---  ```
---
---  2.2. Then, create a new file named `plugin_logger.lua` in your plugin directory, and add the following code:
---  ```lua
---  local logger = require("logger")
---  local plugin_logger = logger:new("your_awesome_plugin", vim.log.levels.INFO)
---  return plugin_logger
---  ```
---
---  2.3. Next, add the following code at the beginning of your plugin files.
---  For example, in `database.lua`:
---  ```lua
---  local logger = require("your_awesome_plugin.Logger"):register_source("Database")
---  ```
---  Now, you can use `logger` to log events in your plugin.
---  ```lua
---  logger.info("Hello, world!")
---  ```
---
---Examples:
---  ```lua
---  -- Basic usage
---  logger.info("successfully connected to database")
---  -- This will produce a log entry like:
---  -- 2024-07-04 13:53:39 [INFO] <Database> successfully connected to database.
---
---  -- Advanced usage with additional information
---  logger.warn({
---    content = "failed to save database",
---    cause = "the `save_path` is not specified",
---    action = "use the default path instead",
---    extra_info = {
---      user = "root",
---      time = os.time(),
---      file_path = "default/path/to/save/database",
---      mode = "w",
---    },
---  })
---  -- This will produce a log entry like:
---  -- 2024-07-04 13:53:39 [WARN] <Database> failed to save database: the `save_path` is not specified, use the default path instead.
---  --     Extra info: mode = "w"
---  --     Extra info: user = "root"
---  --     Extra info: file_path = "default/path/to/save/database"
---  --     Extra info: time = 1720072419
---
---  -- Logging complex data structures
---  local item = {
---    a_string_field = "string",
---    a_number_field = 100,
---    a_table_field = { 1, 2, 3 },
---    a_function_field = function() return "function" end,
---    a_wrong_field = "this is a wrong field",
---  }
---  logger.error({
---    content = "failed to add item",
---    cause = "health check failed",
---    extra_info = {
---      user = "foo",
---      time = os.time(),
---      the_item = item,
---    },
---  })
---  -- This will produce a log entry like:
---  -- 2024-07-04 13:53:39 [ERROR] <Database> failed to add item: health check failed.
---  --     Extra info: the_item = {
---  --       a_function_field = <function 1>,
---  --       a_number_field = 100,
---  --       a_string_field = "string",
---  --       a_table_field = { 1, 2, 3 },
---  --       a_wrong_field = "this is a wrong field"
---  --     }
---  --     Extra info: user = "foo"
---  --     Extra info: time = 1720072419
---  ```

-- TODO: Dynamically change log level
-- TODO: Manange all loggers in one place (`find`, ...)

--------------------
-- Class Event
--------------------

---@class Event
---@field level number Level of the event.
---Example:
---  ```
---  vim.log.levels.TRACE (0)
---  vim.log.levels.DEBUG (1)
---  vim.log.levels.INFO (2)
---  vim.log.levels.WARN (3)
---  vim.log.levels.ERROR (4)
---  ```
---@field source string Source of the event.
---Example:
---  ```
---  "Main"
---  "Database"
---  "Security"
---  ```
---@field content string Content of the event.
---Please do not use any punctuation marks at the end.
---Example:
---  ```
---  "failed to open file"
---  "cannot connect to database"
---  "invalid password"
---  ```
---@field cause string Cause of the event. Default: "not specified".
---Please do not use any punctuation marks at the end.
---Example:
---  ```
---  "the file is not found"
---  "the database is not running"
---  "the password is too short"
---  ```
---@field action string Action used to handle the event. Default: "not specified".
---Please do not use any punctuation marks at the end.
---Example:
---  ```
---  "create a new file instead"
---  "start the database"
---  "change the password"
---  ```
---@field extra_info table Additional information of the event. Default: `{}`.
---Example:
---  ```
---  {
---    file_path = "path/to/file",
---    mode = "w"
---  }
---  ```
---@field timestamp string Timestamp of the event. Default: `os.date("%Y-%m-%d %H:%M:%S")`.
local Event = {}
Event.__index = Event

---Create a new event.
---@param level number Level of the event.
---@param source string Source of the event.
---@param content string The event. Please do not use any punctuation marks at the end.
---@param cause? string Cause of the event. Please do not use any punctuation marks at the end. Default: "not specified".
---@param action? string Action used to handle the event. Please do not use any punctuation marks at the end. Default: "not specified".
---@param extra_info? table Additional information of the event. Default: `{}`.
---@return Event event The created event.
function Event:new(level, source, content, cause, action, extra_info)
  local event = {
    level = level,
    source = source,
    content = content,
    cause = cause or "not specified",
    action = action or "not specified",
    extra_info = extra_info or {},
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
  }
  event.__index = event
  setmetatable(event, Event)

  return event
end

---Convert an event to a massage.
---@return string msg The converted message.
function Event:to_msg()
  local content = self.content
  local cause = ""
  local action = ""
  if self.cause ~= "not specified" then
    cause = ": " .. self.cause
  end
  if self.action ~= "not specified" then
    action = ", " .. self.action
  end

  local msg = string.format(
    "%s [%s] <%s> %s%s%s.",
    self.timestamp,
    vim.lsp.log_levels[self.level],
    self.source,
    content,
    cause,
    action
  )

  for extra_info_name, extra_info_content in pairs(self.extra_info) do
    msg = msg
      .. "\n    Extra info: "
      .. extra_info_name
      .. " = "
      .. vim.inspect(extra_info_content, { depth = 2, indent = "      " })
    if msg:sub(-1) == "}" then
      msg = msg:sub(1, -2) .. "    }"
    end
  end

  return msg
end

--------------------
-- Class Logger
--------------------

---@class Logger
---@field log_path string File path of the logger.
---Default: `vim.fn.stdpath("data") .. "/" .. {plugin_name} .. "/" .. "logs" .. "/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log"`.
---@field log_level number Log level of the logger. Event with level lower than this will not be logged.
---Default: `vim.log.levels.INFO`.
---@field events Event Logged events of the logger.
local Logger = {}
Logger.__index = Logger

----------
-- Basic methods
----------

---Create a new logger for a plugin.
---@param plugin_name string Which plugin is using this logger.
---Log file will be saved in `vim.fn.stdpath("data") .. "/" .. {plugin_name} .. "/" .. "logs"`.
---@param log_level number Log level of the logger. Event with level lower than this will not be logged.
---Default: `vim.log.levels.INFO`.
---@return Logger logger The create logger.
function Logger:new(plugin_name, log_level)
  local log_dir = vim.fn.stdpath("data") .. "/" .. plugin_name .. "/" .. "logs"
  vim.fn.mkdir(log_dir, "p")

  local logger = {}
  logger.log_path = log_dir .. "/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log"
  logger.log_level = log_level
  logger.events = {}

  logger.__index = logger
  setmetatable(logger, Logger)

  return logger
end

---Save a message to the log file.
---@param msg string The message to be saved.
---@return nil
function Logger:save(msg)
  local file, cause = io.open(self.log_path, "a")
  if not file then
    vim.schedule(function()
      vim.notify("Failed to save msg: " .. cause, vim.log.levels.ERROR)
    end)
    return
  end

  file:write(msg .. "\n")
  file:close()
end

---Internal method to handle logging.
---@param level number Level of the event.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---Can be a table with keys: `content`, `cause?`, `action?`, and `extra_info?`, or a string which is the `content` of the event.
---@return nil
function Logger:log(level, source, event_info)
  if level < self.log_level then
    return
  end

  if not vim.tbl_contains({ 0, 1, 2, 3, 4 }, level) then
    vim.schedule(function()
      vim.notify("Failed to log event: invalid `level`", vim.log.levels.ERROR)
    end)
    return
  end

  local content
  if type(event_info) == "string" then
    content = event_info
  elseif type(event_info) == "table" then
    content = event_info.content
  end
  if not content then
    vim.schedule(function()
      vim.notify("Failed to log event: `content` is not specified", vim.log.levels.ERROR)
    end)
    return
  end
  local cause = event_info.cause
  local action = event_info.action
  local extra_info = event_info.extra_info
  local event = Event:new(level, source, content, cause, action, extra_info)

  table.insert(self.events, event)
  local msg = event:to_msg()
  vim.schedule(function()
    self:save(msg)
    vim.notify(msg, level)
  end)
end

----------
-- Convenience methods
----------

---Log an [TRACE] event. Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---Can be a table with keys: `content`, `cause?`, `action?`, and `extra_info?`, or a string which is the `content` of the event.
---@return nil
function Logger:trace(source, event_info)
  self:log(vim.log.levels.TRACE, source, event_info)
end

---Log an [DEBUG] event. Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---Can be a table with keys: `content`, `cause?`, `action?`, and `extra_info?`, or a string which is the `content` of the event.
---@return nil
function Logger:debug(source, event_info)
  self:log(vim.log.levels.DEBUG, source, event_info)
end

---Log an [INFO] event. Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---Can be a table with keys: `content`, `cause?`, `action?`, and `extra_info?`, or a string which is the `content` of the event.
---@return nil
function Logger:info(source, event_info)
  self:log(vim.log.levels.INFO, source, event_info)
end

---Log an [WARN] event. Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---Can be a table with keys: `content`, `cause?`, `action?`, and `extra_info?`, or a string which is the `content` of the event.
---@return nil
function Logger:warn(source, event_info)
  self:log(vim.log.levels.WARN, source, event_info)
end

---Log an [ERROR] event. Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---Can be a table with keys: `content`, `cause?`, `action?`, and `extra_info?`, or a string which is the `content` of the event.
---@return nil
function Logger:error(source, event_info)
  self:log(vim.log.levels.ERROR, source, event_info)
end

---Register a new source for this logger.
---Waprper for `Logger:trace`, `Logger:debug`, `Logger:info`, `Logger:warn`, and `Logger:error`.
---@param source string The source for this logger.
---@return table
function Logger:register_source(source)
  return {
    trace = function(event_info)
      self:trace(source, event_info)
    end,
    debug = function(event_info)
      self:debug(source, event_info)
    end,
    info = function(event_info)
      self:info(source, event_info)
    end,
    warn = function(event_info)
      self:warn(source, event_info)
    end,
    error = function(event_info)
      self:error(source, event_info)
    end,
  }
end

--------------------

-- 1. Single file usage:
-- return Logger:register_plugin("your_awesome_plugin", vim.log.levels.INFO)

-- 2. Plugin usage:
return Logger
