<p align="center">
    <img src="extras/assets/logo/maptac_logo.png" width="200" alt="MapTac">
</p>

<h1 align="center">MapTac</h1>

<p align="center"><b>Tactical map markers for Arma 3</b></p>

MapTac turns the map into a tool for coordinated play. Markers are placed in a couple of clicks from NATO unit
symbols, carry the squad and the author with them, and travel the way information travels in the field: over the
channel you can actually use, to the players who can actually receive it. Leave the radio behind and the side
channel goes quiet; tune in to another frequency and you see what was sent there.

## Features

- **Quick marker dialog.** Double-click the map: NATO unit symbols (infantry, armor, recon, artillery and more)
  and the classic map symbols open in rings next to the point, together with six colors, the text and the channel.
  The last channel is remembered, the vehicle name is inserted with one click.
- **Labels with the squad and the author.** Markers show "A1-1 Smith: text". The squad, the author and the text
  are toggled with buttons on the map or shown while a key is held; the callsign format is configurable.
- **Map menu.** Right-click a marker to forward it to another channel, send it again to those who joined later,
  measure from it or delete it. Right-click the map to place a marker, repeat the last one, draw a route or
  a direction arrow, or measure a distance. With Shift, copy all visible markers as text and paste them back.
- **Map tools.** A ruler with 10 m, 100 m and 1 km ticks and the azimuth; routes of up to 100 points that snap to
  roads; direction arrows. The channel and the color are switched with the arrow keys while drawing.
- **Channels with requirements.** For each channel the mission maker chooses who can place and see markers:
  everyone, nobody, only during the briefing, or only players with a radio, a GPS or a long-range radio.
  The command channel is for group leaders, the direct channel reaches players within a set distance.
- **Markers that stay.** Markers belong to the unit that placed them: they survive respawn, reconnecting and
  joining in progress, and work with Zeus remote control.
- **Tooltips and history.** Hover a marker to see its channel, author and time; the briefing keeps the history
  of created and deleted markers.
- **19 languages**, all languages of Arma 3.

## Compatibility

MapTac needs only CBA_A3. Support for other mods lives in separate compat addons that load only together with
the mod:

