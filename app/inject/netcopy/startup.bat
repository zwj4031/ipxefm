::公用脚本1如果有两个参数，立即执行任务
@echo off
set root=X:\windows\system32
set wait=pecmd wait 1000 
if not exist "X:\Program Files\WinXShell.exe" (
set say=%root%\pecmd.exe TEAM TEXT "
set font="L300 T300 R768 B768 $30^|wait 800 
set wait=echo ...
set xsay=echo ...
set show=echo ...
) else (
set say=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_led.zip -text
:::set say=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_led.zip -wait 5 -scroll -top -text
set show=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_show.zip -text
set xsay=start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
set wait=%root%\pecmd.exe wait 800
)
if not "%2" == "" set args1=%1&&set args2=%2&&goto startjob
::公用脚本1结束


:::创建符号链接，避免32位程序运行不正常
mklink %temp%\cmd.exe  C:\windows\system32\cmd.exe
::动画化批处理
color b0 
set a=51
set b=35
:re
set /a a-=2
set /a b-=2
mode con: cols=%a% lines=%b% 
if %a% geq 16 if %b% geq 1 goto re
if "%1" == "netghost" goto netghost
cd /d "%ProgramFiles(x86)%"
if exist "%ProgramFiles(x86)%\ghost\houx64.exe start "" "%ProgramFiles(x86)%\ghost\houx64.exe"
if exist "%ProgramFiles(x86)%\student\student.exe" start "" /min "%ProgramFiles(x86)%\student\student.exe"

%root%\pecmd.exe TEAM TEXT 正在初始化网络.......L300 T300 R768 B768 $30^|wait 500
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
%root%\pecmd.exe TEAM TEXT 关闭防火墙....... L300 T300 R768 B768 $30^|wait 5000 
wpeutil disablefirewall

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
::注册很方便的右键菜单
if exist %root%\ShowDrives_Gui_x64.exe start "" %root%\ShowDrives_Gui_x64.exe --Reg-All
%root%\pecmd.exe LINK %Desktop%\此电脑,%programfiles%\winxshell.exe,,%root%\ico\winxshell.ico
%root%\pecmd.exe LINK %Desktop%\ghostx64,%root%\ghostx64.exe
%root%\pecmd.exe LINK %Desktop%\netcopy网络同传,%root%\netcopyx64.exe
%root%\pecmd.exe LINK %Desktop%\CGI一键还原,%root%\cgix64.exe
%root%\pecmd.exe LINK %Desktop%\BT客户端,%root%\btx64.exe
%root%\pecmd.exe LINK %Desktop%\ImDisk_Gui镜像挂载,%root%\ShowDrives_Gui_x64.exe
%root%\pecmd.exe LINK %Desktop%\DG分区工具3.5,%root%\DiskGeniusx64.exe
%root%\pecmd.exe LINK %Desktop%\文件共享盘,explorer.exe,B:\
%root%\pecmd.exe LINK %Desktop%\文件共享盘,"%programfiles%\explorer.exe", B:\
%root%\pecmd.exe LINK %Desktop%\文件共享盘,"%windir%\winxshell.exe", B:\
%root%\pecmd.exe LINK %Desktop%\Ghost自动网克,"%root%\startup.bat",netghost,%root%\ico\ghost32.ico
%root%\pecmd.exe LINK %Desktop%\连接共享,"%root%\startup.bat",smbcli,%root%\ico\smbcli.ico
%root%\pecmd.exe LINK %Desktop%\多播接收,"%root%\startup.bat",cloud,%root%\ico\uftpd.ico
%root%\pecmd.exe LINK %Desktop%\多播发送,"%root%\uftp.exe",-R 800000,%root%\ico\uftp.ico
%root%\pecmd.exe LINK %Desktop%\TightVNC Viewer,"%root%\tightvnc\tvnviewer.exe" 

start "" "X:\windows\syswow64\client\DbntCli.exe" %ip% 21984

::::::::::::::公用脚本开始::::::::::::::
::::::::::::::检测IP脚本开始::::::::::::::
set n=0
:checkip
%xsay%
::上报本机ip到服务器
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig^|find /i "IPv4 地址 . . . . . . . . . . . . :"') do (
for /f "tokens=1,2 delims= " %%i in ('echo %%b')  do set myip=%%i
)
ipconfig /renew>nul
set /a n=%n%+1
%say% "第%n%(15)次获取IP" %font% 
%wait%::循环开始
if not "%myip%" == "" goto getipok
if "%n%" == "15" goto getipbuok
goto checkip
::获取ip成功
:getipok
%show% %myip% 
%say% "获取IP成功！本机ip:%myip% 上报中......" %font%
%wait%
echo .>%myip%
tftp %ip% put %myip% client/%myip%
%xsay%
%say% "上报完毕!" %font%
%wait%
%xsay%
goto init

