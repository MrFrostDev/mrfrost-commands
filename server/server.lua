local QBCore = exports['qb-core']:GetCoreObject()

-- Add a new command to the qb-core command system
QBCore.Commands.Add(
    Config.CommandNameNotify, Lang:t("desc.send_notify"),
    -- Command arguments, in this case player id, duration in seconds, and message
    {
        { name = Lang:t("desc.player"), help = Lang:t("desc.player_desc") },
        { name = Lang:t("desc.notify_duration"), help = Lang:t("desc.notify_duration_desc") },
        { name = Lang:t("desc.message"), help = Lang:t("desc.message_desc") }
    },
    -- Whether or not the command is restricted to certain players
    true,
    function(source, args)
        -- Get the player object by the given ID
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        -- Remove the player id from the args table
        table.remove(args, 1)
        -- Get the duration in seconds and remove it from the args table
        local duration = tonumber(args[1]) * 1000
        table.remove(args, 1)
        -- Concatenate the remaining args to form the message
        local msg = table.concat(args, ' ')
        if targetPlayer then
            -- Send the notification to the target player
            TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, msg, 'primary', duration)
            -- Send a success message to the sender
            TriggerClientEvent('QBCore:Notify', source,
                Lang:t(
                    "info.notify_send",
                    {
                        player = GetPlayerName(targetPlayer.PlayerData.source)
                    }
                )
                , "success")
        else
            -- Send an error message to the sender if the player doesn't exist
            TriggerClientEvent('QBCore:Notify', source,
                Lang:t(
                    "info.notify_no_player",
                    {
                        player = args[1]
                    }
                )
                , "error")
        end
    end,
    -- The permission required to run the command
    Config.CommandPermissionNotify
)
