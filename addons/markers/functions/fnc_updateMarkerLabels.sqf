#include "..\script_component.hpp"
/*
 * Author: Smith
 * Applies the label mode to all MapTac markers of this client and to the label mode buttons on the maps
 *
 * Return Value:
 * None
 *
 * Example:
 * call maptac_markers_fnc_updateMarkerLabels
 *
 * Public: No
 */

{
    _x setMarkerTextLocal ([_y] call FUNC(getMarkerLabel));
} forEach GVAR(localMarkers);

// Map buttons show the parts switched on
private _buttons = (uiNamespace getVariable [QGVAR(labelButtons), []]) select {!isNull _x};
uiNamespace setVariable [QGVAR(labelButtons), _buttons];
{
    private _shown = GVAR(labelShown) select (_x getVariable QGVAR(labelPart));
    _x ctrlSetTextColor ([LABEL_BUTTON_OFF_COLOR, [1, 1, 1, 1]] select _shown);
} forEach _buttons;

nil
