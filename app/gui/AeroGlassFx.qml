import QtQuick
import QtQuick.Effects

// Effects half of AeroGlass. Loaded through a Loader, so if QtQuick.Effects is not
// available the import fails and the glass silently stays plain translucent.
//
// Shows the blurred wallpaper (window.aeroBackdrop, produced once by AeroBackground)
// through the rounded panel, and draws a rim that is bright at the top-left and
// bottom-right and fades around the sides.
Item {
    id: fx

    property real radius: 20
    property real blurAmount: 0.6       // 0..1, kept for bindings; the blur itself lives in the backdrop
    property real rimStrength: 0.75

    readonly property Item backdrop: (Window.window && Window.window.aeroBackdrop) ? Window.window.aeroBackdrop : null
    property rect region: Qt.rect(0, 0, 1, 1)

    // Keep the cropped region glued to where this panel is on the window
    // (panels move while scrolling, animating or opening).
    function syncRegion() {
        if (!backdrop || width <= 0 || height <= 0)
            return
        var p = fx.mapToItem(backdrop, 0, 0)
        if (Math.abs(p.x - region.x) > 0.25 || Math.abs(p.y - region.y) > 0.25 ||
                Math.abs(width - region.width) > 0.25 || Math.abs(height - region.height) > 0.25)
            region = Qt.rect(p.x, p.y, width, height)
    }
    onWidthChanged: syncRegion()
    onHeightChanged: syncRegion()
    onBackdropChanged: syncRegion()
    Component.onCompleted: syncRegion()

    FrameAnimation {
        running: fx.visible && fx.Window.active && fx.backdrop !== null
        onTriggered: fx.syncRegion()
    }

    // Rounded shape used to clip the backdrop
    Rectangle {
        id: shape
        anchors.fill: parent
        radius: fx.radius
        visible: false
        layer.enabled: true
    }

    ShaderEffectSource {
        id: crop
        anchors.fill: parent
        visible: false
        sourceItem: fx.backdrop
        sourceRect: fx.region
        live: true
    }

    MultiEffect {
        anchors.fill: parent
        visible: fx.backdrop !== null
        source: crop
        maskEnabled: true
        maskSource: shape
        saturation: 0.25
        brightness: 0.05
    }

    // ----- Specular rim -------------------------------------------------------------
    Rectangle {
        id: ring
        anchors.fill: parent
        radius: fx.radius
        color: "transparent"
        border.width: 1.5
        border.color: "#ffffff"
        visible: false
        layer.enabled: true
    }

    // Diagonal profile: opaque at the top-left and bottom-right, faint in between
    Item {
        id: rimProfile
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle {
            width: fx.width + fx.height
            height: (fx.width + fx.height) * 0.7071
            anchors.centerIn: parent
            rotation: -45
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffffffff" }
                GradientStop { position: 0.18; color: "#ccffffff" }
                GradientStop { position: 0.5; color: "#2effffff" }
                GradientStop { position: 0.82; color: "#b3ffffff" }
                GradientStop { position: 1.0; color: "#f2ffffff" }
            }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: ring
        maskEnabled: true
        maskSource: rimProfile
        opacity: fx.rimStrength
    }
}
