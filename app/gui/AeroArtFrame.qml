import QtQuick
import QtQuick.Effects

// Glass finish for opaque artwork (app box art): rounds the picture's corners and puts a colour
// wash, a soft sheen and the specular rim on top, so the art looks like it sits under the glass.
// Lives in its own file and is loaded lazily, so the app still works without QtQuick.Effects.
//
// Usage: Loader { active: aero.enabled; anchors.fill: art; source: "AeroArtFrame.qml"
//                 onLoaded: item.target = art }
Item {
    id: frame

    property Item target
    property real cornerRadius: 16
    property color tint: aero.scheme.accent

    AeroPalette { id: aero }


    // The art is drawn by this effect (rounded by a mask); the original Image is hidden meanwhile
    Rectangle {
        id: mask
        width: frame.width
        height: frame.height
        radius: frame.cornerRadius
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
        layer.textureSize: Qt.size(Math.max(1, width * 2), Math.max(1, height * 2))
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: frame.target
        maskEnabled: true
        maskSource: mask
    }

    Component.onCompleted: {
        if (target) {
            target.visible = false
        }
    }
    Component.onDestruction: {
        if (target) {
            target.visible = true
        }
    }

    // Colour wash that unifies the artwork with the glass
    Rectangle {
        anchors.fill: parent
        radius: frame.cornerRadius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(Qt.lighter(frame.tint, 1.3).r, Qt.lighter(frame.tint, 1.3).g, Qt.lighter(frame.tint, 1.3).b, 0.24) }
            GradientStop { position: 1.0; color: Qt.rgba(Qt.darker(frame.tint, 1.2).r, Qt.darker(frame.tint, 1.2).g, Qt.darker(frame.tint, 1.2).b, 0.28) }
        }
    }

    // Sheen: fades to nothing, no hard gloss band
    Rectangle {
        anchors.fill: parent
        radius: frame.cornerRadius
        gradient: Gradient {
            GradientStop { position: 0.0;  color: "#4dffffff" }
            GradientStop { position: 0.42; color: "#00ffffff" }
            GradientStop { position: 0.8;  color: "#00ffffff" }
            GradientStop { position: 1.0;  color: Qt.rgba(1, 1, 1, 0.16) }
        }
    }

    // Inner glow
    Repeater {
        model: 3
        delegate: Rectangle {
            anchors.fill: parent
            anchors.margins: 1 + index * 1.5
            radius: Math.max(0, frame.cornerRadius - (1 + index * 1.5))
            color: "transparent"
            border.width: 1.5
            border.color: Qt.rgba(1, 1, 1, 0.12 - index * 0.04)
        }
    }

    // Specular rim
    Rectangle {
        anchors.fill: parent
        radius: frame.cornerRadius
        color: "transparent"
        border.width: 1.5
        border.color: Qt.rgba(1, 1, 1, 0.8)
    }
}
