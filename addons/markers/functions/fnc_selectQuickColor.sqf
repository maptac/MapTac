#include "..\script_component.hpp"
/*
 * Author: Smith
 * Selects the marker color in the marker placement dialog. Side colors also switch the markers to that side.
 *
 * Arguments:
 * 0: Marker placement dialog <DISPLAY>
 * 1: Color index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, 1] call maptac_markers_fnc_selectQuickColor
 *
 * Public: No
 */

params ["_display", "_index"];

((_display getVariable QGVAR(colors)) select _index) params ["", "", "_prefix"];
_display setVariable [QGVAR(colorIndex), _index];

if (_prefix != "") then {
    _display setVariable [QGVAR(prefix), _prefix];

    // b_inf -> o_inf
    private _type = _display getVariable [QGVAR(selectedType), ""];
    if ((_type select [0, 2]) in SIDE_PREFIXES) then {
        _display setVariable [QGVAR(selectedType), _prefix + (_type select [2])];
    };
};

private _colorCtrls = _display getVariable [QGVAR(colorCtrls), []];
[_colorCtrls, _index] call FUNC(highlightMarkerRing);

// Frame around the selected color, visible for any color
private _ctrlFrame = _display displayCtrl IDC_INSERTMARKER_COLOR_FRAME;
(ctrlPosition (_colorCtrls select _index)) params ["_frameX", "_frameY", "_frameW", "_frameH"];
_ctrlFrame ctrlSetPosition [_frameX - 2 * pixelW, _frameY - 2 * pixelH, _frameW + 4 * pixelW, _frameH + 4 * pixelH];
_ctrlFrame ctrlCommit 0;

[_display] call FUNC(updateQuickRings);

nil
