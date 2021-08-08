@echo off
mode con cols=50 lines=4
title=GhostServer

cd /d %~dp0bin
start "" %~dp0bin\GhostSrv64.EXE
exit