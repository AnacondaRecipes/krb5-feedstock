@echo off

set NO_LEASH=1

:: Finds stdint.h from msinttypes.
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

:: Set the install path
set KRB_INSTALL_DIR=%LIBRARY_PREFIX%

:: Need this set or libs/Makefile fails
set VISUALSTUDIOVERSION=%VS_MAJOR%0

cd src

:: Create Makefile for Windows (reuse the prep step)
nmake -f Makefile.in prep-windows
if errorlevel 1 exit 1

:: Build only the utilities we need (not the full build)
nmake NODEBUG=1
if errorlevel 1 exit 1

:: Install everything, then we'll let conda-build's files: section handle separation
nmake install NODEBUG=1
if errorlevel 1 exit 1

echo krb5 package build complete 