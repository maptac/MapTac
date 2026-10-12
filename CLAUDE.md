# MapTac

Arma 3 mod: tactical map markers (quick marker dialog with NATO symbols, labels, map tools, channels with device
requirements). Depends on CBA_A3 only.

## Core rule: CBA is the only dependency

- Core addons (`main`, `common`, `markers`) have **no** dependency on other mods (ACE, TFAR, ACRE, OCAP, RHS...),
  direct or indirect: nothing in `requiredAddons`, no classes, functions, variables or config properties of other
  mods in code or configs.
- Everything related to another mod goes into a separate compat addon `addons/compat_<mod>/`, as in ACE3:
  - `requiredAddons[] = {"maptac_<component>", "<CfgPatches class of the mod>"};` and
    `skipWhenMissingDependencies = 1;`, so the whole addon is skipped without the mod;
  - integration only through the public API of the core addons, not by editing them. If the API is missing
    something, extend the API in the core addon in a mod-agnostic way.
- Keep the mod simple: few functions, no speculative features or abstractions.

## Architecture

- **Markers are local.** Each client creates local markers named `MapTac:...` (`MARKER_NAME_PREFIX`) only for the
  channels it can use. The server keeps the marker data, resolves the receivers of each channel and sends them the
  marker.
- **Network: CBA events** (`markers`):
  - client to server: `markerCreating`, `markersCreating` (batch paste), `markerMoving`, `markerDeleting`,
    `markersRequest` (JIP, reconnect, Zeus unit switch);
  - server to clients: `markerUpdated`, `markerDeleted`;
  - server local, for compat addons (TFAR, OCAP): `markerCreatedServer`, `markerMovedServer`, `markerDeletedServer`.
- **Acting unit.** All actions use the unit the player acts as (`CBA_fnc_currentUnit`, Zeus remote control
  included). Clients report it in `markersRequest`; the server resolves channels among `FUNC(getActingUnits)`, not
  `allPlayers`.
- **Ownership.** Markers belong to the creator unit by its unit key (`FUNC(getUnitKey)`, `BIS_fnc_netId`, kept on
  respawn). `FUNC(getCreatorUnit)` finds the respawned creator; channels (side, group) are resolved from it.
  The marker stays on the server while someone holds it.
- **Channels.** Vanilla channels have a mode setting each: Disabled / Enabled / Briefing only / Radio / GPS /
  Long-range / GPS or long-range (vehicle and direct channels: Disabled / Enabled only). Command channel: group
  leaders only. Direct channel: range setting.
- **Public API for compat addons:**
  - `EFUNC(common,addDeviceCondition)`, `EFUNC(common,hasDevice)`: devices (GPS, radio, long-range radio) of other
    mods;
  - `EFUNC(markers,addChannelType)`: extra channel types (e.g. TFAR frequencies), must run on every machine before
    markers are placed;
  - `EFUNC(markers,canUseChannel)`, `EFUNC(markers,isChannelRecorded)`, `EFUNC(markers,getCreatorUnit)`,
    `EFUNC(markers,placeMarker)`, `EFUNC(markers,moveMarker)`, `EFUNC(markers,deleteMarker)`.
- **Compat addons:**
  - `compat_ace`: microDAGR as GPS, MapTac dialog with the ACE marker placement;
  - `compat_tfar`: TFAR 0.9.x and 1.x; a channel per listened frequency, optional radio range limit. Frequencies are
    polled only after the TFAR client init (`TFAR_currentUnit`), earlier polling returns empty data;
  - `compat_ocap`: server-only mod; records every marker once from the server, excludes the local copies from the
    client recording.

## Build and checks: HEMTT only

- `hemtt check --pedantic` must pass with **no warnings or help** at all. Run it after every change.
- `hemtt build` builds into `.hemttout/build`. `hemtt launch [ace|tfar|tfar_legacy|ace_tfar|ace_tfar_legacy]`
  launches the game with the dev build (profiles in `.hemtt/launch.toml`). Test compat addons in profiles with and
  without their mod.
