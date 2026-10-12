#include "..\script_component.hpp"
#include "\a3\ui_f\hpp\defineResincl.inc"
#include "\a3\ui_f\hpp\defineDIKCodes.inc"
/*
 * Author: Smith
 * Adds marker interaction (dragging, deleting, tooltip) and the label mode button to a map display.
 * Called from Extended_DisplayLoad_EventHandlers for the main map and briefing maps.
 *
 * Arguments:
 * 0: Map display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 12] call maptac_markers_fnc_initMapDisplay
 *
 * Public: No
 */

params ["_display"];

private _mapCtrl = allControls _display param [
    allControls _display findIf {ctrlType _x == CT_MAP_MAIN},
    controlNull
];
if (isNull _mapCtrl) exitWith {};

TRACE_2("Init map display",_display,_mapCtrl);

_display setVariable [QGVAR(mapCtrl), _mapCtrl];

_mapCtrl ctrlAddEventHandler ["MouseButtonDown", {call FUNC(onMapMouseButtonDown)}];
_mapCtrl ctrlAddEventHandler ["MouseMoving", {call FUNC(onMapMouseMoving)}];
_mapCtrl ctrlAddEventHandler ["MouseHolding", {call FUNC(updateMarkerTooltip)}];
_mapCtrl ctrlAddEventHandler ["MouseButtonUp", {call FUNC(onMapMouseButtonUp)}];
// Delete deletes the MapTac marker under the cursor
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key != DIK_DELETE) exitWith {false};

    private _name = [_display getVariable [QGVAR(mapCtrl), controlNull]] call FUNC(getMarkerUnderCursor);
    if (_name == "") exitWith {false};

    [_name] call FUNC(deleteMarker);
    true
}];

private _ctrlTooltipBackground = _display ctrlCreate [QGVAR(RscMarkerTooltipBackground), -1];
private _ctrlTooltip = _display ctrlCreate [QGVAR(RscMarkerTooltip), -1];
_ctrlTooltipBackground ctrlShow false;
_ctrlTooltip ctrlShow false;
_display setVariable [QGVAR(tooltipCtrls), [_ctrlTooltipBackground, _ctrlTooltip]];

// Label part switches in a row
{
    _x params ["_part", "_text"];

    private _ctrl = _display ctrlCreate [QGVAR(RscLabelButton), -1];
    (ctrlPosition _ctrl) params ["_ctrlX", "_ctrlY", "_ctrlW", "_ctrlH"];
    _ctrl ctrlSetPosition [_ctrlX + _ctrlW * LABEL_BUTTON_STEP * _forEachIndex, _ctrlY, _ctrlW, _ctrlH];
    _ctrl ctrlCommit 0;
    _ctrl ctrlSetText _text;
    _ctrl ctrlSetTooltip LLSTRING(LabelButton_Tooltip);
    _ctrl setVariable [QGVAR(labelPart), _part];
    _ctrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _part = _ctrl getVariable QGVAR(labelPart);
        // Until the end of the mission, the defaults are in the settings
        GVAR(labelShown) set [_part, !(GVAR(labelShown) select _part)];
        call FUNC(updateMarkerLabels);
    }];
    uiNamespace setVariable [QGVAR(labelButtons), (uiNamespace getVariable [QGVAR(labelButtons), []]) + [_ctrl]];
} forEach [
    [LABEL_PART_AUTHOR, LLSTRING(LabelAuthor)],
    [LABEL_PART_GROUP, LLSTRING(LabelGroup)],
    [LABEL_PART_TEXT, LLSTRING(LabelText)]
];
call FUNC(updateMarkerLabels);

nil
