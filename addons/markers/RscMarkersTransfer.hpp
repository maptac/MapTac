class RscEditMulti;

// Copying (the text to copy) and pasting (the pasted text and the channel) of the markers, see fnc_openMarkersTransfer
class GVAR(RscMarkersTransfer) {
    idd = -1;
    movingEnable = 0;
    enableSimulation = 1;

    class ControlsBackground {
        class Background: RscText {
            idc = -1;
            colorBackground[] = {0, 0, 0, 0.85};
            x = POS_X(8);
            y = POS_Y(4.5);
            w = POS_W(24);
            h = POS_H(15.6);
        };
        class Title: RscText {
            idc = IDC_TRANSFER_TITLE;
            colorBackground[] = GUI_BCG_COLOR;
            x = POS_X(8);
            y = POS_Y(4.5);
            w = POS_W(24);
            h = POS_H(1);
        };
    };

    class Controls {
        class Hint: RscStructuredText {
            idc = IDC_TRANSFER_HINT;
            size = POS_H(0.8);
            x = POS_X(8.5);
            y = POS_Y(5.8);
            w = POS_W(23);
            h = POS_H(1.6);
        };
        class Text: RscEditMulti {
            idc = IDC_TRANSFER_TEXT;
            maxChars = MAX_TRANSFER_TEXT_LENGTH;
            sizeEx = POS_H(0.7);
            colorBackground[] = {0.1, 0.1, 0.1, 1};
            x = POS_X(8.5);
            y = POS_Y(7.5);
            w = POS_W(23);
            h = POS_H(8.5);
        };
        class Status: RscText {
            idc = IDC_TRANSFER_STATUS;
            x = POS_X(8.5);
            y = POS_Y(16.2);
            w = POS_W(23);
            h = POS_H(1);
        };
        class Channel: RscCombo {
            idc = IDC_TRANSFER_CHANNEL;
            colorBackground[] = {0, 0, 0, 1};
            x = POS_X(8.5);
            y = POS_Y(17.3);
            w = POS_W(23);
            h = POS_H(1);
        };
        // IDC 1 closes the display with exit code 1 (paste), IDC 2 - with exit code 2, same as Escape
        class ButtonOK: RscButton {
            idc = 1;
            text = CSTRING(TransferPaste);
            colorBackground[] = {0, 0, 0, 1};
            colorBackgroundActive[] = {0.2, 0.2, 0.2, 1};
            colorFocused[] = {0, 0, 0, 1};
            x = POS_X(8.5);
            y = POS_Y(18.6);
            w = POS_W(11.4);
            h = POS_H(1);
        };
        class ButtonCancel: ButtonOK {
            idc = 2;
            text = ECSTRING(common,Cancel);
            x = POS_X(20.1);
        };
    };
};
