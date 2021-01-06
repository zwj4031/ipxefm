@echo off
set root=X:\windows\system32
if exist %root%\sysx64.exe start /w "" sysx64.exe
#color b0 
set a=50
set b=34
:re
set /a a-=1
set /a b-=1
mode con: cols=%a% lines=%b% 
if %a% geq 16 if %b% geq 1 goto re
::::MODE CON COLS=15 LINES=5
:::创建符号链接，避免32位程序运行不正常
mklink %temp%\cmd.exe  C:\windows\system32\cmd.exe
%root%\pecmd.exe LINK %Desktop%\ghostx64,%root%\ghostx64.exe
%root%\pecmd.exe LINK %Desktop%\netcopy网络同传,%root%\netcopyx64.exe
%root%\pecmd.exe LINK %Desktop%\CGI一键还原,%root%\cgix64.exe
%root%\pecmd.exe LINK %Desktop%\文件共享盘,explorer.exe,B:\
%root%\pecmd.exe LINK %Desktop%\连接共享,cmd.exe,"/c net use B: \\%ip%\pxe "" /user:guest&explorer.exe B:\"
cls
for /f "tokens=2 delims==" %%a in ('dir /b %root%\serverip*') do set ip=%%a
:判断ip值
if defined ip (
    goto runtask
) else (
%root%\pecmd.exe TEAM TEXT 提取服务器IP中，检测系统目录下有无ip.txt L204 T207 R1000 B768 $30^|wait 5000 
if exist X:\windows\system32\ip.txt @echo 文件存在.准备提取...&&goto txtip
if not exist X:\windows\system32\ip.txt @echo 文件不存在.dhcp作为服务器地址...&&goto dhcpip
)


:::检测服务器文件并退出
:runtask
cd /d "%ProgramFiles(x86)%"
%root%\pecmd.exe TEAM TEXT 得到服务器IP为%ip% L204 T207 R1000 B768 $30^|wait 2000 
echo 
cls
%root%\pecmd.exe TEAM TEXT 正在初始化网络.......L204 T207 R1000 B768 $30^|wait 5000 
ipconfig /renew>nul
goto autoexec
exit


::::从txt中提取服务器地址
:txtip
cd /d X:\windows\system32
for /f %%a in (ip.txt) do set ip=%%a
echo %ip%
%root%\pecmd.exe TEAM TEXT 初始化完成！准备执行相关任务…… L204 T207 R1000 B768 $30^|wait 3000 
goto runtask

:::从dhcp中提取服务器地址
:dhcpip
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig /all^|find /i "DHCP 服务器 . . . . . . . . . . . :"') do (
for /f "tokens=1,2 delims= " %%i in ('echo %%b')  do set ip=%%i
)
goto runtask
exit
:autoexec
%root%\pecmd.exe TEAM TEXT 正在连接会话名称为mousedos的ghostsrv…… L204 T207 R1000 B768 $30^|wait 2000 
X:\windows\system32\pecmd.exe kill ghostx64.exe >nul
cd /d "X:\windows\system32" >nul
ghostx64.exe -ja=mousedos -batch >nul
if errorlevel 1 goto autoexec
exit

