local plugin_func = require("logger.plugin_func")

--------------------

local M = {}
M.log_utils = require("logger.log_utils")

---Set the log level of a specific logger.
---@param plugin_name string The name of the logger to set the log level.
---@param log_level number The log level to set.
---@return nil
function M.set_log_level(plugin_name, log_level)
  local logger = plugin_func.get_cache().loggers[plugin_name]
  if not logger then
    vim.schedule(function()
      vim.notify("Failed to set log level: invalid `plugin_name`", vim.log.levels.ERROR)
    end)
    return
  end

  if not vim.tbl_contains({ 0, 1, 2, 3, 4 }, log_level) then
    vim.schedule(function()
      vim.notify("Failed to set log level: invalid `level`", vim.log.levels.ERROR)
    end)
    return
  end

  logger.level = log_level
  logger:info("Log level of plugin '" .. plugin_name .. "' is set to " .. log_level)
end

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

  vim.api.nvim_create_user_command("LoggerSetLogLevel", function(opts)
    M.set_log_level(opts.fargs[1], opts.fargs[2])
  end, {
    nargs = "+",
    ---@diagnostic disable-next-line: unused-local
    complete = function(arg_lead, cmd_line, cursor_pos) end,
    desc = "Set the log level of a specific logger.",
  })
end

--------------------

return M
