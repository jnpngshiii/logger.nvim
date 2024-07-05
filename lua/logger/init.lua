local plugin_func = require("logger.plugin_func")

--------------------

local M = {}
M.log_utils = require("logger.log_utils")

---Create a logger and register it to the specified plugin.
---@param plugin_name string Which plugin is using this logger.
---@param log_level number Log level of the logger. Event with level lower than this will not be logged.
---@return Logger logger The create logger.
function M.register_plugin(plugin_name, log_level)
  return plugin_func.register_plugin(plugin_name, log_level)
end

----Set up the plugin.
---@param user_config table User configuration. Used to override the default configuration.
---@return nil
function M.setup(user_config)
  user_config = user_config or {}

  -- Merge user config with default config
  plugin_func.set_config(user_config)
end

--------------------

return M
