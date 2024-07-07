---Author: jnpngshiii
---Description: A simple logger for Neovim.
---License: GNU General Public License v3.0
---Source: github.com/jnpngshiii/logger.nvim
---Requirements:
---  - Neovim 0.10.0 or later

--------------------
-- Class Event
--------------------

---@class Event
---@field level number Level of the event.
---Example:
---  vim.log.levels.TRACE
---  vim.log.levels.DEBUG
---  vim.log.levels.INFO
---  vim.log.levels.WARN
---  vim.log.levels.ERROR
---@field source string Source of the event.
---Example:
---  "Main"
---  "Database"
---  "Security"
---@field content string Content of the event.
---Please do not use punctuation at the end.
---Example:
---  "failed to open file"
---  "cannot connect to database"
---  "invalid password"
---@field cause string Cause of the event.
---Please do not use punctuation at the end.
---Default: `"not specified"`.
---Example:
---  "the file is not found"
---  "the database is not running"
---  "the password is too short"
---@field action string Action used to handle the event.
---Please do not use punctuation at the end.
---Default: `"not specified"`.
---Example:
---  "create a new file instead"
---  "start the database"
---  "change the password"
---@field extra_info table Additional information of the event.
---Default: `{}`.
---Example:
---  {
---    file_path = "path/to/file",
---    mode = "w"
---  }
---@field timestamp string Timestamp of the event.
---Default: `os.date("%Y-%m-%d %H:%M:%S")`.
local Event = {}
Event.__index = Event

---Create a new event.
---@param level number Level of the event.
---@param source string Source of the event.
---@param content string Content of the event.
---Please do not use punctuation at the end.
---@param cause? string Cause of the event.
---Please do not use punctuation at the end.
---Default: `"not specified"`.
---@param action? string Action used to handle the event.
---Please do not use punctuation at the end.
---Default: `"not specified"`.
---@param extra_info? table Additional information of the event.
---Default: `{}`.
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
  setmetatable(event, Event)

  return event
end

---Convert an event to a massage.
---@return string msg The converted message.
function Event:to_msg()
  -- Get main message --

  local content, cause, action = self.content, self.cause, self.action
  if cause ~= "not specified" then
    cause = ": " .. self.cause
  end
  if action ~= "not specified" then
    action = ", " .. self.action
  end
  local msg = string.format("%s%s%s.", content, cause, action)

  -- Get prefix --

  msg = string.format("%s [%s] <%s> %s", self.timestamp, vim.lsp.log_levels[self.level], self.source, msg)
  -- Get extra info --

  for extra_info_name, extra_info_content in pairs(self.extra_info) do
    msg = msg
      .. "\nExtra info: "
      .. extra_info_name
      .. " = "
      .. vim.inspect(extra_info_content, { depth = 2, indent = "  " })
  end

  return msg
end

--------------------
-- Class Logger
--------------------

---@class Logger
---@field log_path string File path of the logger.
---Default: `vim.fn.stdpath("data") .. "/" .. {plugin_name} .. "/" .. "logs" .. "/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log"`.
---@field log_level number Log level of the logger.
---Event with level lower than this will not be logged.
---Default: `vim.log.levels.INFO`.
---@field source_log_levels table Log levels of each source.
---Set this to override the default log level of the logger.
---See `Logger:register_source` for more information.
---Default: `{}`.
---@field events Event Logged events of the logger.
local Logger = {}
Logger.__index = Logger

----------
-- Basic methods
----------

---Create a new logger for a plugin.
---@param plugin string Which plugin is using this logger.
---Log file will be saved in `vim.fn.stdpath("data") .. "/" .. {plugin_name} .. "/" .. "logs"`.
---@param log_level number Log level of the logger.
---Event with level lower than this will not be logged.
---Default: `vim.log.levels.INFO`.
---@return Logger logger The create logger.
function Logger:new(plugin, log_level)
  local log_dir = vim.fn.stdpath("data") .. "/" .. plugin .. "/" .. "logs"
  vim.fn.mkdir(log_dir, "p")

  local logger = {
    log_path = log_dir .. "/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log",
    log_level = log_level or vim.log.levels.INFO,
    source_log_levels = {},
    events = {},
  }
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
      vim.notify("failed to save msg: " .. cause, vim.log.levels.ERROR)
    end)
    return
  end

  file:write(msg .. "\n")
  file:close()
