local Logger = require("logger.Logger")
local plugin_data = require("logger.plugin_data")

--------------------

local plugin_func = {}

---Get the plugin configuration.
---@return table plugin_data.config Plugin configuration.
function plugin_func.get_config()
  return plugin_data.config
end

---Set the plugin configuration.
---@param user_config table User configuration. Used to override the default configuration.
---@return nil
function plugin_func.set_config(user_config)
  plugin_data.config = vim.tbl_deep_extend("force", plugin_data.config, user_config)
end

---Get the plugin cache.
---@return table plugin_data.cache Plugin cache.
function plugin_func.get_cache()
  return plugin_data.cache
end

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
