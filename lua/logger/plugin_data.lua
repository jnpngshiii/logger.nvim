local plugin_data = {}

----------
-- Class plugin_data.config
----------

---@class plugin_data.config
plugin_data.config = {}

----------
-- Class plugin_data.cache
----------

---@class plugin_data.cache
---@field loggers table<string, Logger> Key is the logger name, value is the logger instance.
plugin_data.cache = {
  loggers = {},
}

--------------------

return plugin_data
