// Test equipment near the players: vehicle with radio, crate with all the devices
private _base = [1985, 5645, 0];

createMarker ["respawn_west", _base];
createMarker ["respawn_east", [2300, 5560, 0]];

// Vehicle channel, TFAR vehicle radio
"B_MRAP_01_F" createVehicle (_base vectorAdd [15, 0, 0]);

private _crate = "B_supplyCrate_F" createVehicle (_base vectorAdd [-6, 0, 0]);
clearItemCargoGlobal _crate;
clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearBackpackCargoGlobal _crate;

_crate addItemCargoGlobal ["ItemRadio", 10];
_crate addItemCargoGlobal ["ItemGPS", 10];
// Vanilla long-range radios
_crate addBackpackCargoGlobal ["B_RadioBag_01_mtp_F", 6];

// Mod devices when loaded
{
    _x params ["_class", "_count", "_isBackpack"];
    private _cfg = ["CfgWeapons", "CfgVehicles"] select _isBackpack;
    if !(isClass (configFile >> _cfg >> _class)) then {continue};
    if (_isBackpack) then {
        _crate addBackpackCargoGlobal [_class, _count];
    } else {
        _crate addItemCargoGlobal [_class, _count];
    };
} forEach [
    ["ACE_microDAGR", 6, false],
    ["TFAR_anprc152", 6, false],
    ["tf_anprc152", 6, false],
    ["TFAR_rt1523g", 4, true],
    ["tf_rt1523g", 4, true]
];

// Full arsenal for quick loadout changes
["AmmoboxInit", [_crate, true]] call BIS_fnc_arsenal;
