

logging = logging or "none"
local function logger(level, message, description)

  description = tostring(description) or "nil"

  if logging ~= "none" then

    if level == 1 and logging == "warning"  then
      log(serpent.block(message).." - "..description)
    end

    if level == 2 and logging == "all" then
      log(serpent.block(message))
    end

  end
end

---@param message string
---@param description? string
function info(message, description)
  logger(2, message, description)
end
---@param message string
---@param description? string
function warning(message, description)
  logger(1, message, description)
end