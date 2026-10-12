#include "..\script_component.hpp"
#include "\a3\ui_f\hpp\defineResincl.inc"
/*
 * Author: Smith
 * Handles closing of the MapTac marker placement dialog, places the marker when confirmed
 *
 * Arguments:
 * 0: Marker placement dialog <DISPLAY>
 * 1: Exit code <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, 1] call maptac_markers_fnc_onInsertMarkerUnload
 *
 * Public: No
 */

params ["_display", "_exitCode"];

deleteMarkerLocal QGVAR(preview);

(_display getVariable [QGVAR(ringsDrawEH), []]) params [["_mapCtrl", controlNull], ["_drawEH", -1]];
_mapCtrl ctrlRemoveEventHandler ["Draw", _drawEH];
_mapCtrl setVariable [QGVAR(insertDisplay), nil];

if (_exitCode != IDC_OK) exitWith {};

private _ctrlChannel = _display displayCtrl IDC_INSERTMARKER_CHANNEL;
private _channelIndex = lbCurSel _ctrlChannel;
if (_channelIndex == -1 || {_ctrlChannel lbValue _channelIndex < 0}) exitWith {};

((_display getVariable QGVAR(channels)) select (_ctrlChannel lbValue _channelIndex)) params ["_channel", "", "", "_channelData"];
private _type = _display getVariable [QGVAR(selectedType), "hd_dot"];
private _color = ((_display getVariable QGVAR(colors)) select (_display getVariable QGVAR(colorIndex))) select 1;
private _text = ctrlText (_display displayCtrl IDC_INSERTMARKER_TEXT);
private _pos = _display getVariable QGVAR(position);

profileNamespace setVariable [QGVAR(lastMarkerType), _type];
profileNamespace setVariable [QGVAR(lastMarkerColor), _color];
GVAR(lastMarker) = [_channel, _channelData, _type, _text, _color];

[_channel, _pos, _type, _text, _color, _channelData] call FUNC(placeMarker);

nil
