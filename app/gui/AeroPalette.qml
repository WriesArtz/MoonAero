import QtQuick 2.9

import StreamingPreferences 1.0

// Frutiger Aero palette.
//
// Instantiate one wherever the theme is needed:
//
//     AeroPalette { id: aero }
//
// Everything is derived from StreamingPreferences, so every instance
// stays in sync with the settings page and updates live.
QtObject {
    id: palette

    readonly property bool enabled: StreamingPreferences.aeroEnabled
    readonly property bool bubbles: enabled && StreamingPreferences.aeroBubbles

    // 0.1 (very clear glass) .. 0.9 (almost opaque)
    readonly property real glass: Math.max(0.1, Math.min(0.9, StreamingPreferences.aeroGlass / 100.0))

    // Colour of the group box titles on the settings page
    readonly property string groupTitle: enabled ? "#ffffff" : "skyblue"

    // Preset index -> colours (0 = Aqua, 1 = Bliss, 2 = Sunset, 3 = Aurora, 4 = Custom)
    readonly property var presets: [
        { top: "#073b88", mid: "#1c9bdc", bottom: "#4fd8c6", accent: "#38c9f6" }, // Aqua
        { top: "#12559e", mid: "#3fa9e6", bottom: "#46b85a", accent: "#7edc54" }, // Bliss
        { top: "#1b2f7a", mid: "#d6568f", bottom: "#f08a3c", accent: "#ffb04a" }, // Sunset
        { top: "#06173a", mid: "#0c6a86", bottom: "#1fd0a0", accent: "#4af0c8" }  // Aurora
    ]

    readonly property var presetNames: [
        qsTr("Aqua"), qsTr("Bliss"), qsTr("Sunset"), qsTr("Aurora"), qsTr("Custom")
    ]

    // Swatches offered for the Custom preset
    readonly property var swatches: [
        "#1c9bdc", "#00b7c3", "#2ecc71", "#9ccc1a", "#ffb300",
        "#ff6f3c", "#ec407a", "#9c5cf0", "#4f6df5", "#8d99ae"
    ]

    // A whole scheme derived from the single colour chosen for the Custom preset
    readonly property color customBase: StreamingPreferences.aeroCustomColor
    readonly property var customScheme: {
        var h = Math.max(0.0, customBase.hslHue)
        // Keep greys grey (graphite / silver look); otherwise make sure the scheme is colourful enough
        var s = customBase.hslSaturation < 0.1 ? customBase.hslSaturation
                                               : Math.max(0.45, customBase.hslSaturation)
        return {
            top: Qt.hsla(h, s, 0.20, 1.0),
            mid: Qt.hsla(h, s, 0.46, 1.0),
            bottom: Qt.hsla((h + 0.12) % 1.0, s, 0.52, 1.0),
            accent: Qt.hsla(h, Math.min(1.0, s + 0.1), 0.62, 1.0)
        }
    }

    readonly property var scheme: (StreamingPreferences.aeroPreset >= 0 &&
                                   StreamingPreferences.aeroPreset < presets.length)
                                  ? presets[StreamingPreferences.aeroPreset]
                                  : customScheme

    // Returns the given colour (name, #rrggbb or color) with a new alpha
    function withAlpha(c, a) {
        var k = Qt.lighter(c, 1.0)
        return Qt.rgba(k.r, k.g, k.b, a)
    }
}
