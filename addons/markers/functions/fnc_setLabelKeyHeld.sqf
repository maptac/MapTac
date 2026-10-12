#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles the keys which show the marker label parts while held
 *
 * Arguments:
 * 0: Label part, LABEL_PART_AUTHOR/GROUP/TEXT <NUMBER>
 * 1: Held <BOOL>
 *
 * Return Value:
 * Handled, always false so the key still works for other actions <BOOL>
 *
 * Example:
 * [0, true] call maptac_markers_fnc_setLabelKeyHeld
 *
 * Public: No
 */

params ["_part", "_held"];

if ((GVAR(labelHeld) select _part) isNotEqualTo _held) then {
    GVAR(labelHeld) set [_part, _held];
    call FUNC(updateMarkerLabels);
};

false
