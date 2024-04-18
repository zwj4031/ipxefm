@echo off
:: 检查当前路径是否包含C:
set cu_path=%~dp0
if "%cu_path:~0,2%" == "C:" (
echo 禁止在C盘运行本批处理! 当前路径包含C:，禁止运行此批处理！
pause
exit /b
)
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
cd /d %~dp0
:start
mode con cols=65 lines=30
set bootwim=sources\boot.wim
title TFTP传输速率调整,当前启动:"\%bootwim%"
set "result=!path:~0,2!"
if exist %~dp0Boot\BCD del /q /f %~dp0Boot\BCD
:bd_bcd
set pxeid={19260817-6666-8888-f00d-caffee000009}
bcdedit.exe /createstore Boot\BCD
bcdedit.exe /store Boot\BCD /create {ramdiskoptions} /d "Ramdisk options"
bcdedit.exe /store Boot\BCD /set {ramdiskoptions} ramdisksdidevice boot
bcdedit.exe /store Boot\BCD /set {ramdiskoptions} ramdisksdipath \Boot\boot.sdi
bcdedit.exe /store Boot\BCD /create %pxeid% /d "winpe boot image" /application osloader
bcdedit.exe /store Boot\BCD /set %pxeid% device ramdisk=[boot]\%bootwim%,{ramdiskoptions} 
rem bcdedit.exe /store Boot\BCD /set %pxeid% path \windows\system32\winload.exe 
bcdedit.exe /store Boot\BCD /set %pxeid% osdevice ramdisk=[boot]\%bootwim%,{ramdiskoptions} 
bcdedit.exe /store Boot\BCD /set %pxeid% systemroot \windows
bcdedit.exe /store Boot\BCD /set %pxeid% detecthal Yes
bcdedit.exe /store Boot\BCD /set %pxeid% winpe Yes
bcdedit.exe /store Boot\BCD /set %pxeid% highestmode Yes
bcdedit.exe /store Boot\BCD /create {bootmgr} /d "boot manager"
bcdedit.exe /store Boot\BCD /set {bootmgr} timeout 30 
bcdedit.exe /store Boot\BCD -displayorder %pxeid% -addlast
rem 关闭metro启动
bcdedit /store Boot\BCD /set %pxeid% bootmenupolicy legacy
:menu_init
cls
echo 创建BCD引导菜单完成...
:tftpblocksizemenu
title TFTP传输速率调整,当前启动:"\%bootwim%"
echo 修改传输速率，请选择一个选项!
echo --------------------- 
echo 1. 超高速 [可能不稳定]
echo ---------------------
echo 2. 高速   [推荐]
echo ---------------------  
echo 3. 中等
echo ---------------------   
echo 4. 保守   [网络不稳定选择]
echo ---------------------  
echo 5. 引导其它PE 当前:"\%bootwim%"   [暂时仅支持WIM]
echo ---------------------

set /p choice=请输入你的选择（1-5）然后按回车键:
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' set blocksize=16384
if '%choice%'=='2' set blocksize=8192
if '%choice%'=='3' set blocksize=4096
if '%choice%'=='4' set blocksize=512
if '%choice%'=='5' goto selbootwim
if '%choice%'=='' echo 无效的选择, 请重新输入. &&goto menu
bcdedit /store Boot\BCD /set {ramdiskoptions} ramdisktftpblocksize %blocksize%
echo 修改完成
timeout 2 /nobreak
exit /b

:selbootwim
cls
echo 请选择WIM文件作为PE或RamOS启动
echo __________________________________
setlocal enabledelayedexpansion
set n=0
for /f %%i in ('dir /b /s %~dp0*.wim') do (
set /a n+=1
set pc!n!=%%i
@echo !n!.%%i  
)
echo __________________________________
echo [史上最伟大网管瞎搞工作室出品]
set /p sel=请选择数字:
set bootwim=!pc%sel%!
:: 设置当前路径和bootwim变量
set "currentPath=%~dp0"
set "bootwim=!bootwim:%currentPath%=!
bcdedit.exe /store Boot\BCD /set %pxeid% device ramdisk=[boot]\%bootwim%,{ramdiskoptions}
bcdedit.exe /store Boot\BCD /set %pxeid% osdevice ramdisk=[boot]\%bootwim%,{ramdiskoptions} 
goto menu_init
exit /b