::获取IP失败
:getipbuok
%say% "获取IP失败，DHCP服务不常，或没有网卡驱动" %font%
%wait%
%xsay%
%show% %myip% 
goto init
::::::::::::::检测IP脚本结束::::::::::::::


:init
::nc受控服务端
if exist %root%\nc.bat pecmd exec -hide %root%\nc.bat
::启动tightvnc
%root%\pecmd.exe kill tvnserver.exe
::密码reg add "HKCU\SOFTWARE\TightVNC\Server" /v Password /t REG_BINARY /d F0E43164F6C2E373 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v UseVncAuthentication /t REG_DWORD /d 0x0 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v UseControlAuthentication /t REG_DWORD /d 0x0 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v DisconnectClients /t REG_DWORD /d 0x0 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v DisconnectAction /t REG_DWORD /d 0x0 /f
start "" %root%\tightvnc\tvnserver.exe -run
::反向连接模式start "" "%root%\tightvnc\tvnserver.exe" -controlapp -connect %ip%
::::启动tightvnc
call :%job%&&exit
exit
::::从txt中提取服务器地址
:txtip
cd /d X:\windows\system32
for /f %%a in (ip.txt) do set ip=%%a
echo %ip%
%say% "初始化完成，准备执行相关任务！" %font%
%wait%
%xsay%
goto runtask
:::从dhcp中提取服务器地址
:dhcpip
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig /all^|find /i "DHCP 服务器 . . . . . . . . . . . :"') do (
for /f "tokens=1,2 delims= " %%i in ('echo %%b')  do set ip=%%i
)
goto runtask
exit

:startjob 
pecmd exec -hide %root%\nc.bat
if "%args2%" == "shell" (
%say% "接收到自定义命令[%args1%]" %font%
%wait%
%xsay%
::去掉双引号运行自定义命令
%args1:"=%
) else (
%say% "接收到任务[%args1%]" %font%
%wait%
%xsay%
call :%args1%
)
exit/b

:kill
%say% "正在结束进程" %font%
%wait%
%xsay%
for %%i in (cgix64.exe ghostx64.exe uftp.exe uftpd.exe netcopy64.exe btx64.exe diskgeniusx64.exe qbittorrent.exe) do (
%root%\pecmd.exe kill %%i
)
exit /b


:btonly
set p2pfile=I:\system.wim
set smbfile=b:\system.wim
::set diskpartfile=
call :checksmbfile
start "" %root%\btx64.exe
call :cloud
%say% "正在下载%p2pfile%，请等待..." %font%
goto checkp2pfile
exit /b

:p2pmbr
set p2pfile=I:\system.wim
set smbfile=b:\system.wim
set diskpartdir=mbr
::set diskpartfile=
call :checkdiskspace
call :initdiskpart
call :checksmbfile
start "" %root%\btx64.exe
call :cloud
%say% "正在下载%p2pfile%，请等待..." %font%
goto checkp2pfile
exit /b

:p2pgpt
set p2pfile=I:\system.wim
set smbfile=b:\system.wim
set diskpartdir=gpt
::set diskpartfile=
call :checkdiskspace
call :initdiskpart
call :checksmbfile
start "" %root%\btx64.exe
%say% "正在下载%p2pfile%，请等待..." %font%
goto checkp2pfile
call :cloud
exit /b

::::::执行任务
:dbmbr
set p2pfile=I:\system.wim
set smbfile=b:\system.wim
set diskpartdir=mbr
::set diskpartfile=
call :checkdiskspace
call :initdiskpart
call :checksmbfile
call :cloud
exit /b

:dbgpt
set p2pfile=I:\system.wim
set smbfile=b:\system.wim
set diskpartdir=gpt
::set diskpartfile=
call :checkdiskspace
call :initdiskpart
call :checksmbfile
call :cloud
exit /b

::::::执行检测硬盘容量任务
:checkdiskspace
%xsay%
set seldisk=masterdisk&&set disknum=0&&call :checkdisk
set seldisk=slaverdisk&&set disknum=1&&call :checkdisk
::[主盘]
if not "%masterdisk%" == "" (
set masterdiskpartfile=%root%\diskpart\%diskpartdir%\master\%masterdisk%_%diskpartdir%
%say% "检测到主盘容量为%masterdisk% 将调用%masterdisk%_%diskpartdir%脚本" %font%
%wait%
) else (
%say% "检测不到主硬盘容量，请手工分区指定最大分区为I盘" %font%
%wait%
)
::[从盘]
%xsay%
if not "%slaverdisk%" == "" (
set slaverdiskpartfile=%root%\diskpart\%diskpartdir%\slaver\%slaverdisk%_%diskpartdir%
%say% "检测到从盘容量为%slaverdisk% 将调用%slaverdisk%_%diskpartdir%脚本" %font%
%wait%
) else (
%say% "检测不到从硬盘容量" %font%
)
exit /b

