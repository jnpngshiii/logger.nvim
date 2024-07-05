local utils = {}

---Safely call a function.
---If success, returns true and the result of the function call.
---If failure, returns false and a table with the event information.
---@param event_content string The content of event information if the function call fails.
---@param func function The function to call.
---@param ... any Arguments to pass to the function.
---@return boolean success, any result_or_event_info Whether the function call was successful, and the result or event information.
function utils.safe_call(event_content, func, ...)
  assert(type(event_content) == "string", "`event_content` must be a string")
  assert(type(func) == "function", "`func` must be a function")

  local success, result = pcall(func, ...)

  if success then
    return success, result
  else
    event_info = {
      content = event_content,
      cause = result,
      extra_info = {
        func_name = debug.getinfo(func, "n").name or "anonymous function",
        func_args = { ... },
      },
    }
    return success, event_info
  end
end

--------------------

return utils
