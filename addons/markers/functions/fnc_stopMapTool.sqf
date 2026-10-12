#include "..\script_component.hpp"
/*
 * Author: Smith
 * Stops the current map tool, places the drawn route or direction as a marker when finished
 *
 * Arguments:
 * 0: Place the marker (finished), otherwise cancelled <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call maptac_markers_fnc_stopMapTool
 *
 * Public: No
 */

params [["_place", false]];

if !("tool" in GVAR(mapTool)) exitWith {};

private _state = GVAR(mapTool);
GVAR(mapTool) = createHashMap;
// The double click finishing the route also opens the vanilla marker dialog, see fnc_handleInsertMarkerLoad
GVAR(mapToolEndTime) = diag_tickTime;

(uiNamespace getVariable [QGVAR(mapToolCtrls), []]) params [["_mapCtrl", controlNull], ["_ctrlHint", controlNull]];
_mapCtrl ctrlRemoveEventHandler ["Draw", _state get "drawEH"];
ctrlDelete _ctrlHint;
{
    ctrlDelete _x;
} forEach (uiNamespace getVariable [QGVAR(mapToolLabels), []]);
uiNamespace setVariable [QGVAR(mapToolLabels), nil];
uiNamespace setVariable [QGVAR(mapToolCtrls), nil];

if (!_place) exitWith {};

private _tool = _state get "tool";
if (_tool == "measure") exitWith {};

private _polyline = [];
if (_tool == "route") then {
    {
        _polyline append _x;
    } forEach (_state get "points");
} else {
    {
        _polyline append (_x select [0, 2]);
    } forEach (_state get "arrow");
};
// A line needs two points
if (count _polyline < 4) exitWith {};

((_state get "channels") select (_state get "channelIndex")) params ["_channel", "", "", "_channelData"];
private _color = ((_state get "colors") select (_state get "colorIndex")) select 1;
private _type = [QGVAR(direction), QGVAR(route)] select (_tool == "route");

[_channel, (_state get "points") select 0, _type, "", _color, _channelData, _polyline] call FUNC(placeMarker);

nil
