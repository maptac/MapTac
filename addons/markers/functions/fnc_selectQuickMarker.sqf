#include "..\script_component.hpp"
/*
 * Author: Smith
 * Selects the marker type in the marker placement dialog, updates the preview marker on the map
 *
 * Arguments:
 * 0: Marker placement dialog <DISPLAY>
 * 1: Marker type (CfgMarkers class) <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, "b_inf"] call maptac_markers_fnc_selectQuickMarker
 *
 * Public: No
 */

params ["_display", "_type"];

_display setVariable [QGVAR(selectedType), _type];
QGVAR(preview) setMarkerTypeLocal _type;

[_display getVariable [QGVAR(markerRingCtrls), []], _type] call FUNC(highlightMarkerRing);

nil
