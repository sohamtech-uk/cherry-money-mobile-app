#!/bin/sh
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

FLUTTER_DIR="$HOME/flutter"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 --branch stable "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter precache --ios
flutter pub get

cd ios
pod install
