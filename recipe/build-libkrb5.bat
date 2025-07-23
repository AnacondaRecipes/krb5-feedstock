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

:: Install everything first
nmake install NODEBUG=1
if errorlevel 1 exit 1

:: Create a shared directory to store files for the krb5 package
mkdir "%PREFIX%\krb5_utilities" 2>nul

:: Copy utility executables to shared location (krb5 package will copy them back)
copy "%LIBRARY_PREFIX%\bin\kinit.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\klist.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kdestroy.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kpasswd.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kswitch.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kvno.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\gss-client.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\gss-server.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kcpytkt.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kdeltkt.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\kfwcpcc.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\mit2ms.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\ms2mit.exe" "%PREFIX%\krb5_utilities\"
copy "%LIBRARY_PREFIX%\bin\ccapiserver.exe" "%PREFIX%\krb5_utilities\"

:: Remove utilities from libkrb5 package (keep only libraries, headers, etc.)
del "%LIBRARY_PREFIX%\bin\kinit.exe"
del "%LIBRARY_PREFIX%\bin\klist.exe"
del "%LIBRARY_PREFIX%\bin\kdestroy.exe"
del "%LIBRARY_PREFIX%\bin\kpasswd.exe"
del "%LIBRARY_PREFIX%\bin\kswitch.exe"
del "%LIBRARY_PREFIX%\bin\kvno.exe"
del "%LIBRARY_PREFIX%\bin\gss-client.exe"
del "%LIBRARY_PREFIX%\bin\gss-server.exe"
del "%LIBRARY_PREFIX%\bin\kcpytkt.exe"
del "%LIBRARY_PREFIX%\bin\kdeltkt.exe"
del "%LIBRARY_PREFIX%\bin\kfwcpcc.exe"
del "%LIBRARY_PREFIX%\bin\mit2ms.exe"
del "%LIBRARY_PREFIX%\bin\ms2mit.exe"
del "%LIBRARY_PREFIX%\bin\ccapiserver.exe"

:: libkrb5 now contains: DLLs, .lib files, headers, plugins (no executables) 