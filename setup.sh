#!/usr/bin/env bash
# ==========================================================
#  Chay 1 lan sau khi clone (macOS / Linux):  ./setup.sh
#  Kiem tra Flutter dung phien ban, don cache, tai package.
# ==========================================================
cd "$(dirname "$0")" || exit 1

echo "=== 1. Kiem tra duong dan thu muc du an ==="
case "$PWD" in
  *" "*) echo "[CANH BAO] Duong dan co khoang trang: $PWD - nen chuyen sang ~/src/dang-ky-kham-benh";;
esac

echo "=== 2. Kiem tra Flutter ==="
if ! command -v flutter >/dev/null 2>&1; then
  echo "[LOI] Chua cai Flutter hoac chua them flutter/bin vao PATH."
  exit 1
fi

REQ=$(tr -d ' \r\n' < .flutter-version)
CUR=$(flutter --version 2>/dev/null | head -n 1 | awk '{print $2}')
echo "May ban: Flutter $CUR  |  Nhom dung: Flutter $REQ"
if [ "$CUR" != "$REQ" ]; then
  echo "[CANH BAO] Khac phien ban. Doi bang:  cd \$(dirname \$(which flutter))/.. && git fetch --tags && git checkout $REQ"
else
  echo "[OK] Dung phien ban"
fi

echo "=== 3. Don cache va tai package ==="
flutter clean
flutter pub get || { echo "[LOI] flutter pub get that bai - gui anh cho Hai."; exit 1; }

echo "=== 4. Kiem tra moi truong ==="
flutter doctor

echo "Xong! Mo may ao / cam dien thoai roi chay: flutter run"
