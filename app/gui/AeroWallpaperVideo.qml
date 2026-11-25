import QtQuick
import QtQuick.Window
import QtMultimedia

// Looping, silent (no audio output is attached) video wallpaper. Pauses while the window is hidden or in the
// background (also while streaming), so it costs nothing then.
Item {
    id: wp
    property url source
    readonly property bool ready: player.error === MediaPlayer.NoError
                                  && player.mediaStatus >= MediaPlayer.LoadedMedia
                                  && player.mediaStatus !== MediaPlayer.InvalidMedia

    readonly property bool wanted: wp.visible && wp.Window.active
    onWantedChanged: wanted ? player.play() : player.pause()

    MediaPlayer {
        id: player
        source: wp.source
        loops: MediaPlayer.Infinite
        videoOutput: out
        Component.onCompleted: if (wp.wanted) play(); else pause()
    }

    VideoOutput {
        id: out
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}
