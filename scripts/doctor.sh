#!/usr/bin/env bash
# Checks that a Mac has everything needed to build and run this app.
# See docs/LOCAL_SETUP.md for how to install anything that comes back missing.

set -uo pipefail

MIN_FLUTTER="3.44.0"
MIN_DART="3.12.2"

fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# Returns 0 when $1 >= $2 (dotted version compare).
version_ge() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$2" ]
}

head_ "Platform"
if [ "$(uname -s)" = "Darwin" ]; then
  ok "macOS $(sw_vers -productVersion) ($(uname -m))"
else
  warn "not macOS — the iOS checks below will be skipped"
fi

head_ "Xcode / iOS toolchain"
if [ "$(uname -s)" = "Darwin" ]; then
  if xcode-select -p >/dev/null 2>&1; then
    ok "developer dir: $(xcode-select -p)"
    if [ -x /usr/bin/xcodebuild ] && xcodebuild -version >/dev/null 2>&1; then
      ok "$(xcodebuild -version | head -1)"
    else
      bad "xcodebuild not usable — run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer && sudo xcodebuild -runFirstLaunch"
    fi
    if xcrun simctl list devices available 2>/dev/null | grep -qi iphone; then
      ok "iPhone simulator runtime available"
    else
      bad "no iPhone simulator runtime — install one from Xcode > Settings > Components"
    fi
  else
    bad "Command Line Tools missing — run: xcode-select --install"
  fi
fi

head_ "Flutter / Dart"
if command -v flutter >/dev/null 2>&1; then
  fv=$(flutter --version 2>/dev/null | sed -n 's/^Flutter \([0-9.]*\).*/\1/p' | head -1)
  dv=$(flutter --version 2>/dev/null | sed -n 's/.*Dart \([0-9.]*\).*/\1/p' | head -1)
  if [ -n "$fv" ] && version_ge "$fv" "$MIN_FLUTTER"; then
    ok "Flutter $fv (>= $MIN_FLUTTER)"
  else
    bad "Flutter ${fv:-unknown} — this project needs >= $MIN_FLUTTER (run: flutter upgrade)"
  fi
  if [ -n "$dv" ] && version_ge "$dv" "$MIN_DART"; then
    ok "Dart $dv (>= $MIN_DART)"
  else
    bad "Dart ${dv:-unknown} — this project needs >= $MIN_DART"
  fi
  case "$(command -v flutter)" in
    "$HOME/development/flutter/bin/flutter") ok "installed at ~/development/flutter (matches .claude/launch.json)" ;;
    *) warn "flutter lives at $(command -v flutter); .claude/launch.json expects ~/development/flutter/bin/flutter" ;;
  esac
  if flutter config 2>/dev/null | grep -q "enable-swift-package-manager: true"; then
    ok "Swift Package Manager enabled (no CocoaPods needed)"
  else
    warn "Swift Package Manager off — run: flutter config --enable-swift-package-manager (or install CocoaPods)"
  fi
else
  bad "flutter not on PATH — see docs/LOCAL_SETUP.md step 2"
fi

head_ "Git"
if command -v git >/dev/null 2>&1; then
  ok "$(git --version)"
  if ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    ok "GitHub SSH authentication works"
  else
    warn "GitHub SSH not authenticated — the remote is SSH-only (docs/LOCAL_SETUP.md step 4)"
  fi
else
  bad "git missing — run: xcode-select --install"
fi

if [ "$fail" -ne 0 ]; then
  printf '\n\033[31mSetup incomplete.\033[0m Fix the ✗ items above, then re-run this script.\n'
  exit 1
fi

head_ "Project checks"
cd "$(dirname "$0")/.." || exit 1
flutter pub get   || { bad "flutter pub get failed";  exit 1; }
flutter analyze   || { bad "flutter analyze failed";  exit 1; }
flutter test      || { bad "flutter test failed";     exit 1; }

printf '\n\033[32mAll good.\033[0m Run the app with: flutter run\n'
