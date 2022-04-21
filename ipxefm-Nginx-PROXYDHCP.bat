@echo off
mode con cols=45 lines=1
title=building......
@taskkill /f /im pxesrv.exe
@taskkill /f /im nginx.exe
pecmd kill nginx.exe
pecmd kill pxesrv.exe
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
(
echo [arch]
echo 00007=ipxe.efi
echo [dhcp]
echo start=1
echo proxydhcp=1
echo httpd=0
echo bind=1
echo smb=1
echo poolsize=998
echo root=%~dp0
echo filename=ipxe.bios
echo altfilename=ipxeboot.txt
)>%~dp0bin\config.INI
del /s /q %~dp0bin\~temp.*
mkdir %~dp0bin\log
mkdir %~dp0bin\temp
start ""  %~dp0bin\pxesrv.exe
title Nginx WEB服务 运行中
cd /d %~dp0bin
nginx.exe
exit
