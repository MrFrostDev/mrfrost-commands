# Known issues

Findings from a read-through of the source. Nothing here has been fixed — the
code is published as it was last run, and there is no live server to test
changes against. Line numbers refer to the files as they are in this repository.

The resource is one command in fifty lines, so the list is short. Two of the
entries below are reachable by typing the command slightly wrong, and one of
them takes the whole command down.

## Behaviour

### A non-numeric duration ends the command with a Lua error

`mrfrost-commands/server/server.lua:20`

```lua
local duration = tonumber(args[1]) * 1000
```

`tonumber` returns `nil` for anything it cannot read as a number, and `nil * 1000`
throws. The handler stops there: the target gets no notification, the sender
gets no reply, and the only trace is an error line in the server console.

qb-core's `argsrequired` does not prevent this. It compares the *number* of
arguments against the three that were described and never looks at what they
are, so `/notify 3 soon the shop closes` passes that check and reaches the
multiplication with `soon`.

This is the most likely way to hit the resource wrong, because the argument
order is not obvious: the duration sits between the id and the message, and
leaving it out — `/notify 3 the shop is closing` — is exactly the case that
throws.

A fix, keeping the failure inside the command rather than in the console:

```lua
local duration = tonumber(args[1])
if not duration then
    return TriggerClientEvent('QBCore:Notify', source, Lang:t("info.notify_no_duration"), "error")
end
duration = duration * 1000
```

with `info.notify_no_duration` added to both locale files. The smaller version,
`local duration = (tonumber(args[1]) or 5) * 1000`, keeps the command alive but
silently swallows the first word of the message as though it were the duration.

### The "no player" reply names the message, not the id

`mrfrost-commands/server/server.lua:38-45`

```lua
player = args[1]
```

Two arguments have been removed from `args` by the time this line runs, so
`args[1]` is the first word of the message. Sending to a player who is not
connected reports the wrong thing:

```
/notify 999 5 hello there   ->   No player with ID hello found!
```

The id that actually failed is never shown, which makes the reply actively
misleading rather than merely unhelpful — the sender is told to check something
they did not type.

A fix is to keep the id before it is consumed:

```lua
local targetId = args[1]
local targetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
```

and use `player = targetId` in the error branch.

### A duration of zero or less leaves the notification on screen

`mrfrost-commands/server/server.lua:20` and `:26`

Nothing bounds the duration. It is multiplied by 1000 and handed to qb-core as
the notification length, and qb-core's notification UI only schedules the
removal when that length is above zero — with `0` or a negative number it draws
the notification and never takes it away. `/notify 3 0 test` therefore pins a
message to that player's screen until something else resets the UI.

The same gap at the other end lets a sender ask for any length they like:
`/notify 3 86400 test` is a notification that outlasts most sessions.

A fix would clamp the value before it is sent, for example
`duration = math.max(1, math.min(tonumber(args[1]) or 5, 60)) * 1000`.

### A mistyped id scans every connected player before giving up

`mrfrost-commands/server/server.lua:16`

```lua
local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
```

`tonumber` turns a mistyped id into `nil`. `QBCore.Functions.GetPlayer` reads a
non-numeric argument as a player *identifier* rather than a server id, and
resolves it by walking every connected player and every identifier each of them
has, comparing against `nil` — which matches nothing, so it walks the whole list
and returns `0`. The result is `QBCore.Players[0]`, `nil`, and the failure path.

The outcome is correct and nothing errors; it is the work done to get there that
is wasted, and it grows with the player count. Reading the number once and
checking it, as in the fix above, removes the call entirely for a bad id.

It also means the identifier lookup that `GetPlayer` offers can never be used
here — `tonumber` has already destroyed the string by the time it is called.

### Run from the server console, the sender's reply goes nowhere

`mrfrost-commands/server/server.lua:28` and `:38`

Both replies to the sender are `TriggerClientEvent`s addressed to `source`.
Executed from the console, `source` is `0`, which is not a connected client, so
the console operator sees neither the confirmation nor the "no player" error.
The notification to the target is unaffected and still arrives.

A fix would branch on `source == 0` and `print` instead.

## Security

### The message reaches the notification UI as markup

`mrfrost-commands/server/server.lua:23` and `:26`

The message is concatenated from the arguments and passed to `QBCore:Notify`
unmodified. Current qb-core builds its notification element with `innerHTML` and
interpolates the text straight into it, so anything the sender types is parsed
as HTML in the recipient's NUI, not shown as text. A sender can inject markup
and, with it, script into the NUI context of another player's client.

Two things bound this in the default configuration:

- The command needs `qbcore.mod`, so whoever can do it is already staff.
- The NUI in question is qb-core's, and code in it is confined to that browser
  context — it is not a route to the game client, only to whatever that page and
  its own NUI callbacks can reach.

Both of those disappear if `Config.CommandPermissionNotify` is set to `user`,
which qb-core treats as "no restriction at all". Then every player can send
markup to every other player. Do not set it to `user`.

The escaping itself belongs upstream in qb-core rather than here — every
resource that sends free text through `QBCore:Notify` has the same property.
What is specific to this resource is that carrying arbitrary player-typed text
into that call is its entire purpose. A fix on this side would strip or escape
`<` and `>` before the text is sent.

### The command leaves no trace

`mrfrost-commands/server/server.lua`

Nothing is logged: not the sender, not the target, not the text. A staff command
that puts text on another player's screen is exactly the kind of thing that gets
questioned afterwards, and there is nothing to answer with — no console line, no
Discord webhook, nothing in the database.

## Dead and unused code

| What | Where | Note |
|---|---|---|
| `client/client.lua` | `mrfrost-commands/client/client.lua:1` | The whole file is one comment, `--its so dark in here`. It is still declared in `client_scripts`, so it is shipped and loaded to do nothing. The resource is server-side only. |
| The comment above `true` | `mrfrost-commands/server/server.lua:12` | *"Whether or not the command is restricted to certain players"* describes qb-core's sixth parameter. The `true` it sits above is the fourth, `argsrequired`. Restriction comes from `Config.CommandPermissionNotify`. |
| `Config` on the client | `mrfrost-commands/fxmanifest.lua:14` | `config.lua` is a shared script, so both keys exist on the client as well. Nothing client-side reads them, because nothing client-side exists. |
| `version '1.0.0'` | `mrfrost-commands/fxmanifest.lua:8` | Unchanged across every commit that followed it, including the two that changed behaviour. |

## Text and content

### `info.notify_send` has two flaws in six words

`mrfrost-commands/locales/en.lua:12`

```lua
["notify_send"] = "Notification send to player %{player} !"
```

"send" should be "sent", and there is a stray space before the exclamation mark.
The German string next to it has neither problem.

### `desc.player_desc` explains nothing

`mrfrost-commands/locales/en.lua:5`, `mrfrost-commands/locales/de.lua:5`

The other two arguments pair a short name with a help line that says what is
expected — `Duration` with "Duration you want the notification to be visible (in
seconds)". The first pairs `ID` with `Player`, which is the only help text in the
set that leaves the reader exactly where they started. Given that the argument
order is what most often gets this command wrong, this is the one line where a
fuller sentence would earn its place.

### The plural in the name

The resource is called `mrfrost-commands` and registers one command. The
original README said more would be added; none were. Nothing depends on the
name, so it is left as it is.
