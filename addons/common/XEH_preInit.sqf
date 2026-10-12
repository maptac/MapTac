#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Device type -> conditions, any of them gives the device. Compat addons add theirs with fnc_addDeviceCondition.
// Vanilla radio backpacks (Contact platform) are long-range radios and radios,
// compat addons add theirs (e.g. TFAR backpacks and vehicle radios)
private _fnc_hasRadioBag = {backpack (_this select 0) isKindOf "B_RadioBag_01_base_F"};
GVAR(deviceConditions) = createHashMapFromArray [
    ["radio", [{(_this select 0) getSlotItemName SLOT_RADIO != ""}, _fnc_hasRadioBag]],
    ["gps", [{(_this select 0) getSlotItemName SLOT_GPS != ""}]],
    ["lr", [_fnc_hasRadioBag]]
];

ADDON = true;
