#include "..\script_component.hpp"
/*
 * Author: Smith
 * Highlights the selected control of a quick selection group (ring icons, color buttons),
 * the others are half-transparent until hovered
 *
 * Arguments:
 * 0: Controls <ARRAY>
 * 1: Selected value <ANY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrls, "b_inf"] call maptac_markers_fnc_highlightMarkerRing
 *
 * Public: No
 */

params ["_ctrls", "_selectedValue"];

{
    private _color = +(_x getVariable QGVAR(color));
    _color set [3, [QUICK_MARKER_ALPHA, 1] select ((_x getVariable QGVAR(value)) isEqualTo _selectedValue)];
    _x ctrlSetTextColor _color;
} forEach _ctrls;

nil
