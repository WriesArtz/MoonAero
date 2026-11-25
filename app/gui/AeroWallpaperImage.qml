import QtQuick
import QtQuick.Window

// Still image, GIF or animated WebP, cropped to fill the window.
// Animation pauses while the window is hidden or in the background.
Item {
    id: wp
    property url source
    readonly property bool ready: img.status === Image.Ready

    AnimatedImage {
        id: img
        anchors.fill: parent
        source: wp.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        smooth: true
        mipmap: true
        playing: wp.visible && wp.Window.active
        // Never decode something bigger than we can show
        sourceSize.width: Math.max(1, Math.min(wp.width, 3840))
    }
}
