#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles mouse movement on the map, moves the dragged MapTac marker locally, updates the marker tooltip
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * _this call maptac_markers_fnc_onMapMouseMoving
 *
 * Public: No
 */

params ["_mapCtrl"];

[_mapCtrl] call FUNC(updateMarkerTooltip);

if (GVAR(dragState) isEqualTo []) exitWith {};

GVAR(dragState) params ["_name", "_startMousePos", "_isMoving"];

private _mousePos = getMousePosition;
if (!_isMoving && {_mousePos distance2D _startMousePos < DRAG_THRESHOLD}) exitWith {};

GVAR(dragState) set [2, true];
_name setMarkerPosLocal (_mapCtrl ctrlMapScreenToWorld _mousePos);

nil
