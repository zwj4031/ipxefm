@echo off
mode con cols=50 lines=5
title=building......
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
(
echo [arch]
echo 00007=ipxe.efi
echo [dhcp]
echo start=1
echo proxydhcp=0
echo httpd=1
echo bind=1
echo smb=1
echo poolsize=998
echo root=%~dp0
echo filename=ipxe.bios
echo altfilename=ipxeboot.txt
)>%~dp0bin\config.INI

::::start "" /min %~dp0bin\hfs.exe -c active=yes -a %~dp0bin\myhfs.ini
:::::for /f %%a in ('dir /b/a-d *.*') do start "" /min %~dp0bin\hfs.exe %%a
::::::call %~dp0bin\hfs.exe %~dp0%app imgs isos vhds pe wims wim boot
start ""  %~dp0bin\pxesrv.exe
exit
