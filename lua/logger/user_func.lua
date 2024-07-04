local plugin_func = require("logger.plugin_func")

--------------------

local user_func = {}

---Create a logger and register it to the specified plugin.
---@param plugin_name string Which plugin is using this logger.
---@param log_level number Log level of the logger. Event with level lower than this will not be logged.
---@return Logger logger The create logger.
function user_func.register_plugin(plugin_name, log_level)
  return plugin_func.register_plugin(plugin_name, log_level)
end

--------------------

return user_func
