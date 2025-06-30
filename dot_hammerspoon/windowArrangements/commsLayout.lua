-- ~/.hammerspoon/windowArrangements/commsLayout.lua

local logger = require("utilities.logger")
local terminalHelper = require("utilities.terminalHelper")
local layoutHelper = require("utilities.layoutHelper")

local M = {}

function M.activateLayout()
    logger.info("commsLayout", "Activating communications layout")
    
    -- Define our apps
    local apps = {"Microsoft Teams", "Microsoft Outlook", "Calendar", "ghostty"}
    logger.debug("commsLayout", "Apps to arrange", apps)
    
    -- Launch all apps
    for _, app in ipairs(apps) do
        if app == "ghostty" then
            logger.debug("commsLayout", "Launching ghostty with omm")
            terminalHelper.launchAndRunInTerminal("ghostty", "omm")
        else
            logger.debug("commsLayout", "Launching app", {app = app})
            hs.application.launchOrFocus(app)
        end
    end

    -- Wait for all windows to be ready, then apply layout
    layoutHelper.waitForWindows(apps, function()
        local screen = hs.screen.primaryScreen()
        if not screen then 
            logger.error("commsLayout", "No primary screen found")
            return 
        end
        
        logger.debug("commsLayout", "Creating layout configuration")
        local layout = {
            {"ghostty",          nil, screen:getUUID(), hs.geometry.unitrect(0,    0,   0.3, 1.0), nil, nil},
            {"Microsoft Teams",  nil, screen:getUUID(), hs.geometry.unitrect(0.7,  0,   0.3, 1.0), nil, nil},
            {"Microsoft Outlook",nil, screen:getUUID(), hs.geometry.unitrect(0.3,  0,   0.4, 0.5), nil, nil},
            {"Calendar",         nil, screen:getUUID(), hs.geometry.unitrect(0.3,  0.5, 0.4, 0.5), nil, nil},
        }

        layoutHelper.applyLayout(layout, apps)
        
        -- Increase ghostty font size after a longer delay
        logger.debug("commsLayout", "Scheduling font size adjustment for ghostty")
        hs.timer.doAfter(2.0, function()
            local ghostty = hs.application.find("ghostty")
            if ghostty then
                ghostty:activate()
                hs.timer.doAfter(0.1, function()
                    -- Increase font size twice
                    hs.eventtap.keyStroke({"cmd"}, "=")
                    hs.timer.doAfter(0.1, function()
                        hs.eventtap.keyStroke({"cmd"}, "=")
                        logger.debug("commsLayout", "Ghostty font size adjusted")
                    end)
                end)
            else
                logger.warn("commsLayout", "Could not find ghostty for font adjustment")
            end
        end)
    end)
    
    logger.info("commsLayout", "Communications layout activation completed")
end

return M
