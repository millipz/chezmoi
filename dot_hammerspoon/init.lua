-- ~/.hammerspoon/init.lua

-- Hammerspoon configuration
local logger = require("utilities.logger")

-- Config reload hotkey
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
    hs.reload()
    logger.info("init", "Configuration reloaded")
end)

-- Modules
logger.debug("init", "Loading modules")
local terminalHelper = require("utilities.terminalHelper")
local jiraTicketMenu = require("menus.jiraTicketMenu")

-- Window Layouts
logger.debug("init", "Loading layout modules")
local commsLayout     = require("windowArrangements.commsLayout")
local morningRoutine  = require("windowArrangements.morningRoutine")

-- Hotkeys
logger.debug("init", "Setting up hotkeys")
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    logger.debug("init", "Activating communications layout")
    commsLayout.activateLayout()
end)

-- Jira ticket menu hotkey
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "J", function()
    logger.debug("init", "Showing Jira ticket menu")
    jiraTicketMenu.showMenu()
    jiraTicketMenu.refreshTickets()
end)

-- Plover toggle hotkey
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "P", function()
    logger.debug("init", "Toggling Plover output")
    
    -- Save current focus
    local currentApp = hs.application.frontmostApplication()
    local currentWindow = currentApp:mainWindow()
    
    -- Find Plover application
    local plover = hs.application.get("Plover")
    if not plover then
        logger.warn("init", "Plover not found")
        hs.alert.show("Plover not found")
        return
    end
    
    -- Toggle Plover output directly without switching applications
    local script = [[
        tell application "System Events"
            tell process "Plover"
                click menu item "Toggle output" of menu "File" of menu bar 1
            end tell
        end tell
    ]]
    
    local ok, result = hs.osascript.applescript(script)
    if not ok then
        logger.warn("init", "Failed to toggle Plover: " .. tostring(result))
    else
        logger.debug("init", "Plover toggled successfully")
    end
end)

-- Settings app hotkey
hs.hotkey.bind({"cmd", "shift"}, ",", function()
    logger.debug("init", "Opening Settings app")
    hs.application.launchOrFocus("System Settings")
end)

-- Routines
logger.debug("init", "Setting up routines")
hs.timer.doAt("09:00", "1d", function()
    logger.info("init", "Running morning routine")
    morningRoutine.run()
end)

-- Alert
hs.alert.show("Hammerspoon config loaded!")
-- Startup complete
logger.info("init", "Configuration loaded successfully")
