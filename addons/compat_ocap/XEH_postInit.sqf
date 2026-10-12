#include "script_component.hpp"

// OCAP records on the server only
if (!isServer) exitWith {};

// Local copies of the markers on the clients (and the server host) are not recorded, the server sends the markers.
// OCAP sends its marker handlers to the clients by remoteExec (no OCAP on the clients): the names are added the same way,
// after OCAP has set up its exclusion list. JIP clients run it after the OCAP handlers too.
[{!isNil "ocap_listener_markers"}, {
    [LOCAL_MARKER_NAMES, {
        if (isNil "ocap_recorder_excludeMarkerList") then {
            ocap_recorder_excludeMarkerList = [];
        };
        ocap_recorder_excludeMarkerList append _this;
    }] remoteExec ["call", 0, true];
}] call CBA_fnc_waitUntilAndExecute;

[QEGVAR(markers,markerCreatedServer), {
    params ["_name", "_data"];
    if !([_name, _data] call EFUNC(markers,isChannelRecorded)) exitWith {};
    ["CREATED", _name, _data] call FUNC(recordMarker);
}] call CBA_fnc_addEventHandler;

[QEGVAR(markers,markerMovedServer), {
    params ["_name", "_data", "_editor"];
    if !([_name, _data] call EFUNC(markers,isChannelRecorded)) exitWith {};
    ["UPDATED", _name, _data, _editor] call FUNC(recordMarker);
}] call CBA_fnc_addEventHandler;

// Deleted on the server: nobody has the marker anymore
[QEGVAR(markers,markerDeletedServer), {
    params ["_name", "_data", "_editor"];
    if !([_name, _data] call EFUNC(markers,isChannelRecorded)) exitWith {};
    ["DELETED", _name, _data, _editor] call FUNC(recordMarker);
}] call CBA_fnc_addEventHandler;

// Markers placed before the recording (or its pause) are sent when it starts, OCAP skips the recorded ones
GVAR(recording) = false;
[{
    private _recording = (missionNamespace getVariable ["ocap_recorder_recording", false])
        && {(missionNamespace getVariable ["ocap_recorder_startTime", -1]) > -1};

    if (_recording && !GVAR(recording)) then {
        {
            if !([_x, _y] call EFUNC(markers,isChannelRecorded)) then {continue};
            ["CREATED", _x, _y, objNull, 0] call FUNC(recordMarker);
        } forEach EGVAR(markers,markers);
    };
    GVAR(recording) = _recording;
}, RECORDING_CHECK_INTERVAL] call CBA_fnc_addPerFrameHandler;
