@echo off
:::创建符号链接，避免32位程序运行不正常
mklink %temp%\cmd.exe  C:\windows\system32\cmd.exe
set root=X:\windows\system32
::动画化批处理
color b0 
set a=50
set b=34
:re
set /a a-=1
set /a b-=1
mode con: cols=%a% lines=%b% 
if %a% geq 16 if %b% geq 1 goto re
if "%1" == "netghost" goto netghost
cd /d "%ProgramFiles(x86)%"
if exist "%ProgramFiles(x86)%\ghost\houx64.exe start "" "%ProgramFiles(x86)%\ghost\houx64.exe"
if exist "%ProgramFiles(x86)%\student\student.exe" start "" /min "%ProgramFiles(x86)%\student\student.exe"

%root%\pecmd.exe TEAM TEXT 正在初始化网络....... L300 T300 R768 B768 $30^|wait 5000 
ipconfig /renew >nul
@echo 初始化网卡完成.
::获得执行的任务名称%job%
for /f "tokens=1-2 delims=@ " %%a in ('dir /b %root%\*@*') do (
set %%a
set %%b
)
if not "%1" == "" set job=%1
%root%\pecmd.exe TEAM TEXT 得到服务器IP为%ip% L300 T300 R768 B768 $30^|wait 2000 
%root%\pecmd.exe TEAM TEXT 本次执行的任务%job% L300 T300 R768 B768 $30^|wait 2000 
%root%\pecmd.exe TEAM TEXT 关闭防火墙.......L300 T300 R768 B768 $30^|wait 5000 
wpeutil disablefirewall
::补丁缺少的系统组件

:::检测服务器文件并退出
:runtask
cd /d "%ProgramFiles(x86)%"

::下载三大程序
::for %%d in (ghostx64.exe netcopyx64.exe cgix64.exe) do (
::%root%\pecmd.exe TEAM TEXT 正在下载%%d L300 T300 R768 B768 $30^|wait 5000 
::if not exist %root%\%%d tftp -i %ip% get /app/inject/default/%%d %root%\%%d 
::)
::补丁缺少的系统组件
if exist %root%\sysx64.exe start /w "" sysx64.exe
:::创建符号链接，避免32位程序运行不正常
mklink %temp%\cmd.exe x:\windows\system32\cmd.exe
%root%\pecmd.exe LINK %Desktop%\此电脑,%programfiles%\winxshell.exe,,%programfiles%\winxshell.exe#1
%root%\pecmd.exe LINK %Desktop%\ghostx64,%root%\ghostx64.exe
%root%\pecmd.exe LINK %Desktop%\netcopy网络同传,%root%\netcopyx64.exe
%root%\pecmd.exe LINK %Desktop%\CGI一键还原,%root%\cgix64.exe
%root%\pecmd.exe LINK %Desktop%\BT客户端,%root%\btx64.exe
%root%\pecmd.exe LINK %Desktop%\ImDisk_Gui镜像挂载,%root%\ShowDrives_Gui_x64.exe
%root%\pecmd.exe LINK %Desktop%\DG分区工具3.5,%root%\DiskGeniusx64.exe
%root%\pecmd.exe LINK %Desktop%\文件共享盘,explorer.exe,B:\
%root%\pecmd.exe LINK %Desktop%\文件共享盘,"%programfiles%\explorer.exe", B:\
%root%\pecmd.exe LINK %Desktop%\文件共享盘,"%windir%\winxshell.exe", B:\
%root%\pecmd.exe LINK %Desktop%\Ghost自动网克,"%root%\startup.bat",netghost,%root%\ghostx64.exe#0
%root%\pecmd.exe LINK %Desktop%\连接共享,"%root%\startup.bat",smbcli,%programfiles%\winxshell.exe#11
%root%\pecmd.exe LINK %Desktop%\多播接收,"%root%\startup.bat",cloud,%programfiles%\winxshell.exe#33
%root%\pecmd.exe LINK %Desktop%\多播发送,"%root%\uftp.exe",-R 800000,%programfiles%\winxshell.exe#36

start "" "X:\windows\syswow64\client\DbntCli.exe" %ip% 21984
::::::::::::::公用脚本开始::::::::::::::
:::去执行任务
call :%job%&&exit
exit
::::从txt中提取服务器地址
:txtip
cd /d X:\windows\system32
for /f %%a in (ip.txt) do set ip=%%a
echo %ip%
%root%\pecmd.exe TEAM TEXT 初始化完成！准备执行相关任务！L300 T300 R768 B768 $30^|wait 3000 
goto runtask
:::从dhcp中提取服务器地址
:dhcpip
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig /all^|find /i "DHCP 服务器 . . . . . . . . . . . :"') do (
for /f "tokens=1,2 delims= " %%i in ('echo %%b')  do set ip=%%i
)
goto runtask
exit

