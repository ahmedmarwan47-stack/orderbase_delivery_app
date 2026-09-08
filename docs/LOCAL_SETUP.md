# Local setup on a Mac

Everything you need to install to build and run the Orderbase courier app locally,
in the order to do it. Written for a fresh Mac where **Xcode + an iOS Simulator
runtime are already installed**.

Target toolchain (from `pubspec.lock`):

| Requirement | Version |
|---|---|
| Flutter | **≥ 3.44.0** (stable channel) |
| Dart | **≥ 3.12.2** (ships with Flutter — don't install Dart separately) |
| iOS deployment target | 13.0 |
| Xcode | 16 or newer (26.x is what the project was verified on) |
| JDK (Android only) | 17 |

---

## 1. Xcode housekeeping — no download, just run these

Installing Xcode.app from the App Store is not enough; the command-line side has to be
selected and its first-launch steps accepted, or `flutter doctor` and the simulator MCP
will both fail with *"Xcode installed but not selected"*.

```bash
xcode-select --install                                    # Command Line Tools (git, clang, make)
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
sudo softwareupdate --install-rosetta --agree-to-license   # Apple silicon only
```

Confirm a simulator runtime is present:

```bash
xcrun simctl list devices available | grep -i iPhone
```

Installing Xcode does **not** install an iOS runtime, so this often prints nothing on a fresh
machine — `flutter run` then has no device to target. Install one (~7 GB):

```bash
xcodebuild -downloadPlatform iOS
```

(Same thing as Xcode → Settings → Components → iOS, just easier to leave running.) Re-run the
`simctl` line afterwards; you should get a list of iPhones.

> **If the App Store refuses to install Xcode** — *"This version of Xcode isn't supported in this
> version of macOS"* — check whether you already have a working copy before chasing it:
> `xcodebuild -version`. On a macOS beta/seed the App Store can refuse an Xcode that is already
> installed and perfectly usable. If you genuinely don't have one, grab a build matching your macOS
> from <https://developer.apple.com/download/all/>; **Xcode 16 or newer is enough for this project**.

## 2. Flutter SDK — the one real download

Get the **macOS stable** bundle for your CPU (Apple silicon vs Intel) from
<https://docs.flutter.dev/get-started/install/macos/mobile-ios>, or clone it:

```bash
mkdir -p ~/development && cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
```

> **Install it at `~/development/flutter`.** `CLAUDE.md` and `.claude/launch.json` both
> assume that path (`/Users/<you>/development/flutter/bin/flutter`).

Put it on `PATH` permanently (zsh is the default shell on macOS):

```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
flutter --version        # must report Flutter >= 3.44.0, Dart >= 3.12.2
flutter precache --ios
```

Dart comes bundled — installing `dart` from Homebrew separately will shadow it and cause
version mismatches. Don't.

## 3. CocoaPods — probably **not** needed

The iOS project is already migrated to **Swift Package Manager**
(`ios/Runner.xcodeproj` references `FlutterGeneratedPluginSwiftPackage`, and there is no
`Podfile`). Turn the feature flag on once and you never touch Ruby or CocoaPods:

```bash
flutter config --enable-swift-package-manager
```

The only plugins with native Darwin code are `path_provider_foundation` and
`shared_preferences_foundation` (both pulled in transitively). If you ever disable the SPM
flag, Flutter falls back to CocoaPods and you *will* need it:

```bash
brew install cocoapods      # only in that case
```

## 4. Git + SSH access to the repo

The remote is SSH (`git@github.com:ahmedmarwan47-stack/orderbase_delivery_app.git`) —
HTTPS has no credentials configured. Git itself arrives with the Command Line Tools in
step 1; you just need a key on the machine:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
pbcopy < ~/.ssh/id_ed25519.pub          # paste into GitHub → Settings → SSH keys
ssh -T git@github.com                   # expect "successfully authenticated"
```

## 5. Claude Code CLI

To keep working on this repo with Claude locally:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Then run `claude` from the repo root — it picks up `CLAUDE.md` and the `.claude/skills/`
(Flutter_Base) rules automatically.

## 6. Editor — pick one

- **VS Code** (<https://code.visualstudio.com>) + the **Flutter** extension (it pulls in Dart).
  Lightest option, and `.claude/launch.json` already has a `flutter-web` config.
- **Android Studio** (<https://developer.android.com/studio>) + its Flutter/Dart plugins.
  Heavier, but you need it anyway if you want an Android emulator.

## 7. Optional extras

| Want | Install |
|---|---|
| Android builds/emulator | Android Studio + **JDK 17** (`brew install --cask temurin@17`), then `flutter doctor --android-licenses` |
| Browser fallback for quick UI checks | Google Chrome |
| Package manager for the above | Homebrew — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |

Nothing in this project needs Node, Python, Ruby, or Firebase tooling.

---

## First run

```bash
git clone git@github.com:ahmedmarwan47-stack/orderbase_delivery_app.git
cd orderbase_delivery_app
flutter pub get
open -a Simulator                 # boot any iPhone
flutter devices                   # the simulator should be listed
flutter run                       # first iOS compile takes ~100s
```

Fonts (Noto Kufi Arabic) and icons are committed under `assets/`, so there is no
font/asset download step.

Browser fallback (no Xcode involvement):

```bash
flutter run -d web-server --web-port 8080 --web-hostname 127.0.0.1
# then open http://127.0.0.1:8080 at a ~390x844 viewport
```

Note: the `web-server` device does **not** hot-reload on save — kill and restart the
process after editing.

## Verify the setup

```bash
./scripts/doctor.sh
```

It checks Xcode selection, the Flutter/Dart versions, the simulator runtime, and runs
`flutter pub get` + `flutter analyze` + `flutter test`. Green across the board means you
can pick up development where the remote sessions left off.
