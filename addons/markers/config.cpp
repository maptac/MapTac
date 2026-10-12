#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"maptac_common", "A3_Ui_F"};
        author = ECSTRING(main,Team);
        authors[] = {"Smith"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "\a3\ui_f\hpp\defineCommonGrids.inc"

#include "CfgQuickMarkers.hpp"
#include "RscInsertMarker.hpp"
#include "RscMap.hpp"
#include "RscMarkersTransfer.hpp"