- Test mission: `.hemtt/missions/MapTac.Stratis`, profiles `test`, `test_tfar`, `test_ace_tfar` (with ZEN and
  Advanced Developer Tools). Multiplayer: `hemtt launch test -i 2`.
- Extra lints: `.hemtt/lints.toml` (`banned_macros` keeps debug macros out of releases, `undefined`,
  `not_private`, `unused`).
- After stringtable changes: `hemtt ln sort` (keys must be sorted).
- `XEH_PREP.hpp` is regenerated from the function files, sorted:
  `ls functions | sed -E 's/^fnc_(.*)\.sqf$/PREP(\1);/' > XEH_PREP.hpp`.
- Hooks (`.hemtt/hooks`): the version from `script_version.hpp` is written into `mod.cpp` (placeholder `0.0.0`);
  the release archive is renamed to `maptac_<version>.zip`.
- Files outside `addons/` that go into the build (mod.cpp, LICENSE, README.md, logos) are listed in
  `[files] include` of `.hemtt/project.toml`.
- Images for the game are PAA: `hemtt utils paa convert <src.png> <dest.paa>` (power-of-two sizes, `_ca` suffix for
  alpha). Logo sources are in `extras/assets/logo`.
- No other build systems (Addon Builder, pboProject, Python build scripts etc.).

### CI and release

- `.github/workflows/hemtt.yml`: check (annotations) and build on pushes to `main` and pull requests; the dev build
  is uploaded as an artifact.
- Release: bump the version in `addons/main/script_version.hpp`, push the tag `v<version>`. The `Release` workflow
  builds `hemtt release` and creates a GitHub release draft with the archive.
- Steam Workshop: uploaded manually by the maintainer, not from CI.

## Addon structure (`addons/<component>/`)

As in ACE3:

