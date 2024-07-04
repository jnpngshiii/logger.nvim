local plugin_func = require("logger.plugin_func")
local user_func = require("logger.user_func")
user_func.__index = user_func

--------------------

local M = {}
M.__index = M
setmetatable(M, user_func)

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
