local Logger = require("logger.Logger")
local plugin_data = require("logger.plugin_data")

--------------------

local plugin_func = {}

---Create a logger and register it to the specified plugin.
---@param plugin_name string Which plugin is using this logger.
---@param log_level number Log level of the logger. Event with level lower than this will not be logged.
---@return Logger logger The create logger.
function plugin_func.register_plugin(plugin_name, log_level)
  local logger = Logger:new(plugin_name, log_level)
  plugin_data.cache.loggers[plugin_name] = logger

  return logger
end

--------------------

return plugin_func
