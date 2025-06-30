-- ~/.hammerspoon/utilities/layoutHelper.lua

-- Layout helper utilities
local logger = require("utilities.logger")
local M = {}

-- Wait for all windows to exist and be ready
function M.waitForWindows(appNames, callback)
    local function checkWindows()
        for _, appName in ipairs(appNames) do
            local app = hs.application.find(appName)
            if not (app and app:mainWindow()) then
                logger.debug("layoutHelper", "Waiting for window", {app = appName})
                -- If any window doesn't exist yet, try again in 0.5 seconds
                hs.timer.doAfter(0.5, checkWindows)
                return
            end
        end
        -- All windows exist, proceed with callback
        logger.info("layoutHelper", "All windows ready", {apps = appNames})
        callback()
    end
    
    checkWindows()
end

-- Apply a layout with common setup (moving to first space, etc)
function M.applyLayout(layout, appNames)
    logger.info("layoutHelper", "Applying layout", {apps = appNames})
    
    local screen = hs.screen.primaryScreen()
    if not screen then
        logger.error("layoutHelper", "No primary screen found!")
        return
    end
    
    -- Apply the layout first
    hs.layout.apply(layout)
    logger.debug("layoutHelper", "Base layout applied")
    
    -- Move windows to first space
    local spaces = hs.spaces.allSpaces()
    if not spaces then
        logger.error("layoutHelper", "Could not get spaces - check permissions")
        return
    end
    
    local screenSpaces = spaces[screen:getUUID()]
    if not screenSpaces or #screenSpaces == 0 then
        logger.error("layoutHelper", "No spaces found for screen", {uuid = screen:getUUID()})
        return
    end
    
    local firstSpace = screenSpaces[1]
    logger.info("layoutHelper", "Moving windows to space", {space = firstSpace})
    
    for _, appName in ipairs(appNames) do
        local app = hs.application.find(appName)
        if app then
            local win = app:mainWindow()
            if win then
                -- Focus the window before moving it
                win:focus()
                hs.timer.doAfter(0.1, function()
                    hs.spaces.moveWindowToSpace(win, firstSpace)
                    logger.debug("layoutHelper", "Moved window to space", {app = appName, space = firstSpace})
                end)
            else
                logger.warn("layoutHelper", "No main window found", {app = appName})
            end
        else
            logger.warn("layoutHelper", "App not found", {app = appName})
        end
    end

    logger.info("layoutHelper", "Layout application completed")
end

return M 