#!/usr/bin/env bash
# Vercel Linux 빌드: Flutter 웹 결과물은 build/web
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_DIR="${ROOT}/.flutter_sdk"
export PATH="${FLUTTER_DIR}/bin:${PATH}"

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  rm -rf "$FLUTTER_DIR"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get
flutter build web --release
