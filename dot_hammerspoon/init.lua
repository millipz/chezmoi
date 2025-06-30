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
