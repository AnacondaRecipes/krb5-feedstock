@echo off
setlocal enabledelayedexpansion

echo === BUILDING KRB5 WINDOWS ===
echo PREFIX: %LIBRARY_PREFIX%
echo BUILD_PREFIX: %BUILD_PREFIX%
echo HOST: %HOST%

REM Check if this is the second package (krb5) - if so, skip build
if exist "%LIBRARY_PREFIX%\Library\bin\kinit.exe" (
    echo === SKIPPING BUILD - FILES ALREADY EXIST ===
    echo This appears to be the second package build. Files already exist.
    exit /b 0
)

set NO_LEASH=1

REM Finds stdint.h from msinttypes.
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

REM Set the install path
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

REM Need this set or libs/Makefile fails
set VISUALSTUDIOVERSION=%VS_MAJOR%0

cd src

echo === CREATING MAKEFILE FOR WINDOWS ===
nmake -f Makefile.in prep-windows
if errorlevel 1 (
    echo ERROR: Makefile preparation failed
    exit 1
)

echo === BUILDING SOURCES ===
nmake NODEBUG=1
if errorlevel 1 (
    echo ERROR: Build failed
    exit 1
)

echo === INSTALLING ===
nmake install NODEBUG=1
if errorlevel 1 (
    echo ERROR: Install failed
    exit 1
)

echo === VERIFICATION ===
echo Checking critical installed files:
set CRITICAL_FILES=kinit.exe klist.exe krb5-config.exe krb5_64.dll krb5.h
set ERROR_COUNT=0

for %%f in (%CRITICAL_FILES%) do (
    if exist "%LIBRARY_PREFIX%\Library\bin\%%f" (
        echo ✓ %%f found in Library/bin/
    ) else if exist "%LIBRARY_PREFIX%\Library\include\%%f" (
        echo ✓ %%f found in Library/include/
    ) else (
        echo ✗ ERROR: %%f not found
        set /a ERROR_COUNT+=1
    )
)

if %ERROR_COUNT% GTR 0 (
    echo ERROR: %ERROR_COUNT% critical files missing
    exit /b 1
)

echo === BUILD COMPLETE === 