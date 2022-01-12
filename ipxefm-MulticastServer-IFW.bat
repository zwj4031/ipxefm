@echo off
mode con cols=50 lines=4
title=MulticastServer file:%1......
if "%1" == "" start "" %~dp0bin\multicastsender64 system.TBI mousedos&&exit
cd /d %~dp0
%~dp0bin\multicastsender64 %1 mousedos
exit