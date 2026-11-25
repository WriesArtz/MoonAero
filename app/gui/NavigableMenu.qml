import QtQuick 2.0
import QtQuick.Controls 2.2

Menu {
    property var initiator

    AeroPalette { id: aero }

    // Stock Material menu surface, or Aero glass when the theme is on
    background: Item {
        // Qt 6's Material style reads background.radius for the header and footer
        property real radius: aero.enabled ? 12 : 2

        Rectangle {
            visible: !aero.enabled
            anchors.fill: parent
            radius: 2
            color: "#424242"
        }

        AeroGlass {
            visible: aero.enabled
            anchors.fill: parent
            cornerRadius: 12
            density: Math.max(0.6, aero.glass)
            tint: Qt.darker(aero.scheme.mid, 1.35)
        }
    }

    onOpened: {
        // If the initiating object currently has keyboard focus,
        // give focus to the first visible and enabled menu item
        if (initiator.focus) {
            for (var i = 0; i < count; i++) {
                var item = itemAt(i)
                if (item.visible && item.enabled) {
                    item.forceActiveFocus(Qt.TabFocusReason)
                    break
                }
            }
        }
    }
}
