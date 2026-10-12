#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"maptac_main"};
        author = ECSTRING(main,Team);
        authors[] = {"Smith"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
