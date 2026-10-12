#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles mouse button release on the map: the map tools, the map menu, finishes dragging of the MapTac marker
 *
 * Arguments:
 * 0: Map control <CONTROL>
 * 1: Mouse button <NUMBER>
 * 2: X position <NUMBER>
 * 3: Y position <NUMBER>
 * 4: Shift pressed <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * _this call maptac_markers_fnc_onMapMouseButtonUp
 *
 * Public: No
 */

params ["_mapCtrl", "_button", "", "", "_shift"];

// Right click cancels the map tool or opens the menu of the MapTac marker or of the map, the map panning doesn't
if (_button == 1) exitWith {
    if (getMousePosition distance2D GVAR(rightClickPos) >= DRAG_THRESHOLD) exitWith {};

    if (call FUNC(isMapToolActive)) exitWith {
        [false] call FUNC(stopMapTool);
    };

    // Shift shows the extra items, as in many programs
    [_mapCtrl, [_mapCtrl] call FUNC(getMarkerUnderCursor), _shift] call FUNC(openMapMenu);
};

if (call FUNC(isMapToolActive)) exitWith {
    if (_button == 0) then {
        [_mapCtrl] call FUNC(onMapToolClick);
    };
};

if (_button != 0 || {GVAR(dragState) isEqualTo []}) exitWith {};

GVAR(dragState) params ["_name", "", "_isMoving"];
GVAR(dragState) = [];

if (!_isMoving) exitWith {};

private _pos = _mapCtrl ctrlMapScreenToWorld getMousePosition;
_name setMarkerPosLocal _pos;

[_name, _pos] call FUNC(moveMarker);

nil