- **[ACE3](https://github.com/acemod/ACE3)**: the microDAGR counts as a GPS, the MapTac dialog works together with
  the ACE marker placement.
- **[TFAR](https://github.com/michail-nikolaev/task-force-arma-3-radio) 0.9.x and 1.x**: every listened frequency
  is a marker channel named by the radio or the vehicle; markers can be limited to the radio range; long-range
  backpacks and vehicle radios count as long-range radios.
- **[OCAP2](https://github.com/OCAP2/OCAP)**: replays record every marker once, with its label
  (see [OCAP2 replays](#ocap2-replays)).

## Installation

Requires Arma 3 2.22 and [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997) 3.19 or newer.

Load MapTac on the clients and on the server. The settings are in the CBA addon options, category **MapTac**.

## OCAP2 replays

MapTac markers are recorded by [OCAP2](https://github.com/OCAP2/OCAP) through the `compat_ocap` addon. It loads only
where OCAP is loaded, so MapTac must be loaded on the server together with OCAP (as on the clients).

The markers are local copies on every client, OCAP would record each of them from every client (duplicates, blinking
on updates, different labels). `compat_ocap` excludes the local copies from the client recording and records every
marker once from the server, with the squad, the author and the text as its label. Markers placed before the
recording starts are added when it starts.

### OCAP settings

`compat_ocap` adds the MapTac markers to the OCAP exclusions automatically. To be safe, also add them to the OCAP
setting **Marker Prefixes to Exclude** (`OCAP_settings_excludeMarkerFromRecord`, category OCAP, Exclusions),
keeping the existing prefixes:

```
['SystemMarker_','ACE_BFT_','RscAttribute','MapTac:','maptac_markers_preview']
```

In `cba_settings.sqf` of the server or the mission:

```sqf
force OCAP_settings_excludeMarkerFromRecord = "['SystemMarker_','ACE_BFT_','RscAttribute','MapTac:','maptac_markers_preview']";
```

Without them, players who join in progress may record their local copies of the markers again (duplicates).

### Recorded channels

The recorded channels are set in the MapTac CBA settings, **Replay recording** (server settings):

- **Record channel: ...**: markers of each vanilla channel (global, side, command, group, vehicle, direct);
- **Record radio frequencies and other channels**: TFAR frequency markers and the channels of other compat addons.

Which TFAR frequency markers are recorded is set in the TFAR category of the MapTac settings,
**Replay recording: frequencies**:

- **All frequencies**;
- **Placed on LR radios (backpacks, vehicles)**: the author placed the marker while listening to the frequency
  on a long-range radio;
- **LR band frequencies (30-87 MHz)**: the frequency is in the long-range band, whatever radio the marker was placed
  on (short-range radios reach this band too).

All are recorded by default. Global channel markers are shown to all sides in the replay, the others to the side
of the author.

## Development

### Components

| Addon | Description |
| --- | --- |
| `main` | Core: macros, versioning, CBA dependency check |
| `common` | Shared functions (radio/GPS checks) and strings |
| `compat_ace` | ACE3 compatibility: microDAGR as GPS, MapTac marker dialog with ACE markers; skipped without ACE3 |
| `compat_tfar` | TFAR 0.9.x and 1.x compatibility: long-range radios as devices, a marker channel per listened frequency (named by the radio or the vehicle), optional radio range limit; skipped without TFAR |
| `compat_ocap` | OCAP2 replays: markers recorded once from the server (no duplicates of the clients' local copies), recorded channels in the CBA settings (Replay recording); skipped without OCAP |
| `markers` | Marker placement dialog, server-side marker distribution by channel, marker history in the briefing |

### Build

The project is built with [HEMTT](https://hemtt.dev):

```sh
hemtt check --pedantic   # lints configs, SQF and stringtables
hemtt build              # builds PBOs into .hemttout/build
hemtt launch             # launches the game with the dev build and CBA
hemtt launch ace         # same, plus ACE3 for compatibility testing
hemtt launch tfar        # same, plus TFAR 1.x (beta)
hemtt launch tfar_legacy # same, plus TFAR 0.9.12
hemtt launch ace_tfar    # ACE3 + TFAR 1.x (also ace_tfar_legacy)
hemtt release            # signed release build
```

For in-game testing, the `test` profiles open the test mission (`.hemtt/missions/MapTac.Stratis`) in the editor,
with ZEN and Advanced Developer Tools. The mission has BLUFOR players in two groups, OPFOR players, a vehicle and
a crate with radios, GPS and radio backpacks (TFAR and ACE devices too, when loaded).

```sh
hemtt launch test            # CBA, ZEN, developer tools
hemtt launch test_tfar       # plus TFAR 1.x
hemtt launch test_ace_tfar   # plus ACE3 and TFAR 1.x
hemtt launch test -i 2       # two game instances for multiplayer tests
```

### Release

1. Set the version in `addons/main/script_version.hpp`, it is written into `mod.cpp` by a HEMTT hook.
2. Push the version tag, e.g. `v1.1.0`. The `Release` workflow runs `hemtt release` and attaches
   `maptac_1.1.0.zip` to a GitHub release draft.

Every push and pull request is checked and built by the `HEMTT` workflow, the dev build is attached to the run
as an artifact.

### Localization

All UI strings live in `addons/<component>/stringtable.xml`. Translation fixes are welcome.

## License

MapTac is licensed under the [Arma Public License Share Alike (APL-SA)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike),
see [LICENSE](LICENSE).

Files in `include/` belong to their authors and are under their own licenses: `include/a3` - Bohemia Interactive,
`include/x/cba` - [CBA_A3](https://github.com/CBATeam/CBA_A3) (GPLv2).
