cd /d %~dp0
@echo off
mode con cols=50 lines=2
title=制作MINI.WIM中......
title=制作MINI.WIM中......
echo 隐藏网络图标
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v "Settings" /t REG_BINARY /d "30000000feffffff22020000030000003e0000002800000000000000d802000056050000000300006000000001000000" /f
if exist "%~dp0mini\Program Files\PENetwork\penetwork.reg" reg import "%~dp0mini\Program Files\PENetwork\penetwork.reg"if exist mini.wim del /q /f mini.wim
set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"

start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "正在制作MiNi.Wim,请稍候…"
%wimlib% capture "X:\ " "%~dp0mini.wim" "WindowsPE" --config="%~dp0mini\mini.txt" --boot --compress=lzx --rebuild

%wimlib% update %~dp0mini.wim --command="add mini \ "

::%wimlib% update %~dp0mini.wim<bin\add2mini.txt
 
%wimlib% optimize %~dp0mini.wim
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "制作完成,你可以从客户机网络启动PE了!"
exit