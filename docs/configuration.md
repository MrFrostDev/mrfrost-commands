# Configuration

Everything configurable lives in `config.lua`, which is four lines and two keys.
There is no shared folder and no per-command table: the resource has one command
and the two keys describe it.

```lua
Config = {}

Config.CommandPermissionNotify = 'mod' --Permission needed to execute notify command
Config.CommandNameNotify = 'notify'    --Name of the notify command
```

The file is loaded as a shared script, so both the server and the client have
`Config` — although only the server reads it, because `client/client.lua` is
empty.

## `Config.CommandNameNotify`

| | |
|---|---|
| Type | string |
| Default | `'notify'` |

The command as typed in chat, without the leading slash. It is passed straight
to `QBCore.Commands.Add`, which registers it with FiveM under the name as given
and keeps its own registry entry under the lowercased form.

Change it if `notify` collides with another resource. Nothing here checks for
that collision, and neither resource logs a warning about it.

## `Config.CommandPermissionNotify`

| | |
|---|---|
| Type | string |
| Default | `'mod'` |

The QBCore permission level a player needs. qb-core ships three, defined in its
own `config.lua` as `QBCore.Config.Server.Permissions`:

| Level | Note |
|---|---|
| `god` | qb-core deliberately creates no per-command ace for this level, on the assumption that your `server.cfg` allows it everything. If it does not, `god` alone will not run the command. |
| `admin` | Ace created normally. |
| `mod` | The default here. Ace created normally. |

Any other string is accepted as well — qb-core creates the ace for whatever it
is given. The group then has to exist in your `server.cfg` for anyone to be in
it.

### Granting it

At registration qb-core runs

```
add_ace qbcore.<level> command.<name> allow
```

so with the defaults, the ace `command.notify` is allowed for the principal
`qbcore.mod`. What remains is putting a player into that principal, either
permanently in `server.cfg`:

```cfg
add_principal identifier.license:0123456789abcdef qbcore.mod
```

or at runtime, from another resource, with qb-core's helper — which adds the
principal for the *session*, keyed on the server id, and is lost on reconnect:

```lua
QBCore.Functions.AddPermission(source, 'mod')
```

Permission levels are not hierarchical by themselves. qb-core creates one ace
per level and nothing that links them, so `qbcore.admin` does not imply
`qbcore.mod` unless your `server.cfg` chains the principals:

```cfg
add_principal qbcore.god qbcore.admin
add_principal qbcore.admin qbcore.mod
```

Most server setups carry lines like these already. Without them, an admin who is
not also in `qbcore.mod` cannot use a `mod` command.

### Setting it to `user`

`user` is a special case in qb-core: the command is then registered as
**unrestricted** and no ace is created, so every player on the server can run
it. For this command that means any player can put arbitrary text on any other
player's screen, for a duration they choose. The text reaches qb-core's
notification UI as HTML — see [known-issues.md](known-issues.md) — so this is
not only a nuisance setting. Leave it at `mod`, or higher.

## What is not configurable

- The notification type of the delivered message. It is `primary`, hardcoded.
- The duration of the two sender-side confirmations. They are sent without a
  length, so qb-core's default of 5000 ms applies.
- Any bound on the duration a sender may ask for. Zero, negative and absurd
  values are all passed through; see [known-issues.md](known-issues.md).
- The labels. Those live in `locales/`, not in the config — see
  [localisation.md](localisation.md).
