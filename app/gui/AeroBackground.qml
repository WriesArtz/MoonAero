import QtQuick 2.9
import QtQuick.Window 2.2

// Frutiger Aero backdrop: sky gradient, soft sun glow, light rays,
// two rolling hills and slowly rising soap bubbles.
Item {
    id: root

    AeroPalette { id: aero }

    // Sky
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: aero.scheme.top }
            GradientStop { position: 0.55; color: aero.scheme.mid }
            GradientStop { position: 1.0; color: aero.scheme.bottom }
        }
    }

    // Sun glow: concentric translucent discs fake a radial gradient
    Repeater {
        model: 6
        delegate: Rectangle {
            property real base: Math.max(root.width, root.height) * 0.55
            width: base * (1.0 - index * 0.15)
            height: width
            radius: width / 2
            x: root.width * 0.18 - width / 2
            y: -root.height * 0.10 - height / 2 + base * 0.15
            color: aero.withAlpha("#ffffff", 0.045)
        }
    }

    // Light rays
    Repeater {
        model: 3
        delegate: Rectangle {
            width: root.width * (0.10 + index * 0.05)
            height: root.height * 1.6
            x: root.width * (0.05 + index * 0.17)
            y: -root.height * 0.3
            rotation: 24
            transformOrigin: Item.Top
            gradient: Gradient {
                GradientStop { position: 0.0; color: aero.withAlpha("#ffffff", 0.14) }
                GradientStop { position: 1.0; color: aero.withAlpha("#ffffff", 0.0) }
            }
        }
    }

    // Hills: the top arcs of two huge circles that are mostly off-screen
    Rectangle {
        width: root.width * 1.5
        height: width
        radius: width / 2
        x: -root.width * 0.35
        y: root.height - root.height * 0.13
        gradient: Gradient {
            GradientStop { position: 0.0; color: aero.withAlpha(Qt.lighter(aero.scheme.bottom, 1.2), 0.45) }
            GradientStop { position: 0.2; color: aero.withAlpha(aero.scheme.bottom, 0.30) }
            GradientStop { position: 1.0; color: aero.withAlpha(aero.scheme.bottom, 0.0) }
        }
    }
    Rectangle {
        width: root.width * 1.3
        height: width
        radius: width / 2
        x: root.width * 0.30
        y: root.height - root.height * 0.08
        gradient: Gradient {
            GradientStop { position: 0.0; color: aero.withAlpha(Qt.darker(aero.scheme.bottom, 1.15), 0.50) }
            GradientStop { position: 0.2; color: aero.withAlpha(Qt.darker(aero.scheme.bottom, 1.3), 0.30) }
            GradientStop { position: 1.0; color: aero.withAlpha(aero.scheme.bottom, 0.0) }
        }
    }

    // Soap bubbles
    Repeater {
        model: aero.bubbles ? 14 : 0
        delegate: Item {
            id: bubble
            property real size: 22 + ((index * 37) % 70)
            property real startX: ((index * 211) % 100) / 100.0 * root.width
            width: size
            height: size
            x: startX
            y: root.height + size

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: aero.withAlpha("#ffffff", 0.07)
                border.width: 1
                border.color: aero.withAlpha("#ffffff", 0.55)

                // Specular highlight
                Rectangle {
                    x: parent.width * 0.18
                    y: parent.height * 0.12
                    width: parent.width * 0.40
                    height: parent.height * 0.20
                    radius: height / 2
                    rotation: -30
                    color: aero.withAlpha("#ffffff", 0.55)
                }
            }

            SequentialAnimation on y {
                running: root.visible && root.Window.active
                loops: Animation.Infinite
                PauseAnimation { duration: (index * 733) % 6000 }
                NumberAnimation {
                    from: root.height + bubble.size
                    to: -bubble.size
                    duration: 14000 + (index * 997) % 12000
                }
            }

            SequentialAnimation on x {
                running: root.visible && root.Window.active
                loops: Animation.Infinite
                NumberAnimation {
                    to: bubble.startX + 28
                    duration: 3500 + (index * 313) % 2500
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: bubble.startX - 28
                    duration: 3500 + (index * 313) % 2500
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
