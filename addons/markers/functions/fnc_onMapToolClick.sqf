#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles the left click on the map while a map tool is active: finishes the measuring and the direction,
 * adds a route point, the click on the last route point (double click) or the last allowed point finishes the route
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_mapCtrl] call maptac_markers_fnc_onMapToolClick
 *
 * Public: No
 */

params ["_mapCtrl"];

private _tool = GVAR(mapTool) get "tool";
if (_tool == "measure") exitWith {[false] call FUNC(stopMapTool)};
if (_tool == "direction") exitWith {[true] call FUNC(stopMapTool)};

private _points = GVAR(mapTool) get "points";
private _point = GVAR(mapTool) get "cursor";

private _lastScreenPos = _mapCtrl ctrlMapWorldToScreen (_points select -1);
if ((_mapCtrl ctrlMapWorldToScreen _point) distance2D _lastScreenPos < MAP_TOOL_FINISH_DISTANCE) exitWith {
    [true] call FUNC(stopMapTool);
};

_points pushBack _point;
if (count _points >= MAX_POLYLINE_POINTS) exitWith {
    [true] call FUNC(stopMapTool);
};

// Points counter
[0, 0] call FUNC(cycleMapToolOption);

nil
