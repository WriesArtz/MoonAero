import QtQuick
import QtQuick.Effects

// Blurred copy of the Aero scene. Loaded through a Loader so the app keeps working
// (with plain translucent glass) if QtQuick.Effects is unavailable.
Item {
    id: blurRoot
    property Item source: null
    property real amount: 0.6      // 0..1

    MultiEffect {
        anchors.fill: parent
        source: blurRoot.source
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 1.0
        blurMax: 48
        blurMultiplier: 0.3 + blurRoot.amount * 1.7
        saturation: 0.15
    }
}