end

---Create a new event and log it.
---@param level number Level of the event.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---@return Event? event The created event.
function Logger:log(level, source, event_info)
  if not vim.tbl_contains({ 0, 1, 2, 3, 4 }, level) then
    vim.schedule(function()
      vim.notify("failed to log event: invalid `level`", vim.log.levels.ERROR)
    end)
    return
  end

  local local_log_level = self.source_log_levels[source] or self.log_level
  if level < local_log_level then
    return
  end

  local content, cause, action, extra_info
  if type(event_info) == "string" then
    content = event_info
  elseif type(event_info) == "table" then
    content = event_info.content
    cause = event_info.cause
    action = event_info.action
    extra_info = event_info.extra_info
  else
    vim.schedule(function()
      vim.notify("failed to log event: invalid `event_info` type: " .. vim.inspect(event_info), vim.log.levels.ERROR)
    end)
    return
  end
  if not content then
    vim.schedule(function()
      vim.notify("failed to log event: `content` is not specified", vim.log.levels.ERROR)
    end)
    return
  end

  local event = Event:new(level, source, content, cause, action, extra_info)
  table.insert(self.events, event)

  local msg = event:to_msg()
  self:save(msg)

  vim.schedule(function()
    vim.notify(msg, level)
  end)

  return event
end

----------
-- Convenience methods
----------

---Log an [TRACE] event.
---Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---@return Event? event The created event.
function Logger:trace(source, event_info)
  return self:log(vim.log.levels.TRACE, source, event_info)
end

---Log an [DEBUG] event.
---Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---@return Event? event The created event.
function Logger:debug(source, event_info)
  return self:log(vim.log.levels.DEBUG, source, event_info)
end

---Log an [INFO] event.
---Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---@return Event? event The created event.
function Logger:info(source, event_info)
  return self:log(vim.log.levels.INFO, source, event_info)
end

---Log an [WARN] event.
---Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---@return Event? event The created event.
function Logger:warn(source, event_info)
  return self:log(vim.log.levels.WARN, source, event_info)
end

---Log an [ERROR] event.
---Wrapper for `Logger:log`.
---@param source string Source of the event.
---@param event_info table|string Information of the event to be logged.
---@return Event? event The created event.
function Logger:error(source, event_info)
  return self:log(vim.log.levels.ERROR, source, event_info)
end

---Register a new source for this logger.
---@param source string A source of the logger.
---@param log_level? number Log level of the source.
---This value will override the default log level of the logger.
---So, you can use this to set different log levels for different sources.
---Default: `nil`.
---@return table
function Logger:register_source(source, log_level)
  self.source_log_levels[source] = log_level

  return {
    ---@param event_info table|string Information of the event to be logged.
    trace = function(event_info)
      return self:trace(source, event_info)
    end,

    ---@param event_info table|string Information of the event to be logged.
    debug = function(event_info)
      return self:debug(source, event_info)
    end,

    ---@param event_info table|string Information of the event to be logged.
    info = function(event_info)
      return self:info(source, event_info)
    end,

    ---@param event_info table|string Information of the event to be logged.
    warn = function(event_info)
      return self:warn(source, event_info)
    end,

    ---@param event_info table|string Information of the event to be logged.
    error = function(event_info)
      return self:error(source, event_info)
    end,
  }
end

--------------------

-- 1. Single file usage:
-- return Logger:register_plugin("your_awesome_plugin", vim.log.levels.INFO)

-- 2. Plugin usage:
return Logger
