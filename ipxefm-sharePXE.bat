@echo off
mode con cols=50 lines=4
title=sharePXE......

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
net share pxe /delete /y
net share pxe=%~dp0. /grant:Everyone,READ

exit
