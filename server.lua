----------------------
--- StaffWatch 1.0 ---
----------------------

-------------------------------------------------------------------------------------------
------------------------------------BASIC CONFIGURATION------------------------------------
-------------------------------------------------------------------------------------------

-- Authentication Secret: This value can be found in the settings page of the staff panel.
local secret = "ENTERYOURCOMMUNITYSECRETHERE"

-- Ban Appeal Link: This link will be displayed in the ban message, the most common post is a discord link.
local appeal = "appeals.example.com"
-------------------------------------------------------------------------------------------










-------------------------------------------------------------------------------------------
------------------------------------ADVANCED CONFIGURATION------------------------------------
-------------------------------------------------------------------------------------------
-- In-Game Message (For Advanced Users)
function sendMessage(message)
    --TriggerClientEvent('chat:addMessage', -1, {        ----------------------------------------------------------------------------
    --        color = { 255, 0, 0},                      --- Have a custom chat plugin? Want to change the text format of messages?
    --        multiline = true,                          --- Edit the TriggerClientEvent() function so it fits your needs!
    --        args = {"[StaffWatch] "..message}          ----------------------------------------------------------------------------
    --})
    TriggerClientEvent(
        "chat:addMessage",
        -1,
        {
            template = '<div style="color=white; padding: 0.3vw; margin: 0.5vw; background-color: rgba(0, 224, 0, 0.6); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> {0}</div>',
            args = {"[StaffWatch] " .. message}
        }
    )
end
-------------------------------------------------------------------------------------------






-------------------------------------------------------------------------------------
---------------DO NOT EDIT BELOW THIS LINE UNLESS YOU ARE A DEVELOPER----------------
-------------------------------------------------------------------------------------
local staffwatch = "https://staffwatch.app"

--Player Connection
AddEventHandler(
    "playerConnecting",
    function(name, setReason, deferrals)
        deferrals.defer()
        deferrals.update("Verifying User ⏳")

        if string.find(GetPlayerIdentifiers(source)[1], "steam:") then

            local url = staffwatch .. "/api/updateuser?secret=" .. secret
            local bancheck = staffwatch .. "/api/checkban?secret=" .. secret

            local steam = splitstring(GetPlayerIdentifiers(source)[1], ":")[2]
            local license = splitstring(GetPlayerIdentifiers(source)[2], ":")[2]

            url = url .. "&license=" .. license .. "&steam=" .. steam
            bancheck = bancheck .. "&license=" .. license .. "&steam=" .. steam

            for index, value in pairs(GetPlayerIdentifiers(source)) do
                if index > 2 then
                    url = url .. "&" .. value:gsub(":", "=")
                    bancheck = bancheck .. "&" .. value:gsub(":", "=")
                end
            end

            url = url .. "&playername=" .. urlencode(GetPlayerName(source))

            print(url)

            PerformHttpRequest(url, function(statusCode, response, headers)
                print("Updated Used With License (" .. license .. "). Returned Header " .. statusCode)
            end)

            print(bancheck)
            PerformHttpRequest(
                bancheck,
                function(statusCode, response, headers)
                    if response ~= nil and response ~= "null" then
                        local user = json.decode(response)
                        if user["banstatus"] == true then
                            local message =
                                [[
                        ⚠️ You Are Banned From This Server ⚠️
                        --------------------------------------
                        📝 Reason: {reason}
                        👻 Staff: {staff}
                        ⏰ Expiration: {expiration}
                        --------------------------------------
                        ⚙️ Banned From StaffWatch.app
                        --------------------------------------
                        📞 Appeals: {appeals}
                        ]]
                            message = inputReplace(message, "reason", user["reason"])
                            message = inputReplace(message, "expiration", user["end"])
                            message = inputReplace(message, "staff", user["staff"])
                            message = inputReplace(message, "appeals", appeal)
                            deferrals.done(message)
                        else
                            deferrals.update("Verified User ✅")
                            Wait(500)
                            deferrals.done()
                        end
                    else
                        deferrals.update("Unable to verify! Contact server staff!")
                        deferrals.done()
                    end
                end
            )
        else
            setReason([[
                ❌ Steam is required to play on this server! ❌
                ----------------------------------------------------------------------------
                😉 Make sure that you have Steam open in the background, so you can be authenticated and join the server!
                ----------------------------------------------------------------------------
                💙 If you already have steam open, quitting FiveM and Steam.
                💜 Open Steam, and wait until you see the main game page.
                💛 Open FiveM again, and reconnect!
                ----------------------------------------------------------------------------
                🔔 Staff Watch requires the use of Steam to help manage players on the server, as well as to prevent banned players from joining on alt-accounts! For more information, you can visit StaffWatch.app
                ----------------------------------------------------------------------------
                ]])
            CancelEvent()
        end
    end
)

-- RCON Warn User
RegisterCommand(
    "staffwatch_warnuser",
    function(source, args, rawCommand)
        if source == 0 or source == "console" then
            local id = table.remove(args, 1)
            local name = GetPlayerName(id)
            local reason = table.concat(args, " ")
            sendMessage(name .. " (" .. id .. ") has been warned for " .. reason)
        end
    end,
    false
)

-- RCON Kick User
RegisterCommand(
    "staffwatch_kickuser",
    function(source, args, rawCommand)
        if source == 0 or source == "console" then
            local id = table.remove(args, 1)
            local name = GetPlayerName(id)
            local reason = table.concat(args, " ")
            DropPlayer(id, reason)
            sendMessage(name .. " (" .. id .. ") has been kicked for " .. reason)
        end
    end,
    false
)

-- RCON Kick User
RegisterCommand(
    "staffwatch_banuser",
    function(source, args, rawCommand)
        if source == 0 or source == "console" then
            local id = table.remove(args, 1)
            local name = GetPlayerName(id)
            local reason = table.concat(args, " ")
            DropPlayer(id, "You have been banned for: " .. reason .. " (Reconnect for Information)")
            sendMessage(name .. " (" .. id .. ") has been banned for " .. reason)
        end
    end,
    false
)

-- Required Functions
function inputReplace(message, hint, content)
    return message:gsub("{" .. hint .. "}", content)
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function splitstring(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function urlencode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str =
            string.gsub(
            str,
            "([^%w ])",
            function(c)
                return string.format("%%%02X", string.byte(c))
            end
        )
        str = string.gsub(str, " ", "+")
    end
    return str
end
