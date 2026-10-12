class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};

class Extended_DisplayLoad_EventHandlers {
    // Main map and briefing maps
    class RscDiary {
        ADDON = QUOTE(with missionNamespace do {call FUNC(initMapDisplay)});
    };
    // Vanilla marker placement dialog (double-click on the map)
    class RscDisplayInsertMarker {
        ADDON = QUOTE(with missionNamespace do {call FUNC(handleInsertMarkerLoad)});
    };
};
