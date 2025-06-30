-- Logger utility
local M = {}

-- Log levels with numeric values for comparison
M.LEVELS = {
    DEBUG = { name = "DEBUG", value = 1 },
    INFO  = { name = "INFO",  value = 2 },
    WARN  = { name = "WARN",  value = 3 },
    ERROR = { name = "ERROR", value = 4 }
}

-- Default configuration
local config = {
    showAlerts = true,
    logToConsole = true,
    minLevel = M.LEVELS.DEBUG
}

-- Configure logger
function M.configure(options)
    for k, v in pairs(options) do
        config[k] = v
    end
end

-- Internal logging function
local function log(level, module, message, details)
    -- Skip if below minimum level
    if level.value < config.minLevel.value then return end

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logMessage = string.format("[%s][%s][%s] %s", 
        timestamp, 
        level.name, 
        module, 
        message
    )
    
    -- Handle details if present
    if details then
        if type(details) == "table" then
            details = hs.inspect(details)
        end
        logMessage = logMessage .. "\nDetails: " .. details
    end
    
    -- Output to console if enabled
    if config.logToConsole then
        print(logMessage)
    end
    
    -- Show alert for errors if enabled
    if config.showAlerts and level == M.LEVELS.ERROR then
        hs.alert.show(message)
    end
end

-- Create logging functions dynamically
for name, level in pairs(M.LEVELS) do
    M[name:lower()] = function(module, message, details)
        log(level, module, message, details)
    end
end

return M 