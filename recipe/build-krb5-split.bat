@echo off
setlocal enabledelayedexpansion

echo === BUILDING KRB5 WINDOWS ===

set NO_LEASH=1

REM Set up proper library paths for conda OpenSSL
set INCLUDE=%LIBRARY_INC%;%INCLUDE%
set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%

REM Set OpenSSL paths as required by krb5 1.22+ build system
set OPENSSL_DIR=%LIBRARY_PREFIX%
set OPENSSL_VERSION=3

REM Debug: Verify OpenSSL setup
echo === OPENSSL CONFIGURATION ===
echo OPENSSL_DIR=%OPENSSL_DIR%
echo OPENSSL_VERSION=%OPENSSL_VERSION%
echo Expected DLL: %OPENSSL_DIR%\bin\libcrypto-%OPENSSL_VERSION%-x64.dll

if exist "%LIBRARY_BIN%\libcrypto-3-x64.dll" (
    echo ✓ Found libcrypto-3-x64.dll in conda environment
) else (
    echo ✗ WARNING: libcrypto-3-x64.dll not found, checking alternative names...
    dir "%LIBRARY_BIN%\*crypto*.dll" 2>nul
)

if exist "%LIBRARY_INC%\openssl\opensslv.h" (
    echo ✓ Found OpenSSL headers in conda environment
    findstr /C:"OPENSSL_VERSION_TEXT" "%LIBRARY_INC%\openssl\opensslv.h"
)

if exist "%LIBRARY_LIB%\libcrypto.lib" (
    echo ✓ Found libcrypto.lib in conda environment
) else (
    echo ✗ WARNING: libcrypto.lib not found
    dir "%LIBRARY_LIB%\*crypto*.lib" 2>nul
)

REM Set the install path
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

REM Need this set or libs/Makefile fails
set VISUALSTUDIOVERSION=%VS_MAJOR%0

REM Fix perl locale warnings
set LC_ALL=C
set LANG=C

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
if exist "%PREFIX%\Library\bin\kinit.exe" (
    echo ✓ kinit.exe found in Library/bin/
) else (
    echo ✗ ERROR: kinit.exe not found
    set /a ERROR_COUNT+=1
)

if exist "%PREFIX%\Library\bin\klist.exe" (
    echo ✓ klist.exe found in Library/bin/
) else (
    echo ✗ ERROR: klist.exe not found
    set /a ERROR_COUNT+=1
)

if exist "%PREFIX%\Library\bin\kpasswd.exe" (
    echo ✓ kpasswd.exe found in Library/bin/
) else (
    echo ✗ ERROR: kpasswd.exe not found
    set /a ERROR_COUNT+=1
)

if exist "%PREFIX%\Library\bin\kswitch.exe" (
    echo ✓ kswitch.exe found in Library/bin/
) else (
    echo ✗ ERROR: kswitch.exe not found
    set /a ERROR_COUNT+=1
)

REM Check for DLLs
if exist "%PREFIX%\Library\bin\krb5_64.dll" (
    echo ✓ krb5_64.dll found in Library/bin/
    echo Checking OpenSSL linkage:
    dumpbin /dependents "%PREFIX%\Library\bin\krb5_64.dll" | findstr /i "crypto ssl"
) else (
    echo ✗ ERROR: krb5_64.dll not found
    set /a ERROR_COUNT+=1
)

REM Check for headers
if exist "%PREFIX%\Library\include\krb5.h" (
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