# KGB Info Top HUD

KGB Info Top HUD is an AMX Mod X plugin for Counter-Strike 1.6 servers. It
shows the server IP in a top HUD message and sends a colored chat line with
round, map, next-map, and player-count information at the start of each round.
The visible labels can be configured for Serbian or English.

The plugin is a clean-room KGB implementation of the behavior from the
`InfoTopHud.sma` source that this repository started with. It does not require
the old `colorchat` include.

## Features

- Shows the server IP and port in a top HUD message on each new round.
- Sends a colored round/map/player status line to human players.
- Supports Serbian and English labels through the config file.
- Resets the displayed round counter on game restart and game commencing
  events.
- Supports a configurable chat prefix.
- Supports enabling or disabling the HUD and chat outputs separately.
- Creates a default config file on first load.
- Keeps the legacy `amx_prefix <prefix>` server command for compatibility.

## Install

Download `kgb_info_top_hud.amxx` from the latest release and copy it into:

```text
addons/amxmodx/plugins/
```

Add this line to `addons/amxmodx/configs/plugins.ini`:

```text
kgb_info_top_hud.amxx
```

Start or restart the server. On first load, the plugin creates:

```text
addons/amxmodx/configs/kgb_info_top_hud.cfg
```

Edit that file to change the prefix, output toggles, HUD text, color, position,
and duration.

## Commands

| Command | Access | Description |
| --- | --- | --- |
| `amx_prefix <prefix>` | Server/RCON | Updates `kgb_ith_prefix` until the next config reload. |

## Cvars

| Cvar | Default | Description |
| --- | --- | --- |
| `kgb_ith_enabled` | `1` | Enable the plugin output. |
| `kgb_ith_language` | `sr` | Label language. Supported values: `sr`, `serbian`, `en`, `eng`, `english`. Unknown values fall back to Serbian. |
| `kgb_ith_prefix` | `KGB` | Prefix used in the chat status line. |
| `kgb_ith_show_chat` | `1` | Send the colored chat status line. |
| `kgb_ith_show_hud` | `1` | Show the top HUD server IP message. |
| `kgb_ith_hud_text` | empty | Optional HUD text override. Leave empty to use the selected language's default text. `{ip}` is replaced with the server IP and port. |
| `kgb_ith_hud_red` | `255` | HUD red channel, clamped to `0`-`255`. |
| `kgb_ith_hud_green` | `85` | HUD green channel, clamped to `0`-`255`. |
| `kgb_ith_hud_blue` | `0` | HUD blue channel, clamped to `0`-`255`. |
| `kgb_ith_hud_x` | `-1.0` | HUD horizontal position. `-1.0` centers the text. |
| `kgb_ith_hud_y` | `0.0` | HUD vertical position. |
| `kgb_ith_hud_effect` | `2` | AMXX HUD effect. |
| `kgb_ith_hud_fxtime` | `6.0` | HUD effect time in seconds. |
| `kgb_ith_hud_holdtime` | `180.0` | HUD hold time in seconds. |

The plugin also registers the legacy `infotop` version cvar for server-list
compatibility.

## Build

Docker is required for the bundled build flow.

```sh
./scripts/build.sh
```

The script downloads the pinned AMX Mod X compiler when needed, verifies it,
and writes the compiled plugin to `compiled/kgb_info_top_hud.amxx`.

```sh
./scripts/check-compatibility.sh
```

Use the compatibility check to compile against AMX Mod X `1.8.2`, `1.9`, and
`1.10`.

## Release Files

- `kgb_info_top_hud.amxx`
- `kgb_info_top_hud.amxx.sha256`
