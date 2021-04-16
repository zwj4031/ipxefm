@echo off
mode con cols=50 lines=4
title=MulticastServer file:%1......
if "%1" == "" start "" %~dp0bin\lsk.exe
cd /d %~dp0
%~dp0bin\uftp.exe -R 800000 %1
exit