@echo off
REM ==========================================================
REM  Chay 1 lan sau khi clone (Windows). Nhap dup de chay.
REM  Kiem tra Flutter dung phien ban, don cache, tai package.
REM ==========================================================
setlocal
cd /d "%~dp0"

echo.
echo === 1. Kiem tra duong dan thu muc du an ===
echo %CD%| findstr /R /C:" " >nul && (
  echo [CANH BAO] Duong dan co KHOANG TRANG: %CD%
  echo            Nen chuyen du an ve C:\src\dang-ky-kham-benh de tranh loi Gradle.
)

echo.
echo === 2. Kiem tra Flutter ===
where flutter >nul 2>nul
if errorlevel 1 (
  echo [LOI] Chua cai Flutter hoac chua them flutter\bin vao PATH.
  pause
  exit /b 1
)

set "REQ="
for /f "usebackq delims= " %%v in (".flutter-version") do set "REQ=%%v"
call flutter --version > "%TEMP%\flutter_ver.txt" 2>&1
type "%TEMP%\flutter_ver.txt"
findstr /C:"Flutter %REQ% " "%TEMP%\flutter_ver.txt" >nul
if errorlevel 1 (
  echo.
  echo [CANH BAO] Nhom dung Flutter %REQ% nhung may ban dang dung phien ban khac.
  echo            Doi phien ban: cd vao thu muc flutter roi chay
  echo              git fetch --tags
  echo              git checkout %REQ%
  echo            sau do chay lai setup.bat
  echo.
) else (
  echo [OK] Dung phien ban Flutter %REQ%
)

echo.
echo === 3. Don cache va tai package ===
call flutter clean
call flutter pub get
if errorlevel 1 (
  echo [LOI] flutter pub get that bai - xem thong bao phia tren, gui anh cho Hai.
  pause
  exit /b 1
)

echo.
echo === 4. Kiem tra moi truong (Android SDK, JDK, thiet bi) ===
call flutter doctor

echo.
echo Xong! Mo may ao / cam dien thoai roi chay:  flutter run
pause
