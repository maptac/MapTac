class RscText;
class RscEdit;
class RscCombo;
class RscButton;
class RscActivePicture;
class RscActivePictureKeepAspect;
class RscFrame;

// Quick selection marker, created around the marker point by fnc_openInsertMarker
class GVAR(RscQuickMarker): RscActivePictureKeepAspect {
    shadow = 0; // inherited shadow darkens icons compared to the map markers
    w = POS_W(2.8);
    h = POS_H(1.4);
};

// Color button, created by fnc_openInsertMarker
class GVAR(RscQuickColor): RscActivePicture {
    shadow = 0;
    text = "#(argb,8,8,3)color(1,1,1,1)";
};

// Controls are positioned relative to the marker position (0, 0), fnc_openInsertMarker moves them to the clicked
// point on the screen. The marker itself is previewed with a local marker on the map, quick selection rings are created
// by script
class GVAR(RscInsertMarker) {
    idd = -1;
    movingEnable = 0;
    enableSimulation = 1;

    class ControlsBackground {
        class TextBackground: RscText {
            idc = -1;
            colorBackground[] = {0.25, 0.27, 0.3, 0.85};
            x = POS_W(INSERTMARKER_LEFT);
            y = POS_H(-0.5);
            w = POS_W(12);
            h = POS_H(1);
        };
        // Shown while the marker text is empty
        class TextPlaceholder: TextBackground {
            idc = IDC_INSERTMARKER_TEXT_PLACEHOLDER;
            text = CSTRING(TextPlaceholder);
            colorText[] = {1, 1, 1, 0.5};
            colorBackground[] = {0, 0, 0, 0};
        };
    };

    class Controls {
        // Area for the color buttons
        class Colors: RscText {
            idc = IDC_INSERTMARKER_COLORS;
            x = POS_W(INSERTMARKER_LEFT);
            y = POS_H(-2.7);
            w = POS_W(12);
            h = POS_H(0.9);
        };
        class ColorFrame: RscFrame {
            idc = IDC_INSERTMARKER_COLOR_FRAME;
            x = 0;
            y = 0;
            w = 0;
            h = 0;
        };
        class Channel: RscCombo {
            idc = IDC_INSERTMARKER_CHANNEL;
            colorBackground[] = {0, 0, 0, 1};
            x = POS_W(INSERTMARKER_LEFT);
            y = POS_H(-1.6);
            w = POS_W(12);
            h = POS_H(1);
        };
        class Text: RscEdit {
            idc = IDC_INSERTMARKER_TEXT;
            style = "0x00 + 0x200"; // ST_LEFT + ST_NO_RECT
            maxChars = MAX_MARKER_TEXT_LENGTH;
            colorBackground[] = {0, 0, 0, 0};
            x = POS_W(INSERTMARKER_LEFT);
            y = POS_H(-0.5);
            w = POS_W(12);
            h = POS_H(1);
        };
        // Inserts the name of the player's vehicle into the text, shown only in a vehicle
        class VehicleName: RscActivePictureKeepAspect {
            idc = IDC_INSERTMARKER_VEHICLE;
            text = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\car_ca.paa";
            x = POS_W(INSERTMARKER_LEFT + 12.2);
            y = POS_H(-0.5);
            w = POS_W(1.3);
            h = POS_H(1);
        };
        // IDC 1 closes the display with exit code 1, Enter triggers it
        class ButtonOK: RscButton {
            idc = 1;
            default = 1;
            text = CSTRING(Send);
            colorBackground[] = {0, 0, 0, 1};
            colorBackgroundActive[] = {0.2, 0.2, 0.2, 1};
            colorFocused[] = {0, 0, 0, 1};
            x = POS_W(INSERTMARKER_LEFT);
            y = POS_H(0.6);
            w = POS_W(5.9);
            h = POS_H(1);
        };
        // IDC 2 closes the display with exit code 2, same as Escape
        class ButtonCancel: ButtonOK {
            idc = 2;
            default = 0;
            text = ECSTRING(common,Cancel);
            x = POS_W(INSERTMARKER_LEFT + 6.1);
        };
    };
};
