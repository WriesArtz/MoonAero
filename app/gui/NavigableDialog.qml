import QtQuick 2.0
import QtQuick.Controls 2.5

Dialog {
    modal: true
    anchors.centerIn: Overlay.overlay

    AeroPalette { id: aero }

    // Stock Material dialog surface, or Aero glass when the theme is on
    background: Item {
        // Qt 6's Material style reads background.radius for the header and footer
        property real radius: aero.enabled ? 16 : 2

        Rectangle {
            visible: !aero.enabled
            anchors.fill: parent
            radius: 2
            color: "#424242"
        }

        AeroGlass {
            visible: aero.enabled
            anchors.fill: parent
            cornerRadius: 16
            density: Math.max(0.6, aero.glass)
            tint: Qt.darker(aero.scheme.mid, 1.35)
        }
    }

    Component.onCompleted: {
        // Qt 6's Material header and footer paint their own opaque surface;
        // hide it so the Aero glass shows through when the theme is on.
        if (header && header.background) {
            header.background.visible = Qt.binding(function() { return !aero.enabled })
        }
        if (footer && footer.background) {
            footer.background.visible = Qt.binding(function() { return !aero.enabled })
        }
    }

    onClosed: {
        // We must force focus back to the last item. If we don't,
        // gamepad and keyboard navigation will break after a
        // dialog appears.
        stackView.forceActiveFocus()
    }
}
