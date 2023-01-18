local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add(
    Config.CommandNameNotify, Lang:t("desc.send_notify"),
    {
        { name = Lang:t("desc.player"), help = Lang:t("desc.player_desc") },
        { name = Lang:t("desc.message"), help = Lang:t("desc.message_desc") }
    },
    true,
    function(source, args)

        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        table.remove(args, 1)
        local msg = table.concat(args, ' ')
        if targetPlayer then
            TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, msg) --Change that to the notify function you want to use
            TriggerClientEvent('QBCore:Notify', source,
                Lang:t(
                    "info.notify_send",
                    {
                        player = GetPlayerName(targetPlayer.PlayerData.source)
                    }
                )
                , "success") --Change that to the notify function you want to use
        else
            TriggerClientEvent('QBCore:Notify', source,
                Lang:t(
                    "info.notify_no_player",
                    {
                        player = args[1]
                    }
                )
                , "error") --Change that to the notify function you want to use
        end

    end,
    Config.CommandPermissionNotify
)
