#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the units the players act as: their own units or the units they remote control as Zeus
 * (reported by the clients, see fnc_markersRequestEH). The channels are resolved among them:
 * the remote controlled unit hears its channels, the Zeus player unit doesn't meanwhile.
 * The events sent to a remote controlled unit reach the Zeus client, the unit is local there.
 * Must be executed on server-side only
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Units <ARRAY>
 *
 * Example:
 * call maptac_markers_fnc_getActingUnits
 *
 * Public: Yes
 */

allPlayers apply {
    private _unit = _x getVariable [QGVAR(actingUnit), _x];
    // Stale after the remote control ended without a report (e.g. the unit died)
    [_x, _unit] select (alive _unit)
}
