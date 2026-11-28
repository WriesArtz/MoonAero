# MoonAero: tema Frutiger Aero para Moonlight

Estética Frutiger Aero (cristal brillante, degradados aqua, sol, colinas y burbujas) para
**Moonlight Qt** (escritorio / macOS) y **Moonlight Android**. Es personalizable y se puede
apagar para volver al aspecto clásico. No toca el streaming: solo las pantallas de menú.

## Qué se personaliza

Ajustes → **Appearance** (Qt) / **Appearance (Frutiger Aero)** (Android). Los cambios se ven al instante.

| Opción | Detalle |
|---|---|
| Tema Frutiger Aero | Activado por defecto. Apagado = aspecto original de Moonlight |
| Preset de color | Aqua, Bliss, Sunset, Aurora o Custom |
| Color personalizado | Paleta de 10 colores o hex `#rrggbb`. Genera el cielo, el horizonte y el acento a partir de un solo color. Un gris da un tema grafito/plata |
| Opacidad del cristal | 10 % (muy claro) a 90 % (casi opaco) |
| Burbujas flotantes | Se detienen solas con la pantalla apagada o si las animaciones del sistema están desactivadas (Android) |

## Compilar en macOS (moonlight-qt)

Requisitos (los oficiales del proyecto): macOS reciente, **Xcode 15+**, **Qt 6.11+**
(instalador oficial de Qt o `brew install qt`), Python 3 y, solo para generar un DMG, `brew install create-dmg`.

```bash
git clone --recursive https://github.com/WriesArtz/MoonAero.git
cd MoonAero
git checkout frutiger-aero
python3 setup-deps.py                      # descarga las dependencias precompiladas para macOS
export PATH="$(brew --prefix qt)/bin:$PATH" # o la carpeta bin de tu Qt del instalador oficial
qmake6 moonlight-qt.pro
make release -j"$(sysctl -n hw.ncpu)"
```

Para un DMG instalable: `scripts/generate-dmg.sh Release` (desde la raíz del repo, con Qt en el `PATH`).
También puedes abrir `moonlight-qt.pro` en **Qt Creator** y compilar con el botón de Run.

## Compilar en Android (moonlight-android)

El parche está en `patches/moonlight-android-frutiger-aero.patch`. Está hecho sobre el commit
indicado en `patches/moonlight-android.base-commit`.

```bash
git clone --recursive https://github.com/moonlight-stream/moonlight-android.git
cd moonlight-android
git checkout $(cat /ruta/a/MoonAero/patches/moonlight-android.base-commit)   # recomendado; si usas master y falla, ver nota
git apply --check /ruta/a/MoonAero/patches/moonlight-android-frutiger-aero.patch
git apply /ruta/a/MoonAero/patches/moonlight-android-frutiger-aero.patch
```

Herramientas: **Android Studio** (con su JDK 17 integrado), en *SDK Manager* la plataforma
**Android SDK 37** y, en *SDK Tools*, **NDK (Side by side) 29.0.14206865** y CMake/Build-Tools recientes.
Crea `local.properties` en la raíz:

```properties
sdk.dir=/Users/TU_USUARIO/Library/Android/sdk
ndk.dir=/Users/TU_USUARIO/Library/Android/sdk/ndk/29.0.14206865
```

Compilar el APK (línea de comandos o Build > Build APK en Android Studio):

```bash
./gradlew assembleNonRootDebug
# resultado: app/build/outputs/apk/nonRoot/debug/app-nonRoot-debug.apk
adb install -r app/build/outputs/apk/nonRoot/debug/app-nonRoot-debug.apk
```

Un APK *release* necesita tu propia firma (keystore). El *debug* se instala tal cual.
Nota: si `master` de moonlight-android avanzó y el parche no aplica, usa el commit base o `git apply --3way`.

## Estado de la verificación

- **Qt**: los QML cargan sin avisos en Qt 6 y se renderizaron los 5 presets más el modo apagado; `qmllint` sin errores; el parche aplica limpio sobre este fork.
- **Android**: los recursos compilan con `aapt`, el paquete `com.limelight.aero` compila sin avisos y las ediciones a archivos existentes no añaden errores de compilación. La matemática de color da lo mismo que Qt (diferencia máxima 1/255).
- **Pendiente de tu lado**: no se pudo ejecutar en un Mac ni en un dispositivo Android desde este entorno. Prueba visual y de mandos/TV recomendada.
- Limitación conocida (Android): los diálogos del sistema (listas de opciones, avisos) conservan el estilo Material estándar.

## Liquid glass and wallpaper (v2)

**Liquid glass.** Panels, tiles, dialogs, menus and toolbar buttons now show a *blurred copy of the
background* through a rounded, softly tinted pane (frosted glass), with a specular rim that is brightest
at the top-left and bottom-right, a soft inner glow, diffuse shadows, and springy hover/press motion
(tiles and buttons overshoot slightly, then settle). Settings → Appearance → **Glass blur** (0–100 %)
controls the frost; 0 gives plain translucent glass. The blur is computed once per frame for the whole
window and cropped per panel, so many panels stay cheap. It needs `QtQuick.Effects` (Qt 6.5+); if it is
missing the glass falls back to the translucent look automatically.

**Wallpaper.** Settings → Appearance → *Choose image, GIF or video…* accepts PNG/JPG/BMP/WebP, GIF/APNG/animated
WebP and MP4/MOV/M4V/WEBM/MKV. It replaces the sky, is cropped to fill, can be dimmed (0–80 %), and pauses
while the window is in the background or while streaming. *Remove* returns to the sky. If a file cannot be
loaded, the sky stays visible. Videos are silent and loop. `QT += multimedia` was added to `app/app.pro`;
video codecs depend on the platform backend (macOS: AVFoundation, so H.264/HEVC .mp4/.mov are the safest).

New settings keys: `aeroblur`, `aerowallpaper`, `aerowallpaperdim`.

## PC icon, app tiles and app icon (v3)

* **PC tiles** show the aquarium iMac G3 picture (`app/res/aero_pc.png`, same image as the Android build)
  instead of the flat monitor while the theme is on; offline PCs are dimmed.
* **App tiles** round the box art and put the glass finish on top (colour wash, fading sheen, inner glow,
  specular rim) via `gui/AeroArtFrame.qml`, loaded lazily so the app still runs without `QtQuick.Effects`.
* **App icon:** `moonlight.icns` / `moonlight.ico` were regenerated from the new Frutiger Aero orb icon used
  by the Android build.

## Old Macs (crash at launch in MoltenVK)

On Macs with the legacy Metal driver (for example a 2012 MacBook Pro) the app can abort right after
launch inside `libMoltenVK` (`MVKPhysicalDevice::initMetalFeatures`, called from the libplacebo renderer).
This is an upstream Moonlight issue, not caused by the theme. Build without the Vulkan renderer:

    touch disable-libplacebo
    make distclean
    qmake6 moonlight-qt.pro
    make release
    grep -c LIBPLACEBO app/Makefile.Release     # must print 0
