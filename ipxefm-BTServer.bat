@echo off
mode con cols=50 lines=4
title=BTServer

cd /d %~dp0
if exist %temp%\qBittorrent\qbittorrent.exe start "" %temp%\qBittorrent\qbittorrent.exe
start "" %~dp0app\inject\default\btx64.exe
exit