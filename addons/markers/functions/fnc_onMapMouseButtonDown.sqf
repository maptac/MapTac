#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles mouse button press on the map, prepares dragging of own MapTac marker under the cursor.
 * Right button press is remembered to tell the click (marker menu) from the map panning.
 * Only the creator unit may move the marker (survives respawn). Own markers are found also when
 * they are covered by other markers in the same place.
 *
 * Arguments:
 * 0: Map control <CONTROL>
 * 1: Mouse button <NUMBER>
 * 2: X position <NUMBER>
 * 3: Y position <NUMBER>
 * 4: Shift pressed <BOOL>
 * 5: Ctrl pressed <BOOL>
 * 6: Alt pressed <BOOL>
 *
 * Return Value:
 * Handled <BOOL>
 *
 * Example:
 * _this call maptac_markers_fnc_onMapMouseButtonDown
 *
 * Public: No
 */

params ["_mapCtrl", "_button", "", "", "_shift", "_ctrl", "_alt"];

GVAR(dragState) = [];

if (_button == 1) exitWith {
    GVAR(rightClickPos) = getMousePosition;
    false
};

// The map tools take the left clicks, see fnc_onMapMouseButtonUp
if (call FUNC(isMapToolActive)) exitWith {_button == 0};

if (_button != 0 || {_shift || _ctrl || _alt}) exitWith {false};

private _key = [call CBA_fnc_currentUnit] call FUNC(getUnitKey);

// The top marker reported by the engine
private _name = [_mapCtrl] call FUNC(getMarkerUnderCursor);
// Only the icons are dragged, the lines (routes, directions) are drawn again instead
private _fnc_isDraggable = {
    (_this getOrDefault ["creatorKey", ""]) == _key && {(_this getOrDefault ["shape", "ICON"]) == "ICON"}
};

if !((GVAR(localMarkers) getOrDefault [_name, createHashMap]) call _fnc_isDraggable) then {
    // Own markers under the cursor, the closest one
    _name = "";
    getMousePosition params ["_mouseX", "_mouseY"];
    private _closestDistance = 1e10;
    {
        if !(_y call _fnc_isDraggable) then {continue};
        // Hidden, the channel is not available now
        if !(GVAR(channelAccess) getOrDefault [_y get "channel", true]) then {continue};

        (_mapCtrl ctrlMapWorldToScreen markerPos _x) params ["_markerX", "_markerY"];
        private _distanceX = abs (_markerX - _mouseX) / pixelW;
        private _distanceY = abs (_markerY - _mouseY) / pixelH;
        private _radius = MARKER_GRAB_RADIUS * getNumber (configFile >> "CfgMarkers" >> markerType _x >> "size") * (markerSize _x select 0);
        if (_distanceX > _radius || _distanceY > _radius) then {continue};

        private _distance = _distanceX ^ 2 + _distanceY ^ 2;
        if (_distance < _closestDistance) then {
            _name = _x;
            _closestDistance = _distance;
        };
    } forEach GVAR(localMarkers);
};
if (_name == "") exitWith {false};

// Dragging starts only after the mouse moves a bit, so a click or double-click doesn't move the marker
GVAR(dragState) = [_name, getMousePosition, false];

true
