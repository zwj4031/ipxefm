@echo off
mode con cols=50 lines=4
title=种子分发

cd /d %~dp0
start "" %~dp0app\inject\default\btx64.exe
exit