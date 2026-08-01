# The command

One command, `/notify`, registered from `server/server.lua`. This page is the
contract: what it accepts, what it sends, and what QBCore does around it. The
resource exposes no exports, defines no events of its own and ships no NUI, so
everything it can do is on this page.

## Signature

```
/notify [ID] [duration] [message]
```

| Position | Name | Type | Read as |
|---|---|---|---|
| 1 | `ID` | number | Server id of the receiving player. |
| 2 | `duration` | number | Seconds the notification stays on screen. Multiplied by 1000 and passed on as milliseconds. |
| 3+ | `message` | text | Every remaining argument, joined with a single space. |

The command name is not fixed: `Config.CommandNameNotify` decides what is typed
in chat. `notify` is used throughout this documentation because that is the
default.

Arguments are positional and consumed from the front. The handler reads the
first argument, removes it, reads the next, removes it, and treats whatever is
left as the message — which is why a message never needs quoting, and why runs
of spaces inside it collapse to one.

## Registration

```lua
QBCore.Commands.Add(
    Config.CommandNameNotify, Lang:t("desc.send_notify"),
    { ... three argument descriptors ... },
    true,
    function(source, args) ... end,
    Config.CommandPermissionNotify
)
```

The fourth argument is [qb-core](https://github.com/qbcore-framework/qb-core)'s
`argsrequired`, not a restriction flag — the in-file comment above it calls it
"whether or not the command is restricted to certain players", which describes
the sixth argument instead. Restriction comes from the permission level: qb-core
registers the command with FiveM as restricted for anything other than `user`.

`argsrequired = true` means qb-core compares the number of arguments given
against the number described, three, and refuses anything shorter before this
resource's callback runs. The refusal is a red chat line reading *All arguments
must be filled out!* — qb-core's own `error.missing_args2` string, not one of
this resource's. So the callback always sees at least three arguments, and after
the id and the duration are consumed there is always something left to send.

The three argument descriptors carry a name and a help line each, both from
`locales/`. They are what qb-core sends to the chat resource as suggestions, so
they are what a player sees while typing the command. See
[localisation.md](localisation.md).

## What it sends

Two notifications, both as the qb-core client event `QBCore:Notify`, whose
signature is `(text, type, length, icon)` with `length` in milliseconds:

| Recipient | When | Type | Length |
|---|---|---|---|
| The target player | The id resolved to a player | `primary` | `duration * 1000` |
| The sender | Directly after that | `success` | not set — qb-core's default of 5000 ms |
| The sender | The id resolved to nothing | `error` | not set — qb-core's default of 5000 ms |

The two sender-side strings come from `locales/`, `info.notify_send` and
`info.notify_no_player`. The message itself is passed through untouched.

## Resolution of the id

The first argument is put through `tonumber` before it reaches
`QBCore.Functions.GetPlayer`, so the lookup is by server id and nothing else.
Anything that is not a number becomes `nil`, and `nil` finds no player. A name
typed instead of an id therefore does not error — it takes the failure path,
after a detour described in [known-issues.md](known-issues.md).

The failure path reports the wrong value. By the time the error string is built,
two arguments have been removed, so the `%{player}` placeholder receives the
first word of the message rather than the id that failed. See
[known-issues.md](known-issues.md).

## Permission

`Config.CommandPermissionNotify` is passed to qb-core as the permission level.
qb-core creates an ace for it at registration time:

```
add_ace qbcore.mod command.notify allow
```

and registers the command as restricted, so FiveM checks `command.notify` before
the handler is reached. A player without the ace gets FiveM's own *access
denied* line. Granting the permission is covered in
[configuration.md](configuration.md).

## Calling it from another resource

There is no export and no event to call. The only entry point is the chat
command, so a script that wants the same effect should trigger `QBCore:Notify`
on the target directly:

```lua
-- server side, from any resource
TriggerClientEvent('QBCore:Notify', targetSource, 'the message', 'primary', 8000)
```

That is exactly what this resource does, minus the argument parsing and the
permission check.
