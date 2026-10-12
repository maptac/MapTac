#include "..\script_component.hpp"
/*
 * Author: Smith
 * Starts a map tool from the map menu: measuring the distance, drawing a route or a direction.
 * The tool is drawn on the map until it is finished or cancelled (see fnc_onMapToolClick, fnc_stopMapTool).
 * The route and the direction are placed as markers in the channel and the color chosen while drawing.
 *
 * Arguments:
 * 0: Map control <CONTROL>
 * 1: Tool, "measure", "route" or "direction" <STRING>
 * 2: Start position <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_mapCtrl, "route", [1000, 1000]] call maptac_markers_fnc_startMapTool
 *
 * Public: No
 */

params ["_mapCtrl", "_tool", "_pos"];

[false] call FUNC(stopMapTool);

// The channel and the color of the last marker, as in the marker placement dialog
private _channels = call FUNC(getAvailableChannels);
private _channelIndex = _channels findIf {[_x select 0, _x select 3] isEqualTo (GVAR(lastMarker) select [0, 2])};
if (_channelIndex == -1) then {
    _channelIndex = _channels findIf {(_x select 0) == currentChannel};
};

private _colors = (("true" configClasses (configFile >> QGVAR(QuickMarkerColors))) apply {
    [getText (_x >> "displayName"), getText (_x >> "color")]
}) select {isClass (configFile >> "CfgMarkerColors" >> (_x select 1))};
if (_colors isEqualTo []) then {
    _colors = [["", "ColorBlack"]];
};
private _lastColor = profileNamespace getVariable [QGVAR(lastMarkerColor), ""];

GVAR(mapTool) = createHashMapFromArray [
    ["tool", _tool],
    // Route points, the start of the measuring and of the direction
    ["points", [_pos select [0, 2]]],
    // Current point under the cursor (snapped to the road) and the direction arrow, updated by fnc_drawMapTool
    ["cursor", _pos select [0, 2]],
    ["arrow", []],
    ["channels", _channels],
    ["channelIndex", _channelIndex max 0],
    ["colors", _colors],
    ["colorIndex", 0 max (_colors findIf {(_x select 1) == _lastColor})],
    ["drawEH", _mapCtrl ctrlAddEventHandler ["Draw", {call FUNC(drawMapTool)}]]
];
// [map control, hint control]
uiNamespace setVariable [QGVAR(mapToolCtrls), [_mapCtrl, ctrlParent _mapCtrl ctrlCreate [QGVAR(RscMapToolHint), -1]]];

// Shows the hint
[0, 0] call FUNC(cycleMapToolOption);

nil
