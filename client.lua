-- Command Help
Citizen.CreateThread(function()
    TriggerEvent(
        "chat:addSuggestion",
        "/warn",
        "Warn a player through Staff Watch",
        {
            {name = "id", help = "Enter the server ID of the player you would like to warn."},
            {name = "reason", help = "Enter the reason for the warning."},
        }
    )
    TriggerEvent(
        "chat:addSuggestion",
        "/kick",
        "Kick a player through Staff Watch",
        {
            {name = "id", help = "Enter the server ID of the player you would like to kick."},
            {name = "reason", help = "Enter the reason for the kick."},
        }
    )
    TriggerEvent(
        "chat:addSuggestion",
        "/ban",
        "Ban a player through Staff Watch",
        {
            {name = "id", help = "Enter the server ID of the player you would like to ban."},
            {name = "reason?duration", help = "EX: /ban 3 RDM and VDM?2 Days"},
        }
    )
end)

-- Warning Notifications
local announce = false
local announcemessage = ''

RegisterNetEvent('warnuser')
AddEventHandler('warnuser', function(reason)
    announce = true
    announcemessage = reason

    PlaySoundFrontend(-1, "DELETE","HUD_DEATHMATCH_SOUNDSET", 1)

    Citizen.Wait(7000)
    
	announce = false
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if announce then

            local scaleform = RequestScaleformMovie('mp_big_message_freemode')
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end

            PushScaleformMovieFunction(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
            PushScaleformMovieFunctionParameterString('~y~Staff Warning')
            PushScaleformMovieFunctionParameterString('You were warned for: '..announcemessage)
            PopScaleformMovieFunctionVoid()
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

        else
            Wait(500)
        end
    end
end)