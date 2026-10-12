// ace_markers replaces onLoad of the vanilla marker dialog without calling BIS_fnc_initDisplay,
// so the CBA DisplayLoad event never fires and maptac_markers doesn't intercept the dialog.
// Keeps the ACE onLoad (ACE dialog for the vanilla markers) and calls the interception after it.
class RscDisplayInsertMarker {
    onLoad = QUOTE(call ace_markers_fnc_initInsertMarker; with missionNamespace do {call EFUNC(markers,handleInsertMarkerLoad)});
};
