@echo off

:: For Windows, we rely on conda-build's files: section to separate packages
:: since the source build is complex and the libkrb5 package already builds everything
echo Windows krb5 package - using files separation from libkrb5 build 