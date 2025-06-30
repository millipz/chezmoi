local M = {}

function M.run()
    -- Open Safari with Jira boards
    hs.application.launchOrFocus("Safari")
    hs.timer.doAfter(1, function()
        local safari = hs.appfinder.appFromName("Safari")
        if safari then
            -- AppleScript to open certain URLs
            local script = [[
                tell application "Safari"
                    make new document with properties {URL:"https://jira.example.com"}
                    tell window 1
                        set current tab to tab 1
                        make new tab with properties {URL:"https://confluence.example.com"}
                    end tell
                end tell
            ]]
            hs.osascript.applescript(script)
        end
    end)

    -- Possibly open your terminal with a logging command:
    hs.execute("echo 'Start of day log' >> ~/myLogs.txt")

    hs.alert.show("Morning routine complete!")
end

return M
