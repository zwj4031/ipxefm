cd /d %~dp0
@echo off
mode con cols=50 lines=2
for /f %%a in ('dir /b /s \pe_*.txt') do del /s /f %%a
title 制作MINI.WIM中......
copy "X:\Program Files\GhostCGI\ghost64.exe" X:\ipxefm\mini\Windows\System32\. /y
ver |find "22"
if errorlevel 0 set pelist=NewBeePlus.txt&&echo win11
if errorlevel 1 set pelist=NewBeePlus.txt&&echo win10
echo 隐藏网络图标
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v "Settings" /t REG_BINARY /d "30000000feffffff22020000030000003e0000002800000000000000d802000056050000000300006000000001000000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideSCANetwork /t REG_DWORD /d 1 /f
if exist "mini\Program Files\PENetwork\penetwork.reg" reg import "mini\Program Files\PENetwork\penetwork.reg"


set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -text "正在制作MiNi.Wim,请稍候…"
echo 获取WINPE文件夹所有权
title 获取WINPE文件夹所有权...
takeown /f "%~dp0" /r /d y 1>nul
cacls "%~dp0data" /T /E /G Everyone:F 1>nul
takeown /f "%~dp04" /r /d y 1>nul
cacls "%~dp0" /T /E /G Everyone:F 1>nul
%wimlib% capture "mini " "mini.wim" "WindowsPE" --boot --compress=lzx --rebuild
title 第一阶段生成有效列表文件，稍候...

del /s /f pe_*.txt
find "\" mini\%pelist%>pe_list.txt
type pe_list.txt|findstr /v /m "*">pe_add.txt
type pe_list.txt|findstr /I "*">pe_dir.txt


for /f "delims=" %%i in (pe_dir.txt) do (
dir /s /b "%%i">>pe_tmp.txt
)
for /f "delims=" %%i in (pe_add.txt) do (
if exist "X:%%i" echo X:%%i>>pe_tmp.txt
)


title 第二阶段生成wimlib列表文件...
for /f "tokens=1,2 delims=:" %%a in (pe_tmp.txt) do (
echo add "%%b" "%%b">>pe_excel.txt
)
title 第三阶段把文件添加到wim
%wimlib% update mini.wim<pe_excel.txt
title 收尾阶段再次覆盖配置文件
timeout 5 /nobreak
echo 再次覆盖配置文件
%wimlib% update mini.wim --command="add \windows\system32\config \windows\system32\config "
%wimlib% update mini.wim --command="add mini \ "
%wimlib% optimize mini.wim
start "" "%programfiles%\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "制作完成,你可以从客户机网络启动PE了!"
exit



::分离出文件名
for /f "tokens=1,2 delims=: " %%a in ('echo %1') do (
set path=%%a
set wim=%%b
)