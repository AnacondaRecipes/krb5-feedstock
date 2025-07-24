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

REM Set environment variables like conda-forge
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

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
set ERROR_COUNT=0

REM Check for executables
if exist "%LIBRARY_PREFIX%\Library\bin\kinit.exe" (
    echo ✓ kinit.exe found in Library/bin/
) else (
    echo ✗ ERROR: kinit.exe not found
    set /a ERROR_COUNT+=1
)

if exist "%LIBRARY_PREFIX%\Library\bin\klist.exe" (
    echo ✓ klist.exe found in Library/bin/
) else (
    echo ✗ ERROR: klist.exe not found
    set /a ERROR_COUNT+=1
)

REM Check for additional executables that should be built
if exist "%LIBRARY_PREFIX%\Library\bin\kpasswd.exe" (
    echo ✓ kpasswd.exe found in Library/bin/
) else (
    echo ✗ ERROR: kpasswd.exe not found
    set /a ERROR_COUNT+=1
)

if exist "%LIBRARY_PREFIX%\Library\bin\kswitch.exe" (
    echo ✓ kswitch.exe found in Library/bin/
) else (
    echo ✗ ERROR: kswitch.exe not found
    set /a ERROR_COUNT+=1
)

REM Check for DLLs
if exist "%LIBRARY_PREFIX%\Library\bin\krb5_64.dll" (
    echo ✓ krb5_64.dll found in Library/bin/
) else (
    echo ✗ ERROR: krb5_64.dll not found
    set /a ERROR_COUNT+=1
)

REM Check for headers
if exist "%LIBRARY_PREFIX%\Library\include\krb5.h" (
    echo ✓ krb5.h found in Library/include/
) else (
    echo ✗ ERROR: krb5.h not found
    set /a ERROR_COUNT+=1
)

if %ERROR_COUNT% GTR 0 (
    echo ERROR: %ERROR_COUNT% critical files missing
    exit /b 1
)

echo === BUILD COMPLETE === 