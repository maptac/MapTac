#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"maptac_markers", "ocap_recorder"};
        // The whole addon is skipped when OCAP is not loaded (server-side mod, so on the clients too)
        skipWhenMissingDependencies = 1;
        author = ECSTRING(main,Team);
        authors[] = {"Smith"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
