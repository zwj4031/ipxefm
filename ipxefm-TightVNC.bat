@echo off
mode con cols=50 lines=5
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

:start
::::start "" /min %~dp0bin\hfs.exe -c active=yes -a %~dp0bin\myhfs.ini
:::::for /f %%a in ('dir /b/a-d *.*') do start "" /min %~dp0bin\hfs.exe %%a
::::::call %~dp0bin\hfs.exe %~dp0%app imgs isos vhds pe wims wim boot
start ""  %~dp0bin\tvnviewer.exe
exit
