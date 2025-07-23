@echo off

REM Copy utility executables from shared location back to final location
if not exist "%PREFIX%\krb5_utilities" (
    echo ERROR: krb5 utilities directory not found! libkrb5 must be built first.
    exit /b 1
)

echo Copying krb5 utilities to final location...
copy "%PREFIX%\krb5_utilities\*.exe" "%LIBRARY_PREFIX%\bin\"
if errorlevel 1 exit 1

REM Clean up shared directory
rmdir /s /q "%PREFIX%\krb5_utilities"

echo krb5 package build complete - utilities copied to Library/bin 