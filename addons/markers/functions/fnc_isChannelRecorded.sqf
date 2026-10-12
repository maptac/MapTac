#include "..\script_component.hpp"
/*
 * Author: Smith
 * Checks whether the marker is recorded by the replay mods, by the replay recording settings of its channel.
 * The markers of the channel types of compat addons are also filtered by their record filter
 * (e.g. TFAR: long-range frequencies only).
 * Used by the compat addons of the replay mods (e.g. compat_ocap).
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: Marker data <HASHMAP>
 *
 * Return Value:
 * Recorded <BOOL>
 *
 * Example:
 * [_name, _data] call maptac_markers_fnc_isChannelRecorded
 *
 * Public: Yes
 */

params [["_name", "", [""]], ["_data", createHashMap, [createHashMap]]];

private _channel = _data getOrDefault ["channel", -1];

// Channel types of compat addons (radio frequencies)
if (_channel >= EXTRA_CHANNEL_MIN) exitWith {
    GVAR(recordExtraChannels) && {[_name, _data] call ((GVAR(channelTypes) getOrDefault [_channel, []]) param [2, {true}])}
};
if (_channel < 0 || _channel >= count CHANNEL_SETTING_NAMES) exitWith {false};

missionNamespace getVariable [format ["%1%2", QGVAR(recordChannel), CHANNEL_SETTING_NAMES select _channel], true]
