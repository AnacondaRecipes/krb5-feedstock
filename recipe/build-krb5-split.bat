@echo off
setlocal enabledelayedexpansion

echo === BUILDING KRB5 WINDOWS ===

REM Always build everything - the file patterns in meta.yaml will determine what gets packaged
echo === BUILDING KRB5 (ALL COMPONENTS) ===

set NO_LEASH=1

REM Finds stdint.h from msinttypes.
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

REM Set the install path
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

REM Need this set or libs/Makefile fails
set VISUALSTUDIOVERSION=%VS_MAJOR%0

REM Set environment variables like conda-forge
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

REM Fix perl locale warnings
set LC_ALL=C
set LANG=C

REM Detect if building for ARM64 (native or cross)
set IS_ARM64=0
if "%target_platform%"=="win-arm64" set IS_ARM64=1
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set IS_ARM64=1

REM For ARM64: The krb5 makefile doesn't know about ARM64, so we use AMD64
REM Both are 64-bit little-endian, so the makefile logic works correctly
if "%IS_ARM64%"=="1" (
    echo === Setting CPU=AMD64 for ARM64 build compatibility ===
    set CPU=AMD64
)

cd src

REM For ARM64, fix CCAPI build issues (both native and cross-compile)
if "%IS_ARM64%"=="1" (

    REM For ARM64, define little-endian for brg_endian.h detection
    set "CL=/D__LITTLE_ENDIAN__ %CL%"

    REM For ARM64, remove invalid DLL base addresses from source templates
    REM ARM64 requires base >= 4GB, these legacy addresses are below that
    REM This is safe for x64 too - ASLR is preferred over fixed base addresses
    echo === FIXING DLL BASE ADDRESSES FOR ARM64 COMPATIBILITY ===
    powershell -Command "Get-ChildItem -Recurse -Include '*.in','Makefile' | ForEach-Object { $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue; if ($content -and $content -match '-base:0x') { $newContent = $content -replace '-base:0x[0-9a-fA-F]+', ''; Set-Content $_.FullName -Value $newContent -NoNewline; Write-Host ('Fixed: ' + $_.FullName) } }"
    
    echo === FIXING CCAPI FOR ARM64 ===
    
    REM Fix case-sensitive file extensions for MIDL
    pushd %SRC_DIR%\src\ccapi\common\win
    ren ccs_request.Acf ccs_request.acf 2>nul
    ren ccs_reply.Acf ccs_reply.acf 2>nul
    ren ccs_reply.Idl ccs_reply.idl 2>nul
    popd
    
    REM Add /env arm64 to MIDL commands in ccapi Makefile.in files
    powershell -Command "(Get-Content 'ccapi\lib\win\Makefile.in' -Raw) -replace 'midl \$\(MIDL_OPTIMIZATION\)', 'midl /env arm64 $(MIDL_OPTIMIZATION)' | Set-Content 'ccapi\lib\win\Makefile.in' -NoNewline"
    powershell -Command "(Get-Content 'ccapi\server\win\Makefile.in' -Raw) -replace 'midl \$\(MIDL_OPTIMIZATION\)', 'midl /env arm64 $(MIDL_OPTIMIZATION)' | Set-Content 'ccapi\server\win\Makefile.in' -NoNewline"
    echo Fixed MIDL commands for ARM64
    
    REM Remove unimplemented ccs_authenticate from debug.exports
    powershell -Command "(Get-Content 'ccapi\lib\win\debug.exports' -Raw) -replace '[ \t]*ccs_authenticate\r?\n', '' | Set-Content 'ccapi\lib\win\debug.exports' -NoNewline"
    echo Removed ccs_authenticate from debug.exports
)

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

REM Check for executables - use PREFIX which should be the correct install location
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

REM Check for additional executables that should be built
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