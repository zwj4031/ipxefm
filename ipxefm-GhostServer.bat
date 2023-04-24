@echo off
mode con cols=50 lines=10
title=GhostServer
echo 自动确认一般都要加 -sure
echo 克隆后重启添加 -rb
echo gpt克隆报错参数添加 -ntexact
echo linux克隆添加 -ib

cd /d %~dp0bin
start "" %~dp0bin\GhostSrv64.EXE
echo 
pause
exit