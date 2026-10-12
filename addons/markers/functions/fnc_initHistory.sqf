#include "..\script_component.hpp"
/*
 * Author: Smith
 * Creates the marker history tab in the briefing of the current player unit with all records.
 * Does nothing when the tab already exists, a new unit (respawn) gets the whole history.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call maptac_markers_fnc_initHistory
 *
 * Public: No
 */

if (!hasInterface || {isNull player} || {player diarySubjectExists QGVAR(history)}) exitWith {};

player createDiarySubject [QGVAR(history), LLSTRING(History)];

// New records appear on the top
{
    player createDiaryRecord [QGVAR(history), _x];
} forEach GVAR(history);

nil
