@echo off
mode con cols=90 lines=15
title=安全启动模式网启服务端配置......
if "%SystemDrive%"== "X:" pecmd -kill pxesrv.cmd&&pecmd -kill hfs.exe
@taskkill /f /im pxesrv.exe
@taskkill /f /im hfs.exe
cd /d %~dp0
if not "%SystemDrive%" == "C:" echo WinPE&&goto start 
:: 获取管理员权限运行批处理
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs" 1>nul 2>nul
exit /b
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" ) 1>nul 2>nul
::本目录给everyone添加权限
echo Y|cacls %~dp0. /t /p everyone:f
echo Y|cacls %~dp0*.* /t /p everyone:f
:start
cd /d %~dp0
cls
call :buildwim
call :makejob
call Secure_BCD.bat

(
echo [arch]
echo 00007=bootmgr.efi
echo [dhcp]
echo start=1
echo proxydhcp=1
echo httpd=0
echo smb=1
echo bind=1
echo poolsize=998
echo root=%~dp0
echo filename=bootmgr.bios
)>%~dp0bin\config.INI

start "" /min %~dp0bin\hfs.exe -c active=yes

start "" /min %~dp0bin\pxesrv.exe
exit

:buildwim
if not exist bootmgr.efi copy /y app\wimboot\bootmgfw.efi bootmgr.efi
copy /y app\wimboot\boot.sdi  boot\Boot.sdi
copy /y app\wimboot\bcd boot\BCD
if not exist sources mkdir sources
copy /y mini.wim sources\boot.wim
exit /b



:makejob
set wimlib="bin\wimlib.exe"
if "%SystemDrive%" == "X:" set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"
cls
echo 任务名称支持:(详细自行分析startup.bat或参考ipxeboot.txt)
echo netghost(网克)、smbcli(挂载共享)、cloud(多播)
echo p2pmbr/p2pgpt(p2p方式自动分区部署)
echo dbmbr/dbgpt(多播自动分区部署)
echo smbdp(共享恢复)、btonly（不分区)、
echo houmbr/hougpt（hou多播自动分区部署)、iscsi(自动连iscsi服务)
echo gaka(嘎卡/极域电子教室客户端)
echo -----------------------------------------------------------
echo 输入你要执行的任务名称:
echo netghost;netcopy;smbcli;p2pmbr;p2pgpt
echo dbmbr;dbp2p;btonly;smbdp;iscsi;gaka
set /p job=
::设置ip(共享B盘用)
::设置ip(共享B盘用)
echo 输入你要连接的服务器ip:
set /p ip=
:::::::::::::::::::::::::::::::
if not exist %~dp0sources (
echo sources目录不存在！功能无法使用! 
pause&&exit
) else (
call :cpwim
call :injectfiles
call :wtip
call :wtjob
call :buildwim
call :buildiso
)
exit /b

:cpwim
echo 复制mini.wim到build目录....
copy %~dp0mini.wim %~dp0sources\boot.wim /y
exit /b

:injectfiles
::注入inject目录的文件
for /f %%i in ('dir /b app\inject\default\*.*') do (
echo 注入%%i 到boot.wim!
%wimlib% update %~dp0sources\boot.wim --command="add 'app\inject\default\%%i' '\Windows\system32\%%i'"
)
if "%SystemDrive%"== "X:" (
rem 写入原软链接文件
%wimlib% update %~dp0sources\boot.wim --command="add '\Program Files\DiskGenius\DiskGenius.exe' '\Windows\system32\DiskGeniusx86.exe'"
%wimlib% update %~dp0sources\boot.wim --command="add '\Program Files\GhostCGI\CGI-plus_x64.exe' '\Windows\system32\cgix64.exe'"
%wimlib% update %~dp0sources\boot.wim --command="add '\Program Files\GhostCGI\ghost64.exe' '\Windows\system32\ghostx64.exe'"
%wimlib% update %~dp0sources\boot.wim --command="add '\Windows\System32\pecmd.exe' '\Windows\system32\ShowDrives_Gui_x64.exe'"
%wimlib% update %~dp0sources\boot.wim --command="add '\Windows\System32\drivers.7z' '\Windows\system32\drivers.7z'"
)
exit /b




:wtip
echo 写入ip和任务
del /q %~dp0sources\*@* /f
echo . >%~dp0sources\@ip^=%ip%@job^=%job%
exit /b

:wtjob
:::注入任务
for /f %%i in ('dir /b %~dp0sources\*@*') do (
echo 注入%%i 到boot.wim!
%wimlib% update %~dp0sources\boot.wim --command="add 'sources\%%i' '\Windows\system32\%%i'"
)
echo 写入完成，ip为%ip% 任务为%job%....
exit /b

:buildwim
%wimlib% optimize %~dp0sources\boot.wim
exit /b
