import QtQuick 2.0
import QtQuick.Controls 2.2

ItemDelegate {
    id: tile

    property GridView grid

    AeroPalette { id: aero }

    // Glass tile behind the PC / app artwork (Frutiger Aero)
    AeroGlass {
        z: -0.5
        visible: aero.enabled
        anchors.fill: parent
        anchors.margins: 6
        cornerRadius: 18
        hovered: tile.hovered
        pressed: tile.down
        focused: tile.highlighted
    }

    Component.onCompleted: {
        // Hide the stock Material highlight / ripple while the Aero glass is shown
        if (background) {
            background.visible = Qt.binding(function() { return !aero.enabled })
        }
    }

    highlighted: grid.activeFocus && grid.currentItem === this

    Keys.onLeftPressed: {
        grid.moveCurrentIndexLeft()
    }
    Keys.onRightPressed: {
        grid.moveCurrentIndexRight()
    }
    Keys.onDownPressed: {
        grid.moveCurrentIndexDown()
    }
    Keys.onUpPressed: {
        grid.moveCurrentIndexUp()

        // If we've reached the top of the grid, move focus to the toolbar
        if (grid.currentItem === this) {
            nextItemInFocusChain(false).forceActiveFocus(Qt.TabFocus)
        }
    }
    Keys.onReturnPressed: {
        clicked()
    }
    Keys.onEnterPressed: {
        clicked()
    }
}
