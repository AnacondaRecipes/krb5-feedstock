@echo off

REM krb5 package gets utilities via files: section patterns
REM On Windows, we'll rely on the files: section to handle separation
REM instead of staging since conda-build environments may be isolated

echo "krb5 package build - files will be separated by conda-build files: patterns" 