@echo off

REM Copy utility executables from staging area to final location
REM libkrb5 moved them to staging, now krb5 copies them back to proper location

if not exist "%LIBRARY_PREFIX%\krb5_staging\bin" (
    echo ERROR: krb5 staging directory not found! libkrb5 must be built first.
    exit /b 1
)

REM Copy all utility executables from staging back to bin
xcopy "%LIBRARY_PREFIX%\krb5_staging\bin\*" "%LIBRARY_PREFIX%\bin\" /Y
if errorlevel 1 exit 1

REM Clean up staging directory
rmdir /s /q "%LIBRARY_PREFIX%\krb5_staging" 