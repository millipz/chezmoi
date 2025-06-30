-- Jira menu integration
local logger = require("utilities.logger")

-- Load configuration
local config_ok, config = pcall(require, "config")
if not config_ok then
    logger.error("jiraMenu", "Failed to load config.lua. Please copy config.template.lua to config.lua and fill in your values.")
    return {
        showMenu = function() hs.alert.show("⚠️ Jira menu not configured. Check the logs for details.") end,
        refreshTickets = function() end
    }
end

-- Configuration
local jira_config = config.jira
local update_interval = 300  -- 5 minute refresh
local current_menu_items = {{title = "Fetching tickets...", disabled = true}}
local popup_menu = hs.menubar.new(false)

-- Helper functions
local function create_jira_url(endpoint, params)
    local base_url = string.format("https://%s/rest/api/3/%s", jira_config.domain, endpoint)
    if not params then return base_url end
    
    local param_strings = {}
    for k, v in pairs(params) do
        table.insert(param_strings, k .. "=" .. hs.http.encodeForQuery(v))
    end
    return base_url .. "?" .. table.concat(param_strings, "&")
end

local function get_headers()
    return {
        ["Authorization"] = "Basic " .. hs.base64.encode(jira_config.email .. ":" .. jira_config.api_token),
        ["Accept"] = "application/json",
        ["User-Agent"] = "Hammerspoon-Jira-Integration"
    }
end

local function update_menu_error(message)
    current_menu_items = {{title = "⚠️ " .. message .. " (click to retry)", fn = fetch_jira_tickets}}
end

local function handle_api_error(status, body, headers, url)
    local error_msg = status == -1 and "Connection error" or
                     status == 401 and "Authentication error" or
                     status == 403 and "Permission error" or
                     "API error: " .. status
    
    logger.error("jiraMenu", error_msg, {
        status = status,
        url = url,
        response = pcall(hs.json.decode, body or "") and select(2, pcall(hs.json.decode, body)) or body
    })
    update_menu_error(error_msg)
end

-- Core functions
local function show_jira_menu()
    if popup_menu then
        popup_menu:setMenu(current_menu_items)
        popup_menu:popupMenu(hs.mouse.getAbsolutePosition())
    else
        logger.error("jiraMenu", "Failed to create popup menu")
    end
end

local function fetch_jira_tickets()
    -- First verify authentication
    hs.http.asyncGet(create_jira_url("myself"), get_headers(), function(status, body)
        if status ~= 200 then
            handle_api_error(status, body, nil, "auth check")
            return
        end
        
        -- Fetch tickets
        local ticket_url = create_jira_url("search", {
            jql = "assignee in (currentUser()) AND status != Done",  -- Exclude Done tickets in JQL
            fields = "summary,status",
            maxResults = "50"
        })
        
        hs.http.asyncGet(ticket_url, get_headers(), function(status, body)
            if status ~= 200 then
                handle_api_error(status, body, nil, ticket_url)
                return
            end
            
            local success, result = pcall(hs.json.decode, body)
            if not success then
                update_menu_error("Failed to parse response")
                return
            end
            
            local menu_items = {}
            for _, issue in ipairs(result.issues) do
                table.insert(menu_items, {
                    title = issue.key .. ": " .. issue.fields.summary,
                    fn = function(modifiers) 
                        -- Check if alt key is pressed
                        if modifiers and modifiers.alt then
                            hs.urlevent.openURL("https://" .. jira_config.domain .. "/browse/" .. issue.key)
                        else
                            hs.pasteboard.setContents(issue.key)
                            hs.alert.show("Copied: " .. issue.key)
                        end
                    end
                })
            end
            
            if #menu_items == 0 then
                menu_items = {{title = "No active tickets found", disabled = true}}
            end
            
            table.insert(menu_items, {title = "-"})
            table.insert(menu_items, {title = "↻ Refresh Tickets", fn = fetch_jira_tickets})
            
            current_menu_items = menu_items
            logger.info("jiraMenu", "Successfully fetched tickets", {count = #menu_items})
        end)
    end)
end

-- Initialize
logger.info("jiraMenu", "Initializing Jira menu")
fetch_jira_tickets()
hs.timer.doEvery(update_interval, fetch_jira_tickets)

return {
    showMenu = show_jira_menu,
    refreshTickets = fetch_jira_tickets
}