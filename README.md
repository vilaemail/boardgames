# Boardgames

🎬 See a demo! [Click here](https://user-images.githubusercontent.com/7682833/200405597-fbfe37e0-a41e-4497-81c2-786d632c8d3d.webm). It is 1 minute video of web app, linux native app and local docker deployment of nakama server multiplaying tic-tac-toe game.

North star for the project is to provide single- and multi-player cross-platform gaming experience for "boardgame-like" games (i.e. dice/cards/"traditional" boardgames). The experience is supposed to leverage the fact we are using computing devices (phones, PCs, etc.) to enrich the gaming experience as opposed to trying to emulate real-life experience. For example, we can have computer do the time consuming and boring computations which real-life game requires people to do manually. 
Games themselves can and should be developed outside of this repository and by anyone.

If you are interested in **contributing** to the project, go to [CONTRIBUTING](./CONTRIBUTING).
If you need **help** or you are stuck, see [TROUBLESHOOTING](./TROUBLESHOOTING.md).
If you want to know the license of the project, see [COPYING](./COPYING).
If you want to run code for your self, read on...

## Pre-commit checklist
1. `dart analyze`. You could: Make sure to save your changes and then `dart fix --apply`.
1. Check it works on linux
1. `git commit`

## Local development with Linux native app and web app in Chrome (guide for Arch Linux host)

### Setup
1. Install flutter from [this AUR package](https://aur.archlinux.org/packages/flutter).
1. Ensure you can use flutter `sudo gpasswd -a <your-username> flutterusers`
1. Install docker and nodejs (needed for nakama server) `sudo pacman -S docker docker-compose nodejs npm`
1. Install build dependencies `sudo pacman -S cmake clang ninja`
1. Install IDE `sudo pacman -S code`
1. Open IDE `code .` and install extension named `Flutter`
1. Reboot.
1. Verify everything is OK by running `flutter doctor`. You can ignore errors related to chrome and android, see "Testing on other platforms" for instructions how to fix these.
1. Open IDE `code .` and do Ctrl+E, type `>flutter` and choose flutter doctor, ensure output shows no errors. You can ignore errors related to chrome and android, see "Testing on other platforms" for instructions how to fix these.

### Setup for Chrome
1. Install Chrome from [this AUR package](https://aur.archlinux.org/google-chrome.git).
1. Set variables
  ```
  export CHROME_EXECUTABLE=/opt/google/chrome/chrome
  ```
1. Verify there are no Chrome related errors by running `flutter doctor`

### Running
Linux native: `scripts/run-linux.sh`
Web (Chrome): `scripts/run-web.sh`
Multiplayer server: `scripts/run-server.sh` (WARNING: This assumes you are using iptables as firewall and CHANGES its configuration)

## Testing on other platforms

### Android (guide for Arch Linux host)

#### Setup
1. Install Android Studio from [this AUR package](https://aur.archlinux.org/android-studio.git).
1. Open Android Studio and install latest SDK.
1. Open Android Studio, choose more actions and then SDK manager. Install Android SDK Command-Line Tools from SDK tools.
1. Open Android Studio and create a virtual device (more actions and then virtual device manager).
1. Accept Android licenses `flutter doctor --android-licenses`
1. Verify there are no Android related errors by running `flutter doctor`

#### Run
Execute: `flutter run -d android`

### Mac

TODO

### iOS

TODO

### Windows

TODO

## Build for release

* For Linux
    * Build binary for your Arch Linux machine - Run `flutter build linux --release --obfuscate --split-debug-info=build/symbols/linux/v0.0.1`, output is in `./build/linux/x64/release/bundle/` which you can redistribute only to folks using same OS set-up as yours.
    * TODO Publish to snap store. [relevant guide](https://docs.flutter.dev/deployment/linux)
* For Web run `scripts/release-web.sh`, output is in `./build/web` which you should host.
    To test output locally, run:
    ```
      dart --disable-analytics
      dart pub global activate dhttpd
      dart pub global run dhttpd --path build/web
    ```
    And go to http://localhost:8080
* For Android
    1. Change signing config in build.gradle
    1. TODO Other steps might be needed. [relevant guide](https://docs.flutter.dev/deployment/android)
    1. Run `scripts/release-android.sh`, output is in `./build/app/outputs/bundle/release/app-release.aab` which you should publish to play store.
* TODO For Mac. [relevant guide](https://docs.flutter.dev/deployment/macos)
* TODO For iOS. [relevant guide](https://docs.flutter.dev/deployment/ios)
* TODO For Windows. [relevant guide](https://docs.flutter.dev/deployment/windows)

## Reference: Folders
- android: Flutter app Android specific.
- assets: All assets used in some way for the app. Not all are necessarily shipped with the app.
- ios: Flutter app iOS specific.
- lib: Flutter app cross platform.
- linux: Flutter app Linux specific.
- macos: Flutter app MacOS specific.
- nakama: Multiplayer server specific.
- scripts: Scripts used for local development.
- test: Flutter app tests.
- web: Flutter app Web specific.
- windows: Flutter app Windows specific.
