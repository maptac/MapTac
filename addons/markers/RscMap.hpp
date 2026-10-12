class RscStructuredText;

// Tooltip of the MapTac markers on the map, created by fnc_initMapDisplay.
// The background is a separate control to have the vertical padding.
class GVAR(RscMarkerTooltipBackground): RscText {
    colorBackground[] = {0, 0, 0, 0.75};
    w = POS_W(13);
    h = POS_H(1);
};
class GVAR(RscMarkerTooltip): RscStructuredText {
    size = POS_H(0.8);
    colorBackground[] = {0, 0, 0, 0};
    w = POS_W(13);
    h = POS_H(1);
};

// Marker label part switches in the top right corner of the map, created by fnc_initMapDisplay in a row
class GVAR(RscLabelButton): RscButton {
    sizeEx = POS_H(0.8);
    colorBackground[] = {0, 0, 0, 0.6};
    colorBackgroundActive[] = {0, 0, 0, 0.9};
    colorFocused[] = {0, 0, 0, 0.6};
    x = QUOTE(safeZoneX + safeZoneW - 13.5 * GUI_GRID_W);
    y = QUOTE(safeZoneY + 2 * GUI_GRID_H);
    w = POS_W(4.2);
    h = POS_H(1);
};

// Context menu of the map and the MapTac markers (right click), created by fnc_openMapMenu.
// Items are created by script at the click position.
class GVAR(RscMapMenu) {
    idd = -1;
    movingEnable = 0;
    enableSimulation = 1;
};
class GVAR(RscMapMenuItem): RscButton {
    style = 0; // ST_LEFT
    sizeEx = POS_H(0.8);
    colorBackground[] = {0, 0, 0, 0.85};
    colorBackgroundActive[] = {0.2, 0.2, 0.2, 0.95};
    colorFocused[] = {0, 0, 0, 0.85};
    w = POS_W(10);
    h = POS_H(1);
};

// Hint of the active map tool at the top of the map, created by fnc_startMapTool
class GVAR(RscMapToolHint): RscStructuredText {
    size = POS_H(0.8);
    colorBackground[] = {0, 0, 0, 0.75};
    x = QUOTE(safeZoneX + safeZoneW / 2 - 13 * GUI_GRID_CENTER_W);
    y = QUOTE(safeZoneY + 2 * GUI_GRID_H);
    w = POS_W(26);
    h = POS_H(2.5);
    class Attributes {
        align = "center";
    };
};

// Map tool texts (ruler, lengths), created by fnc_drawMapTool. Font and size of the vanilla map cursor info
// (RscMapControl fontInfo, sizeExInfo), UI controls keep the size at any map zoom unlike the drawIcon text.
class GVAR(RscMapToolLabel): RscText {
    font = "RobotoCondensed";
    sizeEx = QUOTE(MAP_TOOL_TEXT_SIZE);
    shadow = 0;
    colorBackground[] = {0, 0, 0, 0};
    w = 0;
    h = 0;
};
