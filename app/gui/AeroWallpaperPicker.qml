import QtQuick
import QtQuick.Dialogs

// File chooser for the wallpaper (loaded on demand from the settings page).
FileDialog {
    id: picker
    signal picked(string path)
    title: qsTr("Choose a wallpaper")
    nameFilters: [
        qsTr("Images, GIFs and videos (*.png *.jpg *.jpeg *.bmp *.webp *.gif *.apng *.mp4 *.mov *.m4v *.webm *.mkv)"),
        qsTr("All files (*)")
    ]
    onAccepted: picked(selectedFile.toString())
}
