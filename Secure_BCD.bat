@echo off
mode con cols=90 lines=15
title TFTP传输速率调整
if exist Boot\BCD del /q /f Boot\BCD
:bd_bcd
set pxeid={19260817-6666-8888-f00d-caffee000009}
bcdedit.exe /createstore Boot\BCD
bcdedit.exe /store Boot\BCD /create {ramdiskoptions} /d "Ramdisk options"
bcdedit.exe /store Boot\BCD /set {ramdiskoptions} ramdisksdidevice boot
bcdedit.exe /store Boot\BCD /set {ramdiskoptions} ramdisksdipath \Boot\boot.sdi
bcdedit.exe /store Boot\BCD /create %pxeid% /d "winpe boot image" /application osloader
bcdedit.exe /store Boot\BCD /set %pxeid% device ramdisk=[boot]\sources\boot.wim,{ramdiskoptions} 
rem bcdedit.exe /store Boot\BCD /set %pxeid% path \windows\system32\winload.exe 
bcdedit.exe /store Boot\BCD /set %pxeid% osdevice ramdisk=[boot]\sources\boot.wim,{ramdiskoptions} 
bcdedit.exe /store Boot\BCD /set %pxeid% systemroot \windows
bcdedit.exe /store Boot\BCD /set %pxeid% detecthal Yes
bcdedit.exe /store Boot\BCD /set %pxeid% winpe Yes
bcdedit.exe /store Boot\BCD /create {bootmgr} /d "boot manager"
bcdedit.exe /store Boot\BCD /set {bootmgr} timeout 30 
bcdedit.exe /store Boot\BCD -displayorder %pxeid% -addlast
rem 关闭metro启动
bcdedit /store Boot\BCD /set %pxeid% bootmenupolicy legacy
cls
echo 创建BCD引导菜单完成...
:tftpblocksizemenu
echo.
echo 修改传输速率，请选择一个选项!
echo 1. 超高速 [可能不稳定]
echo 2. 高速   [推荐]
echo 3. 中等
echo 4. 保守   [网络不稳定选择]
echo.
set /p choice=请输入你的选择（1-4）然后按回车键:
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' set blocksize=16384
if '%choice%'=='2' set blocksize=8192
if '%choice%'=='3' set blocksize=4096
if '%choice%'=='4' set blocksize=512
if '%choice%'=='' echo 无效的选择, 请重新输入. &&goto menu
bcdedit /store Boot\BCD /set {ramdiskoptions} ramdisktftpblocksize %blocksize%
echo 修改完成
timeout 2 /nobreak
exit /b

