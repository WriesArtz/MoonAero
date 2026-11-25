import QtQuick 2.9
import QtQuick.Controls 2.2

// GroupBox that turns into a pane of Aero glass when the theme is enabled.
// With the theme off it draws the same thin frame as the stock Material one.
GroupBox {
    id: groupBox

    AeroPalette { id: aero }

    // Same as the stock label, nudged down so it sits inside the glass pane
    label: Label {
        x: groupBox.leftPadding
        y: aero.enabled ? 8 : 0
        width: groupBox.availableWidth
        text: groupBox.title
        font: groupBox.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    background: Item {
        // Stock Material frame (theme off)
        Rectangle {
            visible: !aero.enabled
            y: groupBox.topPadding - groupBox.padding
            width: parent.width
            height: parent.height - groupBox.topPadding + groupBox.padding
            color: "transparent"
            border.color: "#1fffffff"
            radius: 2
        }

        // Glass pane (theme on); it also sits behind the title
        AeroGlass {
            visible: aero.enabled
            width: parent.width
            height: parent.height
            density: Math.max(0.35, aero.glass * 0.75)
            cornerRadius: 14
        }
    }
}
