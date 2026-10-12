#include "..\script_component.hpp"
/*
 * Author: Smith
 * Creates clickable marker icons on half-circle rings left of the marker point in the marker placement dialog.
 * Icons of each ring are centered around its left point.
 *
 * Arguments:
 * 0: Marker placement dialog <DISPLAY>
 * 1: Items <ARRAY>
 *   0: Marker type to show (CfgMarkers class) <STRING>
 *   1: Tooltip <STRING>
 *   2: Value passed to the click handler <ANY>
 * 2: Rings layout (see fnc_getQuickRingLayouts) <ARRAY>
 * 3: Icons color (RGBA) <ARRAY>
 * 4: Click handler, called with [display, value] <CODE>
 *
 * Return Value:
 * Created controls <ARRAY>
 *
 * Example:
 * [_display, [["b_inf", "Infantry", 0]], [[100, 45, 1]], [0, 0.3, 0.6, 1], {}] call maptac_markers_fnc_createMarkerRing
 *
 * Public: No
 */

params ["_display", "_items", "_layout", "_color", "_onClick"];

(_display getVariable QGVAR(origin)) params ["_originX", "_originY"];
(_display getVariable QGVAR(quickIconSize)) params ["_iconW", "_iconH"];

private _ctrls = [];
private _itemIndex = 0;
{
    _x params ["_radius", "_step", "_ringCount"];

    for "_i" from 0 to (_ringCount - 1) do {
        (_items select _itemIndex) params ["_type", "_tooltip", "_value"];
        _itemIndex = _itemIndex + 1;

        // From the top (90 degrees) through the left (180) to the bottom (270)
        private _angle = 180 - _step * (_ringCount - 1) / 2 + _step * _i;

        private _ctrl = _display ctrlCreate [QGVAR(RscQuickMarker), -1];
        _ctrl ctrlSetPosition [
            _originX + _radius * cos _angle * pixelW - _iconW / 2,
            _originY - _radius * sin _angle * pixelH - _iconH / 2,
            _iconW,
            _iconH
        ];
        _ctrl ctrlCommit 0;
        _ctrl ctrlSetText getText (configFile >> "CfgMarkers" >> _type >> "icon");
        _ctrl ctrlSetTooltip _tooltip;
        _ctrl setVariable [QGVAR(value), _value];
        _ctrl setVariable [QGVAR(onClick), _onClick];
        [_ctrl, _color] call FUNC(setQuickControlColor);
        _ctrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            [ctrlParent _ctrl, _ctrl getVariable QGVAR(value)] call (_ctrl getVariable QGVAR(onClick));
        }];

        _ctrls pushBack _ctrl;
    };
} forEach _layout;

_ctrls
