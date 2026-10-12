#include "..\script_component.hpp"
/*
 * Author: Smith
 * Checks whether a map tool (measuring, route, direction) is active. The tool of a closed map (e.g. the briefing map
 * after the mission start) is stopped, otherwise its keys and clicks would stay taken.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Active <BOOL>
 *
 * Example:
 * call maptac_markers_fnc_isMapToolActive
 *
 * Public: No
 */

if !("tool" in GVAR(mapTool)) exitWith {false};

if (isNull ((uiNamespace getVariable [QGVAR(mapToolCtrls), []]) param [0, controlNull])) exitWith {
    [false] call FUNC(stopMapTool);
    false
};

true
