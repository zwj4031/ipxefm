@echo off
mode con cols=50 lines=4
title=MulticastServer file:%1......
if "%1" == "" start "" %~dp0bin\hous.exe&&exit
cd /d %~dp0
%~dp0bin\hous %1
exit