#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"maptac_markers", "task_force_radio"};
        // The whole addon is skipped when TFAR is not loaded.
        // task_force_radio exists in 0.9.x and in 1.x (legacy compatibility patch).
        skipWhenMissingDependencies = 1;
        author = ECSTRING(main,Team);
        authors[] = {"Smith"};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
