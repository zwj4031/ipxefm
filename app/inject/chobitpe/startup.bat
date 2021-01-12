@echo off
:::创建符号链接，避免32位程序运行不正常
mklink %temp%\cmd.exe  C:\windows\system32\cmd.exe
set root=X:\windows\system32
::动画化批处理
#color b0 
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

%root%\pecmd.exe TEAM TEXT 正在初始化网络.......L204 T207 R1000 B768 $30^|wait 5000 
ipconfig /renew >nul
@echo 初始化网卡完成.
::获得执行的任务名称%job%
for /f "tokens=1-2 delims=@ " %%a in ('dir /b %root%\*@*') do (
set %%a
set %%b
)
%root%\pecmd.exe TEAM TEXT 得到服务器IP为%ip% L204 T207 R1000 B768 $30^|wait 2000 
%root%\pecmd.exe TEAM TEXT 本次执行的任务%job% L204 T207 R1000 B568 $30^|wait 2000 
%root%\pecmd.exe TEAM TEXT 关闭防火墙.......L204 T207 R1000 B768 $30^|wait 5000 
wpeutil disablefirewall
::补丁缺少的系统组件

:::检测服务器文件并退出
:runtask
cd /d "%ProgramFiles(x86)%"

::下载三大程序
::for %%d in (ghostx64.exe netcopyx64.exe cgix64.exe) do (
::%root%\pecmd.exe TEAM TEXT 正在下载%%d L204 T207 R1000 B768 $30^|wait 5000 
::if not exist %root%\%%d tftp -i %ip% get /app/inject/default/%%d %root%\%%d 
::)

%root%\pecmd.exe LINK %Desktop%\ghostx64,%root%\ghostx64.exe
%root%\pecmd.exe LINK %Desktop%\netcopy网络同传,%root%\netcopyx64.exe
%root%\pecmd.exe LINK %Desktop%\CGI一键还原,%root%\cgix64.exe
%root%\pecmd.exe LINK %Desktop%\史上最伟大自动克隆,%root%\startup.bat,netghost
%root%\pecmd.exe LINK %Desktop%\文件共享盘,explorer.exe,B:\
%root%\pecmd.exe LINK %Desktop%\文件共享盘,WinXshell.exe,B:\
%root%\pecmd.exe LINK %Desktop%\连接共享,cmd.exe,"/c net use B: \\%ip%\pxe "" /user:guest&explorer.exe B:\"
start "" "X:\windows\syswow64\client\DbntCli.exe" %ip% 21984
goto %job%


::::::执行任务
:netghost
%root%\pecmd.exe TEAM TEXT 正在连接会话名称为mousedos的ghostsrv…… L204 T207 R1000 B768 $30^|wait 2000 
X:\windows\system32\pecmd.exe kill ghostx64.exe >nul
cd /d "X:\windows\system32" >nul
ghostx64.exe -ja=mousedos -batch >nul
if errorlevel 1 goto netghost
exit

:smbcli
net use * /delete /y >nul
%root%\pecmd.exe TEAM TEXT 正在连接共享\\%ip%\pxe为B盘....L204 T207 R1000 B768 $30^|wait 8000
::echo 正在连接共享\\%ip%\pxe为B盘 
::echo 如果很久连不上，请确认主机%ip%开了名称为pxe的共享!，可关闭本窗口!
net use B: \\%ip%\pxe "" /user:guest
if "%errorlevel%"=="0" ( 
 %root%\pecmd.exe TEAM TEXT 连接服务器成功！准备进入桌面！ L204 T207 R1000 B568 $30^|wait 2000
 exit
) else (
 %root%\pecmd.exe TEAM TEXT 连接服务器超时！如果连不上，请确认主机开了名称为pxe的共享! ！ L204 T207 R1000 B768 $30^|wait 5000
goto runtask
)
exit
:netcopy
%root%\pecmd.exe TEAM TEXT 正在启动网络同传netcopy…… L204 T207 R1000 B768 $30^|wait 2000 
start "" "%ProgramFiles(x86)%\ghost\netcopyx86.exe"

