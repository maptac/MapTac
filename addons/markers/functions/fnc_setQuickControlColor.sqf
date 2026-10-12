#include "..\script_component.hpp"
/*
 * Author: Smith
 * Sets the color of a quick selection control (ring icon, color button), hovered control is opaque
 *
 * Arguments:
 * 0: Control <CONTROL>
 * 1: Color (RGBA) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrl, [1, 0, 0, 1]] call maptac_markers_fnc_setQuickControlColor
 *
 * Public: No
 */

params ["_ctrl", "_color"];

private _activeColor = +_color;
_activeColor set [3, 1];

_ctrl setVariable [QGVAR(color), _color];
_ctrl ctrlSetActiveColor _activeColor;
_ctrl ctrlSetTextColor _color;

nil
