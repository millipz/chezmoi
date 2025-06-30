-- ~/.hammerspoon/utilities/terminalHelper.lua

local logger = require("utilities.logger")
local M = {}  -- We'll return this table at the end

-- Check if a process is running
local function isProcessRunning(processName)
    -- For omm, we need to check for both omm and omm-server
    if processName == "omm" then
        local omm = hs.execute("pgrep -x omm-server")
        logger.debug("terminalHelper", "Checking omm-server process", {running = omm ~= nil and omm ~= ""})
        return omm ~= nil and omm ~= ""
    end
    
    local output = hs.execute("pgrep -x " .. processName)
    logger.debug("terminalHelper", "Checking process: " .. processName, {running = output ~= nil and output ~= ""})
    return output ~= nil and output ~= ""
end

-- Attempt to launch a named terminal app (e.g. "ghostty") and run a command (e.g. "omm")
function M.launchAndRunInTerminal(appName, command)
    logger.info("terminalHelper", "Launching terminal app", {app = appName, command = command})
    
    if appName == "ghostty" and command then
        local isRunning = isProcessRunning(command)
        logger.debug("terminalHelper", "Process status check", {command = command, running = isRunning})
        
        if not isRunning then
            -- Launch ghostty with command directly
            local result = hs.execute("ghostty -e zsh -ic '" .. command .. "'")
            logger.info("terminalHelper", "Launched new ghostty instance", {command = command, success = result ~= nil})
        else
            -- Just focus ghostty if command is already running
            logger.info("terminalHelper", "Focusing existing ghostty instance")
            hs.application.launchOrFocus(appName)
        end
    else
        -- For other apps or no command
        logger.info("terminalHelper", "Launching/focusing app", {app = appName})
        hs.application.launchOrFocus(appName)
    end
end

return M
