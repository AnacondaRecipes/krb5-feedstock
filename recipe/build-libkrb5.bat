set NO_LEASH=1

:: Finds stdint.h from msinttypes.
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

:: Set the install path
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

:: Need this set or libs/Makefile fails
set VISUALSTUDIOVERSION=%VS_MAJOR%0

cd src

:: Create Makefile for Windows.
nmake -f Makefile.in prep-windows
if errorlevel 1 exit 1

:: Build the sources
nmake NODEBUG=1
if errorlevel 1 exit 1

:: Install everything first (libkrb5 builds everything)
nmake install NODEBUG=1
if errorlevel 1 exit 1

:: Create staging directory for krb5 utilities
mkdir "%LIBRARY_PREFIX%\krb5_staging"
mkdir "%LIBRARY_PREFIX%\krb5_staging\bin"

:: Move utility executables to staging area (will be picked up by krb5 package)
move "%LIBRARY_PREFIX%\bin\kinit.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\klist.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kdestroy.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kpasswd.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kswitch.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kvno.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\gss-client.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\gss-server.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kcpytkt.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kdeltkt.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\kfwcpcc.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\mit2ms.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\ms2mit.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"
move "%LIBRARY_PREFIX%\bin\ccapiserver.exe" "%LIBRARY_PREFIX%\krb5_staging\bin\"

:: libkrb5 package keeps: DLLs, .lib files, headers, plugins
:: Utility executables are now in staging area for krb5 package 