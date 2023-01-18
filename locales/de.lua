local Translations = {
    desc = {
        ["send_notify"] = "Sende einem Spieler eine Benachrichtigung",
        ["player"] = "ID",
        ["player_desc"] = "Spieler",
        ["message"] = "Nachricht",
        ["message_desc"] = "Die Nachricht die du senden willst",
    },
    info = {
        ["notify_send"] = "Benachrichtigung wurde erfolgreich an %{player} gesendet!",
        ["notify_no_player"] = "Kein Spieler mit ID %{player} gefunden!"
    }
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
