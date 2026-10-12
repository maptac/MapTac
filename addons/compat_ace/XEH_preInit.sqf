#include "script_component.hpp"

// microDAGR has a map with the markers
["gps", {
    params ["_unit"];
    "ACE_microDAGR" in items _unit
}] call EFUNC(common,addDeviceCondition);
