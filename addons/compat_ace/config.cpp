#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"maptac_markers", "ace_microdagr", "ace_markers"};
        // The whole addon is skipped when the mod is not loaded
        skipWhenMissingDependencies = 1;
        author = ECSTRING(main,Team);
        authors[] = {"Smith"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "RscDisplayInsertMarker.hpp"
