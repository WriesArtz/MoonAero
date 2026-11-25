import QtQuick

// A "liquid glass" Frutiger Aero surface.
//
//  * frosted backdrop: the (already blurred) wallpaper behind the panel, clipped to the
//    panel's rounded shape (loaded lazily from AeroGlassFx.qml, so the app still works
//    with plain translucent glass if QtQuick.Effects is missing or blur is set to 0)
//  * a light tint, a soft sheen that fades out (no hard highlight band) and an inner glow
//  * a specular rim, brightest at the top-left and bottom-right corners
//  * a soft diffuse shadow, a glow instead of a hard focus ring
//  * springy hover / press motion
//
// Used as an overlay (z: -0.5) inside buttons and tiles, or as the background of
// bars, group boxes, dialogs and menus.
Item {
    id: glass

    // How opaque the glass is (0..1). Defaults to the user's slider.
    property real density: aero.glass
    property color tint: aero.scheme.accent
    property real cornerRadius: 22
    property bool orb: false        // fully round / capsule (toolbar buttons)
    property bool hovered: false
    property bool pressed: false
    property bool focused: false    // keyboard / gamepad selection
    property bool shadow: true
    property bool backdropBlur: true   // show the blurred wallpaper through the glass
    property bool springy: true        // scale this surface on hover / press (see `spring`)

    readonly property real r: orb ? Math.min(width, height) / 2 : Math.min(cornerRadius, Math.min(width, height) / 2)
    readonly property bool fxActive: fxLoader.status === Loader.Ready
    // Body opacity. Less is needed when the blurred backdrop already frosts the glass.
    readonly property real strength: fxActive ? 0.10 + 0.42 * density : 0.20 + 0.55 * density

    // Springy scale factor (1 at rest, ~1.04 hovered / selected, ~0.96 pressed).
    // Buttons and tiles bind their own `scale` to it so the content moves with the glass.
    property real spring: pressed ? 0.96 : ((hovered || focused) ? 1.04 : 1.0)
    Behavior on spring {
        NumberAnimation {
            duration: glass.pressed ? 90 : 520
            easing.type: glass.pressed ? Easing.OutQuad
                         : ((glass.hovered || glass.focused) ? Easing.OutBack : Easing.OutElastic)
            easing.overshoot: 2.2
            easing.amplitude: 1.0
            easing.period: 0.45
        }
    }

    AeroPalette { id: aero }

    Item {
        id: visual
        anchors.fill: parent
        scale: glass.springy ? glass.spring : 1.0

        // Soft diffuse shadow: stacked translucent shapes that fade outwards
        Repeater {
            model: glass.shadow ? 5 : 0
            delegate: Rectangle {
                x: -(index * 2 + 1)
                y: -(index * 2) + 3 + index
                width: glass.width + (index * 2 + 1) * 2
                height: glass.height + (index * 2) * 2 + 1
                radius: glass.r + index * 2
                color: "#001018"
                opacity: 0.075
            }
        }

        // Glow around the glass when hovered or selected (replaces the old hard focus ring)
        Repeater {
            model: 4
            delegate: Rectangle {
                x: -(3 + index * 3)
                y: -(3 + index * 3)
                width: glass.width + (3 + index * 3) * 2
                height: glass.height + (3 + index * 3) * 2
                radius: glass.r + 3 + index * 3
                color: aero.withAlpha(Qt.lighter(glass.tint, 1.6), 0.10 - index * 0.02)
                opacity: glass.focused ? 1.0 : (glass.hovered ? 0.55 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            }
        }

        // Frosted backdrop + gradient specular rim (needs QtQuick.Effects)
        Loader {
            id: fxLoader
            anchors.fill: parent
            active: glass.backdropBlur && aero.blur > 0 && glass.visible
            source: "AeroGlassFx.qml"
            onLoaded: {
                item.radius = Qt.binding(function() { return glass.r })
                item.blurAmount = Qt.binding(function() { return aero.blur })
                item.rimStrength = Qt.binding(function() { return glass.focused ? 1.0 : (glass.hovered ? 0.95 : 0.75) })
            }
        }

        // Light tint of the glass
        Rectangle {
            anchors.fill: parent
            radius: glass.r
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: aero.withAlpha(Qt.lighter(glass.tint, 1.25), glass.strength + (glass.hovered ? 0.08 : 0.0))
                }
                GradientStop {
                    position: 0.55
                    color: aero.withAlpha(glass.tint, glass.strength * 0.85 + (glass.hovered ? 0.05 : 0.0))
                }
                GradientStop {
                    position: 1.0
                    color: aero.withAlpha(Qt.darker(glass.tint, 1.35), Math.min(1.0, glass.strength * 1.05 + 0.04))
                }
            }
        }

        // Soft sheen: fades smoothly to nothing, so there is no visible band edge
        Rectangle {
            anchors.fill: parent
            radius: glass.r
            opacity: 0.5 + 0.5 * glass.density
            gradient: Gradient {
                GradientStop { position: 0.0; color: aero.withAlpha("#ffffff", 0.20) }
                GradientStop { position: 0.45; color: aero.withAlpha("#ffffff", 0.0) }
                GradientStop { position: 0.85; color: aero.withAlpha("#ffffff", 0.0) }
                GradientStop { position: 1.0; color: aero.withAlpha(Qt.lighter(glass.tint, 1.6), 0.14) }
            }
        }

        // Inner glow: a few nested hairlines that fade towards the centre
        Repeater {
            model: 3
            delegate: Rectangle {
                x: 1 + index * 1.5
                y: 1 + index * 1.5
                width: glass.width - 2 - index * 3
                height: glass.height - 2 - index * 3
                radius: Math.max(0, glass.r - 1 - index * 1.5)
                color: "transparent"
                border.width: 1.5
                border.color: aero.withAlpha("#ffffff", 0.11 - index * 0.035)
            }
        }

        // Plain rim: the whole edge (with the effects layer it is only a faint contour)
        Rectangle {
            anchors.fill: parent
            radius: glass.r
            color: "transparent"
            border.width: 1
            border.color: aero.withAlpha("#ffffff", glass.fxActive ? 0.14 : (glass.focused ? 0.85 : 0.42))
        }

        // Pressed state dims the surface softly
        Rectangle {
            anchors.fill: parent
            radius: glass.r
            color: "#000a14"
            opacity: glass.pressed ? 0.20 : 0.0
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }
    }
}
