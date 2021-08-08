@echo off
mode con cols=50 lines=4
title=BTServer

cd /d %~dp0
if exist %temp%\gaka\teacher.exe start "" %temp%\gaka\teacher.exe&&exit
if exist %~dp0app\inject\default\gakax86.exe start "" %~dp0app\inject\default\gakax86.exe
exit