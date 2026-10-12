#include "script_component.hpp"
#include "\a3\ui_f\hpp\defineDIKCodes.inc"

[QGVAR(markerUpdated), FUNC(onMarkerUpdated)] call CBA_fnc_addEventHandler;
[QGVAR(markerDeleted), FUNC(onMarkerDeleted)] call CBA_fnc_addEventHandler;

if (hasInterface) then {
    // Unit the player acts as: joined (also in progress, reconnected), respawned, remote controlled as Zeus
    ["unit", {
        params ["_unit", "_oldUnit"];
        if (isNull _unit) exitWith {};

        // Respawn: the new unit keeps the unit key (markers)
        if (!isNull _oldUnit && {!alive _oldUnit}) then {
            _unit setVariable [QGVAR(unitKey), [_oldUnit] call FUNC(getUnitKey), true];
        };

        // Another unit (joined, Zeus remote control): its markers, as when taking another slot
        private _switched = isNull _oldUnit || {([_unit] call FUNC(getUnitKey)) != ([_oldUnit] call FUNC(getUnitKey))};
        if (_switched) then {
            {
                deleteMarkerLocal _x;
            } forEach GVAR(localMarkers);
            GVAR(localMarkers) = createHashMap;
        };

        call FUNC(initHistory);
        call FUNC(updateChannelAccess);
        [QGVAR(markersRequest), [_unit, player, _switched]] call CBA_fnc_serverEvent;
    }, true] call CBA_fnc_addPlayerEventHandler;
    ["loadout", {call FUNC(updateChannelAccess)}] call CBA_fnc_addPlayerEventHandler;
    // Vehicle devices (e.g. long-range radios from compat addons)
    ["vehicle", {call FUNC(updateChannelAccess)}] call CBA_fnc_addPlayerEventHandler;
    // The map tool ends with the map
    ["visibleMap", {
        params ["", "_visible"];
        if (!_visible) then {
            [false] call FUNC(stopMapTool);
        };
    }] call CBA_fnc_addPlayerEventHandler;

    // Stringtable keys, not localized texts: CBA localizes them itself and uses the mod name as an ID,
    // localized non-ASCII names break the keybinds menu
    private _keybindCategory = [ELSTRING(main,Category), LSTRING(Category)];

    // All the parts on one key by default, they can be split in the keybinds menu
    [_keybindCategory, QGVAR(showAuthorLabels), [LSTRING(ShowAuthorLabels), LSTRING(ShowAuthorLabels_Description)], {
        [LABEL_PART_AUTHOR, true] call FUNC(setLabelKeyHeld)
    }, {
        [LABEL_PART_AUTHOR, false] call FUNC(setLabelKeyHeld)
    }, [DIK_LSHIFT, [true, false, false]]] call CBA_fnc_addKeybind;

    [_keybindCategory, QGVAR(showGroupLabels), [LSTRING(ShowGroupLabels), LSTRING(ShowGroupLabels_Description)], {
        [LABEL_PART_GROUP, true] call FUNC(setLabelKeyHeld)
    }, {
        [LABEL_PART_GROUP, false] call FUNC(setLabelKeyHeld)
    }, [DIK_LSHIFT, [true, false, false]]] call CBA_fnc_addKeybind;

    [_keybindCategory, QGVAR(showTextLabels), [LSTRING(ShowTextLabels), LSTRING(ShowTextLabels_Description)], {
        [LABEL_PART_TEXT, true] call FUNC(setLabelKeyHeld)
    }, {
        [LABEL_PART_TEXT, false] call FUNC(setLabelKeyHeld)
    }, [DIK_LSHIFT, [true, false, false]]] call CBA_fnc_addKeybind;

    // Map tools, the keys are blocked for other actions only while drawing
    [_keybindCategory, QGVAR(toolSnapToRoad), [LSTRING(ToolSnapToRoad), LSTRING(ToolKey_Description)], {
        GVAR(snapToRoadHeld) = true;
        false
    }, {
        GVAR(snapToRoadHeld) = false;
        false
    }, [DIK_LSHIFT, [true, false, false]]] call CBA_fnc_addKeybind;

    [_keybindCategory, QGVAR(toolPreviousChannel), [LSTRING(ToolPreviousChannel), LSTRING(ToolKey_Description)], {
        [-1, 0] call FUNC(cycleMapToolOption)
    }, {}, [DIK_UP, [false, false, false]]] call CBA_fnc_addKeybind;

    [_keybindCategory, QGVAR(toolNextChannel), [LSTRING(ToolNextChannel), LSTRING(ToolKey_Description)], {
        [1, 0] call FUNC(cycleMapToolOption)
    }, {}, [DIK_DOWN, [false, false, false]]] call CBA_fnc_addKeybind;

    [_keybindCategory, QGVAR(toolPreviousColor), [LSTRING(ToolPreviousColor), LSTRING(ToolKey_Description)], {
        [0, -1] call FUNC(cycleMapToolOption)
    }, {}, [DIK_LEFT, [false, false, false]]] call CBA_fnc_addKeybind;

    [_keybindCategory, QGVAR(toolNextColor), [LSTRING(ToolNextColor), LSTRING(ToolKey_Description)], {
        [0, 1] call FUNC(cycleMapToolOption)
    }, {}, [DIK_RIGHT, [false, false, false]]] call CBA_fnc_addKeybind;
};

if (!isServer) exitWith {};

// Marker name -> data
GVAR(markers) = createHashMap;
// Marker name -> keys of the units that have received the marker
GVAR(markerHolders) = createHashMap;

[QGVAR(markerCreating), FUNC(markerCreatingEH)] call CBA_fnc_addEventHandler;
[QGVAR(markerMoving), FUNC(markerMovingEH)] call CBA_fnc_addEventHandler;
[QGVAR(markerDeleting), FUNC(markerDeletingEH)] call CBA_fnc_addEventHandler;
[QGVAR(markersRequest), FUNC(markersRequestEH)] call CBA_fnc_addEventHandler;
[QGVAR(markersCreating), {
    params ["_requests"];
    {
        _x call FUNC(markerCreatingEH);
    } forEach _requests;
}] call CBA_fnc_addEventHandler;

// Respawned unit keeps the unit key: copied by the engine, set here too if the old unit had no variable yet
addMissionEventHandler ["EntityRespawned", {
    params ["_unit", "_oldUnit"];
    if (isNil {_unit getVariable QGVAR(unitKey)}) then {
        _unit setVariable [QGVAR(unitKey), [_oldUnit] call FUNC(getUnitKey), true];
    };
}];
