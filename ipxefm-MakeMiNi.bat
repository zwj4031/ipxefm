@echo off
cd /d %~dp0
mode con cols=50 lines=2
title=制作MINI.WIM中......
echo 隐藏网络图标
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v "Settings" /t REG_BINARY /d "30000000feffffff22020000030000003e0000002800000000000000d802000056050000000300006000000001000000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCANetwork /t REG_DWORD /d 1 /f
if exist "%~dp0mini\Program Files\PENetwork\penetwork.reg" reg import "%~dp0mini\Program Files\PENetwork\penetwork.reg"

if exist excel.txt del /q excel.txt
set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "正在制作MiNi.Wim,请稍候…"
echo 获取WINPE文件夹所有权
takeown /f "%~dp0" /r /d y 1>nul
cacls "%~dp0data" /T /E /G Everyone:F 1>nul
takeown /f "%~dp04" /r /d y 1>nul
cacls "%~dp0" /T /E /G Everyone:F 1>nul
%wimlib% capture "%~dp0mini " "%~dp0mini.wim" "WindowsPE" --boot --compress=lzx --rebuild
echo 生成列表中……

for /f "delims=" %%i in (%~dp0mini\mini_ntfs.txt) do (
if exist %%i @echo add "%%i" "%%i">>excel.txt
)
echo 正在把文件添加到wim……
%wimlib% update %~dp0mini.wim<excel.txt
echo 再次覆盖配置文件
%wimlib% update %~dp0mini.wim --command="add mini \ "
%wimlib% optimize %~dp0mini.wim
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "制作完成,你可以从客户机网络启动PE了!"
if exist excel.txt del /q excel.txt
