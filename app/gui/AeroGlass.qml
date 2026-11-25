import QtQuick 2.9

// A glossy Frutiger Aero glass surface: tinted translucent body, a bright
// "gloss" highlight on the top half, a thin white rim and a soft shadow.
//
// Used as an overlay (z: -0.5) inside buttons and tiles, or as the
// background of bars, group boxes, dialogs and menus.
Item {
    id: glass

    // How opaque the glass is (0..1). Defaults to the user's slider.
    property real density: aero.glass
    property color tint: aero.scheme.accent
    property real cornerRadius: 14
    property bool orb: false        // fully round (used for toolbar buttons)
    property bool hovered: false
    property bool pressed: false
    property bool focused: false    // keyboard / gamepad selection
    property bool shadow: true

    readonly property real r: orb ? Math.min(width, height) / 2 : cornerRadius
    readonly property real strength: 0.25 + 0.55 * density

    AeroPalette { id: aero }

    // Soft drop shadow (two stacked, offset, translucent shapes)
    Rectangle {
        visible: glass.shadow
        x: -2; y: 1
        width: parent.width + 4
        height: parent.height + 5
        radius: glass.r + 2
        color: "#000000"
        opacity: 0.12
    }
    Rectangle {
        visible: glass.shadow
        x: 0; y: 2
        width: parent.width
        height: parent.height + 1
        radius: glass.r
        color: "#000000"
        opacity: 0.18
    }

    // Tinted body
    Rectangle {
        anchors.fill: parent
        radius: glass.r
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: aero.withAlpha(Qt.lighter(glass.tint, 1.15), glass.strength + (glass.hovered ? 0.10 : 0.0))
            }
            GradientStop {
                position: 0.5
                color: aero.withAlpha(glass.tint, glass.strength + (glass.hovered ? 0.06 : 0.0))
            }
            GradientStop {
                position: 1.0
                color: aero.withAlpha(Qt.darker(glass.tint, 1.45), Math.min(1.0, glass.strength + 0.12))
            }
        }
        border.width: glass.focused ? 2 : 1
        border.color: glass.focused ? "#ffffff" : aero.withAlpha("#ffffff", 0.55)
    }

    // Warm glow along the bottom edge
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 2
        }
        height: parent.height * 0.32
        radius: Math.max(0, glass.r - 2)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: aero.withAlpha(Qt.lighter(glass.tint, 1.4), 0.28) }
        }
    }

    // Gloss highlight on the top half
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 2
        }
        height: parent.height * 0.5
        radius: Math.max(0, glass.r - 2)
        opacity: 0.55 + 0.45 * glass.density
        gradient: Gradient {
            GradientStop { position: 0.0; color: aero.withAlpha("#ffffff", 0.55) }
            GradientStop { position: 1.0; color: aero.withAlpha("#ffffff", 0.06) }
        }
    }

    // Pressed state darkens the whole surface
    Rectangle {
        anchors.fill: parent
        radius: glass.r
        color: "#000000"
        opacity: glass.pressed ? 0.25 : 0.0
        Behavior on opacity { NumberAnimation { duration: 80 } }
    }

    // Selection ring for keyboard / gamepad navigation
    Rectangle {
        visible: glass.focused
        anchors.fill: parent
        anchors.margins: -4
        radius: glass.r + 4
        color: "transparent"
        border.width: 3
        border.color: aero.withAlpha(Qt.lighter(glass.tint, 1.5), 0.85)
    }
}