::::::执行任务
:p2pmbr
set dpfile=I:\system.wim
set diskpartfile=500g_mbr
call :initdiskpart
start "" %root%\btx64.exe
goto checkp2pfile
exit /b

:p2pgpt
set dpfile=I:\system.wim
set diskpartfile=500g_gpt
call :initdiskpart
start "" %root%\btx64.exe
goto checkp2pfile
exit /b

::::::执行任务
:dbmbr
set dpfile=I:\system.wim
set diskpartfile=500g_mbr
call :initdiskpart
call :cloud
exit /b

:dbgpt
set dpfile=I:\system.wim
set diskpartfile=500g_gpt
call :initdiskpart
call :cloud
exit /b


:initdiskpart
%root%\pecmd.exe TEAM TEXT 正在准备部署系统_%diskpartfile% L300 T300 R768 B768 $30^|wait 5000 
call :smbdp
%root%\pecmd.exe TEAM TEXT 警告！即将分区！硬盘数据丢失!!!! L300 T300 R768 B768 $30^|wait 5000 
ping 127.0 -n 10 >nul
%root%\pecmd.exe TEAM TEXT 正在分区，请稍候！  L300 T300 R768 B768 $30^|wait 5000
mode con: cols=40 lines=10 
diskpart /s %root%\%diskpartfile%
%root%\pecmd.exe TEAM TEXT 分区完成！准备接收种子! L300 T300 R768 B768 $30^|wait 5000 
exit /b

:checkp2pfile
%root%\pecmd.exe TEAM TEXT 镜像正在下载,检测到%dpfile%后即将还原! L300 T1 R1000 B768 $30^|wait 8000
ping 127.0 -n 2 >nul
if exist %dpfile% ( 
 %root%\pecmd.exe TEAM TEXT 下载完成！准备还原%dpfile%！L300 T1 R1000 B768 $30^|wait 8000
 start "" %root%\cgix64 dp.ini
 exit /b
) else (
goto checkp2pfile
)
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::以上为危险脚本
::::::执行多播任务
:cloud
color 07
mode con: cols=40 lines=4 
%root%\pecmd.exe TEAM TEXT 正在准备多播接收端…… L300 T300 R768 B768 $30^|wait 2000 
%root%\pecmd.exe kill uftp.exe >nul
%root%\pecmd.exe kill uftpd.exe >nul
cd /d "X:\windows\system32" >nul
if exist I:\ (
echo 存在I盘,多播到I:\
start /min "多播到I:\" uftpd -B 2097152 -L %temp%\uftpd.log -D I:\
exit /b
) else (
echo 不存在I盘,多播到X:\
start /min "多播到X:\" uftpd -B 2097152 -L %temp%\uftpd.log -D X:\
exit /b
)
exit /b

::::::执行ghost网克任务
:netghost
%root%\pecmd.exe TEAM TEXT 正在连接会话名称为mousedos的ghostsrv…… L300 T1 R1000 B768 $30^|wait 8000
%root%\pecmd.exe kill ghostx64.exe >nul
cd /d "X:\windows\system32" >nul
ghostx64.exe -ja=mousedos -batch >nul
if errorlevel 1 goto netghost
exit

::::::执行netcopy同传任务
:netcopy
%root%\pecmd.exe TEAM TEXT 正在准备netcopy网络同传,接收端可以取消后切换成发送模式…… L300 T300 R768 B768 $30^|wait 2000 
%root%\pecmd.exe kill netcopyx64.exe >nul
cd /d "X:\windows\system32" >nul
netcopyx64.exe
exit /b

::::::执行多次尝试映射共享任务
:smbcli
net use * /delete /y >nul
%root%\pecmd.exe TEAM TEXT 正在连接共享\\%ip%\pxe为B盘.... L300 T1 R1000 B768 $30^|wait 8000
::echo 正在连接共享\\%ip%\pxe为B盘 
::echo 如果很久连不上，请确认主机%ip%开了名称为pxe的共享!，可关闭本窗口!
net use B: \\%ip%\pxe "" /user:guest
if "%errorlevel%"=="0" ( 
 %root%\pecmd.exe TEAM TEXT 连接服务器成功！准备进入桌面！L300 T1 R1000 B768 $30^|wait 2000
 exit /b
) else (
%root%\pecmd.exe TEAM TEXT 连接服务器超时！请确认主机的共享名为PXE或PE未加载网卡驱动! L300 T1 R1000 B768 $30^|wait 5000
goto runtask
)
exit /b
::::::执行一次性尝试映射任务
:smbdp
net use * /delete /y >nul
%root%\pecmd.exe TEAM TEXT 正在连接共享\\%ip%\pxe为B盘.... L300 T1 R1000 B768 $30^|wait 8000
net use B: \\%ip%\pxe "" /user:guest
exit /b


