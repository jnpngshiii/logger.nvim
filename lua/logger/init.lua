local Logger = require("logger.Logger")
local plugin_func = require("logger.plugin_func")

--------------------

local M = {}

---Create and register a logger for the specified plugin.
---If the logger is not exist, a new logger will be created with the specified log level.
---If already registered, just return the existing logger.
---@param plugin string Which plugin is using this logger.
---@param log_level? number Log level of the logger.
---Default: `vim.log.levels.INFO`.
---@return Logger logger The registered logger.
function M.register_plugin(plugin, log_level)
  log_level = log_level or vim.log.levels.INFO

  local logger = plugin_func.get_cache().loggers[plugin]
  if not logger then
    logger = Logger:new(plugin, log_level)
    plugin_func.get_cache().loggers[plugin] = logger
  end

  return logger
end

----Set up the plugin.
---@param user_config table User configuration. Used to override the default configuration.
---@return nil
function M.setup(user_config)
  -- Set the plugin configuration.

  user_config = user_config or {}
  plugin_func.set_config(user_config)

  -- Set the plugin commands.
end

--------------------

M.log_utils = require("logger.log_utils")

return M