::::::执行检测硬盘容量任务
:checkdisk
for /f "tokens=1-2,4-5" %%i in ('echo list disk ^| diskpart ^| find ^"磁盘 %disknum%^"') do (
	echo %%i %%j %%k %%l
	if %%k gtr 101 if %%k lss 221 set %seldisk%=120G
	if %%k gtr 222 if %%k lss 233 set %seldisk%=240G
    if %%k gtr 234 if %%k lss 257 set %seldisk%=256G
    if %%k gtr 446 if %%k lss 501 set %seldisk%=500G
    if %%k gtr 882 if %%k lss 999 set %seldisk%=1t
    if %%k gtr 1862 if %%k lss 1999 set %seldisk%=2t
)>nul
exit /b
::::::执行分区任务
:initdiskpart
%xsay%
mode con: cols=40 lines=10 
::主盘
if not "%masterdisk%" == "" (
%say% "警告，即将分区,主硬盘%masterdisk%数据将丢失!!!!" %font%
call :daojishi
%say% "正在分区……" %font%
diskpart /s %masterdiskpartfile%
) else (
%say% "检测不到主硬盘容量，请手工分区指定I盘[放镜像]" %font%
%wait%
)
%xsay%
::从盘
if not "%slaverdisk%" == "" (
%say% "警告，即将分区,从硬盘%slaverdisk%数据将丢失!!!!" %font%
call :daojishi
%xsay%
%say% "正在分区……" %font%
diskpart /s %slaverdiskpartfile%
%wait%
exit /b
) else (
%say% "检测不到从硬盘容量" %font%
%wait%
)
%xsay%
call :smbdp
%xsay%
%say% "分区完成，准备接收种子!" %font%
%xsay%
exit /b

:checkp2pfile
%wait%
if exist %p2pfile% ( 
%say% "下载完成！准备还原%p2pfile%" %font%
start "" %root%\cgix64 dp.ini
exit /b
) else (
goto checkp2pfile
)
exit /b

:checksmbfile
%xsay%
if exist %smbfile% ( 
%say% "B盘发现%smbfile%,准备还原%smbfile%" %font%
%wait%
cd /d "X:\windows\system32" >nul
start "" /w %root%\cgix64.exe dp.ini
) else (
echo ..
)
exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::以上为危险脚本
::::::执行多播任务
:cloud
color 07
mode con: cols=40 lines=4 
%say% "正在准备多播接收端..." %font%
%wait%
%xsay%
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
%say% "连接会话名称为mousedos的ghostsrv……" %font%
%wait%
%xsay%
%root%\pecmd.exe kill ghostx64.exe >nul
cd /d "X:\windows\system32" >nul
ghostx64.exe -ja=mousedos -batch >nul
if errorlevel 1 goto netghost
exit

::::::执行netcopy同传任务
:netcopy
%say% "正在准备netcopy客户端,可取消切换成发送模式." %font%
%wait%
%xsay%

%root%\pecmd.exe kill netcopyx64.exe >nul
cd /d "X:\windows\system32" >nul
netcopyx64.exe
exit /b

::::::执行多次尝试映射共享任务
:smbcli
net use * /delete /y >nul
%say% "连接\\%ip%\pxe为B盘" %font%
%wait%
%xsay%
net use B: \\%ip%\pxe "" /user:guest
if "%errorlevel%" == "0" ( 
%say% "连接服务器成功！进入桌面!" %font%
%wait%
%xsay%
%xsay%
exit /b
) else (
%say% "连接超时！请确认共享名为PXE或PE未加载网卡驱动!" %font%
%wait%
%xsay%
%xsay%
ipconfig /renew>nul
goto smbcli
)
exit /b
::::::执行一次性尝试映射任务
:smbdp
net use * /delete /y >nul
%say% "连接\\%ip%\pxe为B盘" %font%
net use B: \\%ip%\pxe "" /user:guest
%xsay%
%xsay%
exit /b

:daojishi
%xsay%
for /l %%i in (15,-1,1) do (
%say% "倒时计:%%i秒后开始分区!如需中断，请关闭批处理或关机..........." %font%
%wait%
%xsay%
)


