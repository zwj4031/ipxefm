@echo off
mode con cols=50 lines=4
title=多播文件%1中......

cd /d %~dp0
%~dp0bin\uftp.exe -R 800000 %1
exit