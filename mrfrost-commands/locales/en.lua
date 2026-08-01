local Translations = {
    desc = {
        ["send_notify"] = "Send a player a notification",
        ["player"] = "ID",
        ["player_desc"] = "Player",
        ["notify_duration"] = "Duration",
        ["notify_duration_desc"] = "Duration you want the notification to be visible (in seconds)",
        ["message"] = "Message",
        ["message_desc"] = "Message you want to send",
    },
    info = {
        ["notify_send"] = "Notification send to player %{player} !",
        ["notify_no_player"] = "No player with ID %{player} found!"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
