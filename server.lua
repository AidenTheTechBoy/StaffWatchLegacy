-------------------------------------------------------------------------------------------
------------------------------------ADVANCED CONFIGURATION------------------------------------
-------------------------------------------------------------------------------------------
-- In-Game Message (For Advanced Users)
function sendMessage(message, scope)
    TriggerClientEvent('chat:addMessage', scope, {        ----------------------------------------------------------------------------
           color = { 255, 0, 0},                      --- Have a custom chat plugin? Want to change the text format of messages?
           multiline = true,                          --- Edit the TriggerClientEvent() function so it fits your needs!
           args = {"[StaffWatch] "..message}          ----------------------------------------------------------------------------
    })
end



-------------------------------------------------------------------------------------------
---------------DO NOT EDIT BELOW THIS LINE UNLESS YOU ARE A LEGIT DEVELOPER----------------
-------------------------------------------------------------------------------------------
local staffwatch = "https://staffwatch.app"

--Player Connection
AddEventHandler(
    "playerConnecting",
    function(name, setReason, deferrals)
        deferrals.defer()

        if string.find(GetPlayerIdentifier(source, 0), "steam:") then

            local url = staffwatch .. "/api/updateuser?secret=" .. Config.secret
            local bancheck = staffwatch .. "/api/checkban?secret=" .. Config.secret

            local steam = splitstring(GetPlayerIdentifier(source, 0), ":")[2]
            local license = splitstring(GetPlayerIdentifier(source, 1), ":")[2]

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
                            message = inputReplace(message, "appeals", Config.appeal)
                            deferrals.done(message)
                        else
                            for x = 1, 6 do
                                deferrals.update("Verifying User 💙")
                                Wait(200)
                                deferrals.update("Verifying User 🧡")
                                Wait(200)
                            end
                            deferrals.update("Verified User ✅")
                            Wait(2000)
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

-- Report User
RegisterCommand(
    "report",
    function(source, args, rawCommand)
        local sender = splitstring(GetPlayerIdentifier(source, 1), ":")[2]

        local id = table.remove(args, 1)
        local reciever = splitstring(GetPlayerIdentifier(id, 1), ":")[2]

        local reason = table.concat(args, " ")

        local url = staffwatch..'/api/report?secret='..Config.secret..'&sender='..sender..'&reciever='..reciever..'&reason='..urlencode(reason)
        PerformHttpRequest(url, function(statusCode, response, headers)
            print(statusCode)
            if tostring(statusCode) == '0' then
                sendMessage('Connection issue?', source)
                return
            end
            if tostring(statusCode) == '403' then
                sendMessage('Permissions issue?', source)
                return
            end
            if tostring(statusCode) == '400' then
                sendMessage('Invalid Arguments!', source)
                return
            end
            sendMessage('Report Sent!', source)
        end)
    end,
    false
)

-- Warn User
RegisterCommand(
    "warn",
    function(source, args, rawCommand)
        local type = 'warn'
        local staff = splitstring(GetPlayerIdentifier(source, 0), ":")[2]
        local id = table.remove(args, 1)
        local license = splitstring(GetPlayerIdentifier(id, 1), ":")[2]
        local reason = table.concat(args, " ")
        local url = staffwatch..'/api/performaction?secret='..Config.secret..'&type='..type..'&staff='..staff..'&license='..license..'&id='..id..'&reason='..urlencode(reason)
        PerformHttpRequest(url, function(statusCode, response, headers)
            print(statusCode)
            if tostring(statusCode) == '403' then
                sendMessage('Invalid Permissions!', source)
            end
            if tostring(statusCode) == '400' then
                sendMessage('Invalid Arguments!', source)
            end
        end)
    end,
    false
)

-- Kick User
RegisterCommand(
    "kick",
    function(source, args, rawCommand)
        local type = 'kick'
        local staff = splitstring(GetPlayerIdentifier(source, 0), ":")[2]
        local id = table.remove(args, 1)
        local license = splitstring(GetPlayerIdentifier(id, 1), ":")[2]
        local reason = table.concat(args, " ")
        local url = staffwatch..'/api/performaction?secret='..Config.secret..'&type='..type..'&staff='..staff..'&license='..license..'&id='..id..'&reason='..urlencode(reason)
        PerformHttpRequest(url, function(statusCode, response, headers)
            print(statusCode)
            if tostring(statusCode) == '403' then
                sendMessage('Invalid Permissions!', source)
            end
            if tostring(statusCode) == '400' then
                sendMessage('Invalid Arguments!', source)
            end
        end)
    end,
    false
)

-- Ban User
RegisterCommand(
    "ban",
    function(source, args, rawCommand)
        local type = 'ban'
        local staff = splitstring(GetPlayerIdentifier(source, 0), ":")[2]

        local id = table.remove(args, 1)

        local argString = table.concat(args, ' ')
        local combined = splitstring(argString, '?')

        local reason = combined[1]
        local duration = combined[2]

        local license = splitstring(GetPlayerIdentifier(id, 1), ":")[2]
        local url = staffwatch..'/api/performaction?secret='..Config.secret..'&type='..type..'&staff='..staff..'&license='..license..'&id='..id..'&reason='..urlencode(reason)..'&duration='..urlencode(duration)
        PerformHttpRequest(url, function(statusCode, response, headers)
            print(statusCode)
            if tostring(statusCode) == '403' then
                sendMessage('Invalid Permissions!', source)
            end
            if tostring(statusCode) == '400' then
                sendMessage('Invalid Arguments!', source)
            end
        end)
    end,
    false
)

-- RCON Warn User
RegisterCommand(
    "staffwatch_warnuser",
    function(source, args, rawCommand)
        if source == 0 or source == "console" then
            local id = table.remove(args, 1)
            local name = GetPlayerName(id)
            local reason = table.concat(args, " ")
            sendMessage(name .. " (" .. id .. ") has been warned for " .. reason, -1)
            TriggerClientEvent('warnuser', id, reason)
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
            sendMessage(name .. " (" .. id .. ") has been kicked for " .. reason, -1)
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
            sendMessage(name .. " (" .. id .. ") has been banned for " .. reason, -1)
        end
    end,
    false
)

-- Player Join Logs
AddEventHandler('playerConnecting', function()
	TriggerEvent('staffwatch:logData', 'server', '<a href = "/profile?license='..string.gsub(GetPlayerIdentifier(source, 1), 'license:', '')..'">'..GetPlayerName(source)..'</a>'..' joined the server')
end)

-- Player Leave Logs
AddEventHandler('playerDropped', function()
	TriggerEvent('staffwatch:logData', 'server', '<a href = "/profile?license='..string.gsub(GetPlayerIdentifier(source, 1), 'license:', '')..'">'..GetPlayerName(source)..'</a>'..' left the server')
end)

-- Player Death Logs
RegisterServerEvent('playerDiedFromPlayer')
AddEventHandler('playerDiedFromPlayer',function(message, killer_id)
    TriggerEvent('staffwatch:logData', 'server', HighlightableLink(killer_id) .. message .. HighlightableLink(source))
end)

-- Player Death Logs
RegisterServerEvent('playerDied')
AddEventHandler('playerDied',function(message)
    TriggerEvent('staffwatch:logData', 'server', HighlightableLink(source) .. message)
end)

-- Explosion Logging
local explosions = {}
explosions[1] = 'EXPLOSION_GRENADE'
explosions[2] = 'EXPLOSION_GRENADELAUNCHER'
explosions[3] = 'EXPLOSION_STICKYBOMB'
explosions[4] = 'EXPLOSION_MOLOTOV'
explosions[5] = 'EXPLOSION_ROCKET'
explosions[6] = 'EXPLOSION_TANKSHELL'
explosions[7] = 'EXPLOSION_HI_OCTANE'
explosions[8] = 'EXPLOSION_CAR'
explosions[9] = 'EXPLOSION_PLANE'
explosions[10] = 'EXPLOSION_PETROL_PUMP'
explosions[11] = 'EXPLOSION_BIKE'
explosions[12] = 'EXPLOSION_DIR_STEAM'
explosions[13] = 'EXPLOSION_DIR_FLAME'
explosions[14] = 'EXPLOSION_DIR_WATER_HYDRANT'
explosions[15] = 'EXPLOSION_DIR_GAS_CANISTER'
explosions[16] = 'EXPLOSION_BOAT'
explosions[17] = 'EXPLOSION_SHIP_DESTROY'
explosions[18] = 'EXPLOSION_TRUCK'
explosions[19] = 'EXPLOSION_BULLET'
explosions[20] = 'EXPLOSION_SMOKEGRENADELAUNCHER'
explosions[21] = 'EXPLOSION_SMOKEGRENADE'
explosions[22] = 'EXPLOSION_BZGAS'
explosions[23] = 'EXPLOSION_FLARE'
explosions[24] = 'EXPLOSION_GAS_CANISTER'
explosions[25] = 'EXPLOSION_EXTINGUISHER'
explosions[26] = 'EXPLOSION_PROGRAMMABLEAR'
explosions[27] = 'EXPLOSION_TRAIN'
explosions[28] = 'EXPLOSION_BARREL'
explosions[29] = 'EXPLOSION_PROPANE'
explosions[30] = 'EXPLOSION_BLIMP'
explosions[31] = 'EXPLOSION_DIR_FLAME_EXPLODE'
explosions[32] = 'EXPLOSION_TANKER'
explosions[33] = 'EXPLOSION_PLANE_ROCKET'
explosions[34] = 'EXPLOSION_VEHICLE_BULLET'
explosions[35] = 'EXPLOSION_GAS_TANK'
explosions[36] = 'EXPLOSION_BIRD_CRAP'

AddEventHandler("explosionEvent", function(sender, ev)
    local type = ev["explosionType"]

    if type == 0 then
        return
    end

    TriggerEvent('staffwatch:logData', 'server', '<a href = "/profile?license='..string.gsub(GetPlayerIdentifier(sender, 1), 'license:', '')..'">'..GetPlayerName(sender)..'</a>'..' caused an explosion ('..explosions[type]..').')
end)

-- Logging System
RegisterNetEvent('staffwatch:logData')
AddEventHandler('staffwatch:logData', function(type, content)

    if type == 'chat' then
        local license = splitstring(GetPlayerIdentifier(source, 1), ':')[2]
        local url = staffwatch..'/api/log?secret='..Config.secret..'&type='..type..'&license='..license..'&content='..urlencode(content)
        PerformHttpRequest(url, function(statusCode, response, headers)
            if statusCode ~= 200 then
                print('StaffWatch Log Returned Status -> ' .. statusCode)
            end
        end)
        return
    end

    local url = staffwatch..'/api/log?secret='..Config.secret..'&type='..type..'&content='..urlencode(content)
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode ~= 200 then
            print('StaffWatch Log Returned Status -> ' .. statusCode)
        end
    end)
    
end)

-- Required Functions
function HighlightableLink(source)
    print(source)
    print(GetPlayerIdentifier(source, 1))
    return '<a href = "/profile?license='..string.gsub(GetPlayerIdentifier(source, 1), 'license:', '')..'">'..GetPlayerName(source)..'</a>'
end

function inputReplace(message, hint, content)
    return message:gsub("{" .. hint .. "}", content)
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function splitstring(str, delim)
    local t = {}

    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
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
