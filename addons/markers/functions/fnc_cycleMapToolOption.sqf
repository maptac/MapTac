#include "..\script_component.hpp"
/*
 * Author: Smith
 * Switches the channel or the color of the route or the direction being drawn and updates the map tool hint.
 * Called by the keybinds, they are handled only while a map tool is active.
 *
 * Arguments:
 * 0: Channel change, -1 previous, 1 next, 0 keep <NUMBER>
 * 1: Color change, -1 previous, 1 next, 0 keep <NUMBER>
 *
 * Return Value:
 * Handled (the key is blocked for other actions) <BOOL>
 *
 * Example:
 * [1, 0] call maptac_markers_fnc_cycleMapToolOption
 *
 * Public: No
 */

params ["_channelChange", "_colorChange"];

if !(call FUNC(isMapToolActive)) exitWith {false};

private _tool = GVAR(mapTool) get "tool";
private _channels = GVAR(mapTool) get "channels";
private _colors = GVAR(mapTool) get "colors";

if (_tool != "measure") then {
    if (_channels isNotEqualTo []) then {
        GVAR(mapTool) set ["channelIndex", ((GVAR(mapTool) get "channelIndex") + _channelChange + count _channels) % count _channels];
    };
    GVAR(mapTool) set ["colorIndex", ((GVAR(mapTool) get "colorIndex") + _colorChange + count _colors) % count _colors];
};

private _fnc_escape = {
    [_this] call EFUNC(common,escapeStructuredText)
};
private _fnc_keyName = {
    private _keybind = [ELSTRING(main,Category), _this] call CBA_fnc_getKeybind;
    if (isNil "_keybind") exitWith {""};
    (_keybind select 5) params ["_key", "_modifiers"];
    if (_key <= 0) exitWith {""};
    ([_key, _modifiers] call CBA_fnc_localizeKey) call _fnc_escape
};
private _fnc_colored = {
    params ["_text", "_color"];
    format ["<t color='%1'>%2</t>", (_color select [0, 3]) call BIS_fnc_colorRGBtoHTML, _text call _fnc_escape]
};

private _title = localize ([
    LSTRING(MenuMeasure), LSTRING(MenuRoute), LSTRING(MenuDirection)
] select (["measure", "route", "direction"] find _tool));
if (_tool == "route") then {
    _title = format ["%1  %2", _title, format [LLSTRING(HintPoints), count (GVAR(mapTool) get "points"), MAX_POLYLINE_POINTS]];
};
private _lines = [format ["<t font='RobotoCondensedBold'>%1</t>", _title]];

if (_tool == "measure") then {
    _lines pushBack LLSTRING(HintMeasure);
} else {
    (_channels select (GVAR(mapTool) get "channelIndex")) params ["", "_channelName", "_channelColor"];
    (_colors select (GVAR(mapTool) get "colorIndex")) params ["_colorName", "_colorClass"];
    _lines pushBack format [
        "%1  %2",
        format [LLSTRING(HintChannel), [_channelName, _channelColor] call _fnc_colored, format [
            "%1/%2", QGVAR(toolPreviousChannel) call _fnc_keyName, QGVAR(toolNextChannel) call _fnc_keyName
        ]],
        format [LLSTRING(HintColor), [_colorName, [_colorClass] call FUNC(getMarkerColor)] call _fnc_colored, format [
            "%1/%2", QGVAR(toolPreviousColor) call _fnc_keyName, QGVAR(toolNextColor) call _fnc_keyName
        ]]
    ];
    _lines pushBack ([
        LLSTRING(HintDirection),
        format [LLSTRING(HintRoute), QGVAR(toolSnapToRoad) call _fnc_keyName]
    ] select (_tool == "route"));
};

((uiNamespace getVariable [QGVAR(mapToolCtrls), []]) param [1, controlNull]) ctrlSetStructuredText parseText (_lines joinString "<br/>");

// The measuring has no options, the keys keep their actions
_tool != "measure"
