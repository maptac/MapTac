#include "..\script_component.hpp"
#include "\a3\ui_f\hpp\defineResincl.inc"
/*
 * Author: Smith
 * Intercepts the vanilla marker placement dialog (map double-click) and replaces it with the MapTac one.
 * Double-click on an existing non-MapTac marker keeps the vanilla dialog (marker editing).
 *
 * Arguments:
 * 0: Vanilla marker dialog (RscDisplayInsertMarker) <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call maptac_markers_fnc_handleInsertMarkerLoad
 *
 * Public: No
 */

params ["_display"];

// Double click finishing a map tool (route) opens the dialog too
if (call FUNC(isMapToolActive) || {diag_tickTime - GVAR(mapToolEndTime) < MAP_TOOL_DOUBLE_CLICK_TIME}) exitWith {
    {
        _x ctrlShow false;
    } forEach allControls _display;
    [{(_this select 0) closeDisplay IDC_CANCEL}, [_display]] call CBA_fnc_execNextFrame;
};

if !(missionNamespace getVariable [QGVAR(replaceVanillaDialog), false]) exitWith {};

private _parentDisplay = displayParent _display;
private _mapCtrl = allControls _parentDisplay param [
    allControls _parentDisplay findIf {ctrlType _x == CT_MAP_MAIN && {ctrlShown _x}},
    controlNull
];
if (isNull _mapCtrl) exitWith {};

if ((ctrlMapMouseOver _mapCtrl) param [0, ""] == "marker" && {[_mapCtrl] call FUNC(getMarkerUnderCursor) == ""}) exitWith {
    TRACE_1("Editing vanilla marker, keeping vanilla dialog",ctrlMapMouseOver _mapCtrl);
};

private _screenPos = getMousePosition;
private _pos = _mapCtrl ctrlMapScreenToWorld _screenPos;
TRACE_2("Intercepting vanilla marker dialog",_parentDisplay,_pos);

// Hide the vanilla dialog right away, closing it inside its onLoad is not safe
{
    _x ctrlShow false;
} forEach allControls _display;

[{
    params ["_display", "_mapCtrl", "_pos", "_screenPos"];

    _display closeDisplay IDC_CANCEL;

    if (isNull _mapCtrl) exitWith {};
    [_mapCtrl, _pos, _screenPos] call FUNC(openInsertMarker);
}, [_display, _mapCtrl, _pos, _screenPos]] call CBA_fnc_execNextFrame;

nil