- `$PBOPREFIX$`: `z\maptac\addons\<component>`
- `config.cpp`: `CfgPatches` (`name = COMPONENT_NAME`, `requiredVersion = REQUIRED_VERSION`, `requiredAddons`,
  `author = ECSTRING(main,Team)` (`CSTRING(Team)` in `main`), `authors[]` (contributors' nicknames),
  `VERSION_CONFIG`) and
  `#include` of the other `.hpp` files
- `CfgEventHandlers.hpp`: `Extended_PreStart/PreInit/PostInit_EventHandlers` via
  `QUOTE(call COMPILE_SCRIPT(XEH_...))`
- `XEH_PREP.hpp`: `PREP(...)` list, alphabetical; included from `XEH_preStart.sqf` and `XEH_preInit.sqf`
- `XEH_preStart.sqf`: `#include "XEH_PREP.hpp"` (function cache)
- `XEH_preInit.sqf`: `ADDON = false;`, `PREP_RECOMPILE_START/END` around `#include "XEH_PREP.hpp"`,
  `#include "initSettings.inc.sqf"`, `ADDON = true;`
- `XEH_postInit.sqf`: CBA events, state initialization
- `initSettings.inc.sqf`: CBA settings (`CBA_fnc_addSetting`), category `[ELSTRING(main,Category), LSTRING(Category)]`
- `script_component.hpp`: `COMPONENT`, `COMPONENT_BEAUTIFIED`, debug flags, includes of `script_mod.hpp` /
  `script_macros.hpp`; dialog IDCs and component constants
- `stringtable.xml`: component localization
- `functions/fnc_<name>.sqf`: one function per file

New addons depend (`requiredAddons`) at least on `maptac_main` (or `maptac_common`).

## SQF

- Every function file starts with `#include "..\script_component.hpp"` and an ACE header (Author, description,
  Arguments, Return Value, Example, `Public: Yes/No`). Snippet `header` in `.vscode/sqf.code-snippets`.
- CBA/MapTac macros only: `GVAR`, `QGVAR`, `EGVAR`, `FUNC`, `EFUNC`, `QFUNC`, `LSTRING`, `CSTRING`, `LLSTRING`,
  `ELSTRING`, `TRACE_n`, `ARR_n` etc. Never hardcode `maptac_<component>_...`.
- All local variables are `private`; arguments via `params` (with types in public functions).
- Network via CBA events (`CBA_fnc_serverEvent`, `CBA_fnc_targetEvent`, `CBA_fnc_globalEvent(JIP)`), not
  `remoteExec`.
  Exception: compat addons of server-only mods (e.g. `compat_ocap`). Clients have neither the mod nor the compat
  addon, so nobody there could receive a CBA event; `remoteExec` code instead, as the mod itself does.
- UI event handlers called from configs (`onLoad`, `Extended_DisplayLoad_EventHandlers`) are wrapped in
  `with missionNamespace do {...}`, they may run in `uiNamespace`.
- Vanilla displays are extended with `Extended_DisplayLoad_EventHandlers`, not by overriding `onLoad` of vanilla
  classes.
  Exception: a compat addon, when the other mod itself overrides `onLoad` without `BIS_fnc_initDisplay` (the CBA
  event never fires): keep its `onLoad` and append the MapTac call (see `compat_ace/RscDisplayInsertMarker.hpp`).
- Vanilla includes (`\a3\ui_f\hpp\defineResincl.inc`, `defineCommonGrids.inc`, `defineDIKCodes.inc`) are in
  `include/a3/ui_f/hpp`, CBA macros in `include/x/cba/...`. These are third-party files, don't edit them.
- Engine commands and event handlers: check the Arma 3 wiki (`arma3-wiki` data of HEMTT) instead of guessing.

### English style in code

- Code comments: terse technical English (`// Hidden, channel not available`).
- Logs, statuses, error texts (`WARNING_n`, `TRACE_n`, `ERROR_n`, `diag_log`): telegraphic English
  (`"%1 tried to move marker %2, not creator"`).
- Documentation only (ACE function headers: description, Arguments, Return Value): clear grammatical English in
  full sentences.

## GUI

- Positions via `POS_X/Y/W/H` from `addons/main/script_macros.hpp` (40x25 grid from the screen center),
  background colors via `GUI_BCG_COLOR`.
- Base classes (`RscText`, `RscCombo`, ...) are declared external, `A3_Ui_F` in `requiredAddons`.
- Display and control classes are prefixed with `GVAR(...)`.

## Localization (mandatory)

- **Everything shown to the user** (dialog texts, buttons, tooltips, CBA setting names and descriptions, hints,
  messages) goes through `stringtable.xml`, no hardcoded strings.
- Every key has **all languages supported by Arma 3**: English (original), Czech, French, Spanish, Italian, Polish,
  Portuguese, Russian, German, Korean, Japanese, Chinese, Chinesesimp, Turkish, Slovak, Hungarian, Ukrainian,
  Bulgarian, Latin. Language-neutral texts (mod name, codes, formats like `%1 - %2`) are copied from English.
  Placeholders (`%1`, `%2`) must match English. `hemtt ln coverage` shows the coverage (it doesn't list every
  language, check the rest by hand).
- Key IDs: `STR_maptac_<component>_<Name>`; in code `LSTRING`/`CSTRING`/`LLSTRING`/`ELSTRING`/`ECSTRING`/`LELSTRING`.
- CBA settings and keybinds (category, name, description) get **keys** (`LSTRING`/`ELSTRING`), not translated text:
  CBA localizes them itself and uses the mod name of keybinds as an ID, a translated Cyrillic name breaks the menu
  (empty names).
- Shared strings (OK/Cancel, channel names) go to `common`, the mod name, category and team name to `main`.
- Exception: `mod.cpp` (the launcher doesn't support stringtables), plain English there.

## Version

`addons/main/script_version.hpp` is the only version source (read by HEMTT). Minimum game and CBA versions:
`REQUIRED_VERSION` / `REQUIRED_CBA_VERSION` in `addons/main/script_mod.hpp` (keep the README Installation section
in sync).

## Working notes

- Report what was verified honestly: `hemtt check`/`hemtt build` is not an in-game test. Say so when nothing was
  tested in game.
- Don't modify `.vscode/settings.json` (maintainer's personal settings).
- Commit only when asked. The default branch is `main`.
- SQF include paths use backslashes; shell heredocs, `sed` and `printf` can mangle them (`\a` becomes a bell
  character). Prefer the file editing tools for such edits.
