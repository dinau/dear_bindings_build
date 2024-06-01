@echo off
set rootDrv=c:\drvDx
set msysRoot=%rootDrv%\msys32
set mingwRoot=%msysRoot%\mingw32

rem Start path setting
set path=

rem
set path=c:\gcc_nim\bin
set path=%path%;%rootDrv%\python
set path=%path%;%rootDrv%\cmake\bin
set path=%path%;c:\make\bin

set path=%path%;%rootDrv%\GnuWin32x\bin
rem set path=%path%;%msysRoot%\usr\bin
rem set path=%path%;%mingwRoot%\bin
set path=%path%;%rootDrv%\00emacs-home\vimtool

set path=%path%;%UserProfile%\.nimble\bin
set path=%path%;%rootDrv%\Git\bin
