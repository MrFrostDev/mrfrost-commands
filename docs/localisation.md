# Localisation

The resource ships two locale files, `locales/en.lua` and `locales/de.lua`.
Translation goes through the qb-core `Locale` object
(`@qb-core/shared/locale.lua`), which the manifest loads before anything else.
Both files set `warnOnMissing = true`, so a missing key prints a warning rather
than failing quietly.

Nine keys in total, and all nine are read on the server. Nothing on this page is
per-player: the language is fixed for the whole server when the resource starts.

## Selecting a language

`locales/en.lua` assigns `Lang = Lang or Locale:new{ ... }`, so it takes effect
only if nothing has claimed `Lang` yet.

`locales/de.lua` is wrapped in `if GetConvar('qb_locale', 'en') == 'de' then`, so
the German set is built only when the standard qb-core locale convar is set to
`de`:

```cfg
setr qb_locale "de"
```

Any other value — including a language this resource does not ship, such as
`fr` — leaves the English set in place.

### Load order

The manifest lists the locale files twice over:

```lua
shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/en.lua',
  'locales/*.lua',
  'config.lua'
}
```

`locales/en.lua` is named explicitly *before* the glob that would also match it.
That is deliberate and it matters: `de.lua` passes `fallbackLang = Lang`, which
only resolves to something useful if the English set already exists. With the
explicit line, it always does, whichever order the glob expands in. Whether the
glob then loads `en.lua` a second time makes no difference, because that file
assigns with `Lang = Lang or ...` and leaves an existing `Lang` alone.

Remove the explicit line and the fallback becomes order-dependent. Leave it.

## Keys

Both files define the same nine keys — none present in one language and missing
from the other.

### `desc`

Everything qb-core shows about the command while a player types it. The first is
the command's own help line; the other six are the name and the help text of
each argument, in order.

| Key | Used as | English | German |
|---|---|---|---|
| `desc.send_notify` | Command help | `Send a player a notification` | `Sende einem Spieler eine Benachrichtigung` |
| `desc.player` | Argument 1, name | `ID` | `ID` |
| `desc.player_desc` | Argument 1, help | `Player` | `Spieler` |
| `desc.notify_duration` | Argument 2, name | `Duration` | `Dauer` |
| `desc.notify_duration_desc` | Argument 2, help | `Duration you want the notification to be visible (in seconds)` | `Dauer die die Benachrichtigung angezeigt werden soll (in Sekunden)` |
| `desc.message` | Argument 3, name | `Message` | `Nachricht` |
| `desc.message_desc` | Argument 3, help | `Message you want to send` | `Die Nachricht die du senden willst` |

The first argument's pair reads oddly next to the other two: its name is `ID`
and its help is just `Player`, where the others spell out what is expected. It
is the only argument whose help line does not explain anything the name has not
already said.

These strings are read once, when `QBCore.Commands.Add` runs at resource start,
and handed to the chat resource as suggestions. Editing a locale file therefore
needs a restart of this resource to show up in chat.

### `info`

The two replies to the sender. Both take one substitution, `%{player}`.

| Key | English | German |
|---|---|---|
| `info.notify_send` | `Notification send to player %{player} !` | `Benachrichtigung wurde erfolgreich an %{player} gesendet!` |
| `info.notify_no_player` | `No player with ID %{player} found!` | `Kein Spieler mit ID %{player} gefunden!` |

`info.notify_send` is filled with the target's player name from
`GetPlayerName`, so the English wording — "to player &lt;name&gt;" — is right,
even though the key sits next to one that talks about ids. It also has a stray
space before the exclamation mark, and "send" where it means "sent".

`info.notify_no_player` promises an id and is given something else entirely; see
[known-issues.md](known-issues.md).

## What is not translatable

- **The notification itself.** The message is whatever the sender typed. It is
  passed through unchanged, and no locale file is involved.
- **The rejection for too few arguments.** That comes from qb-core, not from
  here: `error.missing_args2`, *All arguments must be filled out!*, in qb-core's
  own `locale/` folder. It follows `qb_locale` the same way, but translating it
  means translating qb-core.
- **FiveM's access-denied line** when a player without the permission tries the
  command. That is the server core, below qb-core.

## Adding a language

1. Copy `locales/en.lua` to `locales/<code>.lua`.
2. Replace the assignment at the bottom with the guarded form from `de.lua`,
   using your own language code:

   ```lua
   if GetConvar('qb_locale', 'en') == '<code>' then
       Lang = Locale:new({
           phrases = Translations,
           warnOnMissing = true,
           fallbackLang = Lang,
       })
   end
   ```

3. Translate the values, keeping all nine keys and keeping `%{player}` in both
   `info` strings.
4. Leave `locales/en.lua` first in the manifest. The glob picks up the new file
   on its own; it does not need its own line.
