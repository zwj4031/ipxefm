@echo off
mode con cols=16 lines=1
cd /d %systemroot%\system32

::::开始
set desktop=%USERPROFILE%\desktop
set QuickLaunch=X:\users\Default\AppData\Roaming\Microsoft\internet Explorer\Quick Launch\User Pinned\TaskBar
set StartMenu=X:\users\Default\AppData\Roaming\Microsoft\windows\Start Menu
set root=X:\windows\system32
set wait=pecmd wait 1000 
::::文字提示
if not exist "X:\Program Files\WinXShell.exe" (
set say=%root%\pecmd.exe TEAM TEXT "
set hello=echo ...
set font="L300 T300 R768 B768 $30^|wait 800 
set wait=echo ...
set xsay=echo ...
set show=echo ...
set xshow=echo ...
) else (
set font=
set say=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_led.zip -text
set hello=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_led.zip -wait 2 -scroll -text
set show=start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_show.zip -top -text
set xsay=start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
set xshow=start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_show')"
set wait=%root%\pecmd.exe wait 800
)
if not "%2" == "" set args1=%1&&set args2=%2&&goto startjob
::公用脚本1结束

echo 注册32位的 msi.dll
echo Regsvr32.exe /s %WinDir%\System32\Msi.dll
echo if exist "%WinDir%\SysWOW64\Msi.dll" %WinDir%\SysWOW64\Regsvr32.exe /s %WinDir%\SysWOW64\Msi.dll

::启动时建立快捷方式 winxShell接管无线图标
::pecmd LINK %StartMenu%\扇区小工具BOOTICE,%ProgramFiles%\OTHERS\BOOTICE.EXE
::pecmd LINK %StartMenu%\文件快搜,%ProgramFiles%\EVERYTHING\EVERYTHING.EXE
::pecmd LINK %StartMenu%\分区工具DiskGenius,%ProgramFiles%\DiskGenius\DiskGenius.exe 
if exist "X:\Program Files\wifi.wcs" start "" %root%\pecmd.exe LINK "%QuickLaunch%\开启wifi",%root%\pecmd.exe,%programfiles%\wifi.wcs,%root%\ico\wifi.ico
::start "" "X:\Program Files\WinXShell.exe" -ui -jcfg wxsUI\UI_WIFI\main.jcfg -hidewindow


::预加载快捷方式
start "" %root%\pecmd.exe LINK %Desktop%\iSCSI 发起程序,%root%\iscsicpl.exe,,%root%\ico\iscsicli.ico
start "" %root%\pecmd.exe LINK %Desktop%\iSCSI 服务端,%ProgramFiles%\Others\iscsiconsole.exe
start "" %root%\pecmd.exe LINK %Desktop%\PE 网络管理,%ProgramFiles%\PENetwork\PENetwork.exe
start "" %root%\pecmd.exe LINK %Desktop%\SkyIAR 驱动注入,%ProgramFiles%\Others\skyiar.exe
start "" %root%\pecmd.exe LINK %Desktop%\SoftMgr 软件管理,%ProgramFiles%\SoftMgr\QQPCSoftMgr.exe
start "" %root%\pecmd.exe LINK %Desktop%\远程工具,"%ProgramFiles%\winxshell.exe","%ProgramFiles%\Remote Control Tool",%root%\ico\remote.ico
start "" %root%\pecmd.exe LINK "%Desktop%\BatchTools 特色小工具","%ProgramFiles%\winxshell.exe","%ProgramFiles%\BatchTools",%root%\ico\batch.ico
start "" %root%\pecmd.exe LINK "%ProgramFiles%\Remote Control Tool\mstsc远程_console","%WinDir%\mstsc.exe",/console,"%WinDir%\mstsc.exe"
start "" %root%\pecmd.exe LINK "%ProgramFiles%\Remote Control Tool\mstsc远程","%WinDir%\mstsc.exe",,"%WinDir%\mstsc.exe"
start "" %root%\pecmd.exe LINK "%Desktop%\Microsoft Edge","%ProgramFiles%\edge\edge.bat",,"%ProgramFiles%\edge\edge.ico"
start "" %root%\pecmd.exe LINK "%Desktop%\腾讯QQ","%ProgramFiles%\qq\qq.bat",,"%ProgramFiles%\QQ\QQ.ico"
start "" %root%\pecmd.exe LINK "%Desktop%\微信","%ProgramFiles%\Wechat\Wechat.bat",,"%ProgramFiles%\Wechat\WeChat.ico"

:startmenu
%say% "加载开始菜单..."
if exist "X:\Program Files\Classic Shell\ClassicStartMenu.exe" (
regedit /s "X:\Program Files\Classic Shell\cs.reg"
start "" "X:\Program Files\Classic Shell\ClassicStartMenu.exe"
)
%xsay%


::导入注册表，初始化
regedit /s pe.reg
wpeinit



echo 改计算机名
set pcname=%time:~3,2%%random:~0,2%
%say% "修改计算机名为PE%pcname%..." %font%
reg add "HKLM\SYSTEM\ControlSet001\Control\ComputerName\ComputerName" /f /v "ComputerName" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\ControlSet001\Control\ComputerName\ActiveComputerName" /f /v "ComputerName" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\ControlSet001\services\Tcpip\Parameters" /f /v "hostname" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\ControlSet001\services\Tcpip\Parameters" /f /v "NV Hostname" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" /f /v "ComputerName" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" /f /v "ComputerName" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /f /v "hostname" /t REG_SZ /d "PE%pcname%"
reg add "HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" /f /v "NV Hostname" /t REG_SZ /d "PE%pcname%"
%xsay%
::桌面LED显示 
%show% 计算机名:PE%pcname%

goto installdrivers
:resetcom
%say% "重置COM和LPT口..."
:::(0400 0401 0500 0501 0502 0A05 0B00 0200 0800 0100 0001)
for %%a in (0400 0401 0500 0501 0502) do (
devcon disable *pnp%%a*
devcon enable *pnp%%a*
)
::start "" /min devcon rescan
%xsay%

::%say% "启动网络共享相关服务..." %font%
::net start lanmanserver>nul
::net start lanmanworkstation>nul
::%xsay%

:installdrivers
%say% "正在安装驱动..."
echo 解压驱动……
if exist %systemroot%\system32\drivers.7z  (
:::::7z x drivers.7z -o%temp%\pe-driver\drivers
DriverIndexer.exe load-driver drivers.7z drivers.index
)
%xsay%



:mklinktoipxefm
%say% "链接文件到Ipxefm"
mklink "X:\ipxefm\app\inject\default\DiskGeniusx86.exe" "X:\Program Files\DiskGenius\DiskGenius.exe"
mklink "X:\ipxefm\app\inject\default\cgix64.exe" "X:\Program Files\GhostCGI\CGI-plus_x64.exe"
mklink "X:\ipxefm\app\inject\default\ghostx64.exe" "X:\Program Files\GhostCGI\ghost64.exe" 
mklink "X:\ipxefm\app\inject\default\ShowDrives_Gui_x64.exe" "X:\Windows\System32\pecmd.exe" 
mklink "X:\ipxefm\app\inject\default\drivers.7z" "X:\Windows\System32\drivers.7z" 
::链接ipxefm的文件到PE工具
mklink "X:\Program Files\Remote Control Tool\TightVNC-远程控制.exe" "%SystemDrive%\ipxefm\bin\tvnviewer.exe" 
%xsay%
if exist "X:\ipxefm\app\inject\default\sysx64.exe" start "" /w "X:\ipxefm\app\inject\default\sysx64.exe"
reg add "HKCU\SOFTWARE\TightVNC\Server" /v UseVncAuthentication /t REG_DWORD /d 0x0 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v UseControlAuthentication /t REG_DWORD /d 0x0 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v DisconnectClients /t REG_DWORD /d 0x0 /f
reg add "HKCU\SOFTWARE\TightVNC\Server" /v DisconnectAction /t REG_DWORD /d 0x0 /f
if exist %root%\tightvnc\tvnserver.exe start "" %root%\tightvnc\tvnserver.exe -run
::反向连接模式start "" "%root%\tightvnc\tvnserver.exe" -controlapp -connect %ip%
::start "" pecmd.exe --imdisk-S
::start "" pecmd.exe --UnReg-System
%xsay%

:regright
%say% "注册右键..."
rem 注册右键
:::start "" pecmd.exe --Reg-All
::start "" pecmd --Reg-2REG
%xsay%

echo 右键菜单
reg delete "HKLM\SOFTWARE\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\services" /f 
reg delete "HKLM\SOFTWARE\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\控制面板" /f 
echo 用DriverIndexer安装驱动
reg add "HKCR\*\shell\用DriverIndexer安装驱动" /f /v "icon" /t REG_SZ /d "X:\Windows\System32\ico\mycomput.ico"
reg add "HKCR\*\shell\用DriverIndexer安装驱动\command" /f /ve /t REG_SZ /d "\"X:\windows\system32\Driverindexer\" load-driver \"%%1\""
reg add "HKCR\7-Zip.7z\shell\用DriverIndexer安装驱动" /f /v "icon" /t REG_SZ /d "X:\Windows\System32\ico\mycomput.ico"
reg add "HKCR\7-Zip.7z\shell\用DriverIndexer安装驱动\command" /f /ve /t REG_SZ /d "\"X:\windows\system32\Driverindexer\" load-driver \"%%1\""
reg add "HKCR\folder\shell\用DriverIndexer安装驱动" /f /v "icon" /t REG_SZ /d "X:\Windows\System32\ico\mycomput.ico"
reg add "HKCR\folder\shell\用DriverIndexer安装驱动\command" /f /ve /t REG_SZ /d "\"X:\windows\system32\Driverindexer\" load-driver \"%%1\""

echo Smb共享辅助
::reg add "HKCR\*\shell\映射网络驱动器(N)" /f /v "icon" /t REG_SZ /d "X:\Windows\System32\ico\mycomput.ico"
reg add "HKCR\folder\shell\映射网络驱动器(N)\command" /f /ve /t REG_SZ /d "X:\windows\smb.bat"
reg add "HKCR\folder\shell\映射网络驱动器(N)" /f /v "Position" /t REG_SZ /d "Middle"

reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\映射网络驱动器(N)\command" /f /ve /t REG_SZ /d "X:\windows\smb.bat"
reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\映射网络驱动器(N)" /f /v "Position" /t REG_SZ /d "Middle"

::reg add "HKCR\*\shell\断开网络驱动器的连接(C)" /f /v "icon" /t REG_SZ /d "X:\Windows\System32\ico\mycomput.ico"
reg add "HKCR\folder\shell\断开网络驱动器的连接(C)\command" /f /ve /t REG_SZ /d "net use * /delete /y"
reg add "HKCR\folder\shell\断开网络驱动器的连接(C)" /f /v "Position" /t REG_SZ /d "Middle"
reg add "HKCR\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}shell\断开网络驱动器的连接(C)\command" /f /ve /t REG_SZ /d "net use * /delete /y"

echo 共享目标目录
reg add "HKCR\folder\shell\共享\command" /f /ve /t REG_SZ /d "X:\windows\smb.bat netshare %%1"
reg add "HKCR\folder\shell\共享" /f /v "Position" /t REG_SZ /d "Middle"

echo 使用&Notepad++ 编辑
reg add "HKCR\*\shell\NotePad++" /f /ve /t REG_SZ /d "使用&Notepad++ 编辑"
reg add "HKCR\*\shell\NotePad++" /f /v "Icon" /t REG_SZ /d "X:\Program Files\Notepad++\notepad++.exe"
reg add "HKCR\*\shell\NotePad++\Command" /f /ve /t REG_SZ /d "X:\Program Files\Notepad++\notepad++.exe \"%%1\""


echo 用记事本打开该文件
reg add "HKCR\*\shell\Notepad" /f /ve /t REG_SZ /d "用记事本打开该文件(&F)"
reg add "HKCR\*\shell\Notepad" /f /v "Icon" /t REG_SZ /d "notepad.exe"
reg add "HKCR\*\shell\Notepad\Command" /f /ve /t REG_SZ /d "notepad \"%%1\""

echo 5大工具全注册表
reg add "HKCR\.reg\shell\reg2cmd" /f /ve /t REG_SZ /d "转换为cmd文件"
reg add "HKCR\.reg\shell\reg2cmd" /f /v "Icon" /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\",6"
reg add "HKCR\.reg\shell\reg2cmd\command" /f /ve /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\" --reg2cmd \"%%1\""
reg add "HKCR\.reg\shell\reg2inf" /f /ve /t REG_SZ /d "转换为inf文件"
reg add "HKCR\.reg\shell\reg2inf" /f /v "Icon" /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\",6"
reg add "HKCR\.reg\shell\reg2inf\command" /f /ve /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\" --reg2inf \"%%1\""
reg add "HKCR\.reg\shell\reg2wcs" /f /ve /t REG_SZ /d "转换为wcs文件"
reg add "HKCR\.reg\shell\reg2wcs" /f /v "Icon" /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\",6"
reg add "HKCR\.reg\shell\reg2wcs\command" /f /ve /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\" --reg2wcs \"%%1\""
reg add "HKCR\Directory\shell\MaxCab" /f /ve /t REG_SZ /d "CAB最大压缩"
reg add "HKCR\Directory\shell\MaxCab" /f /v "Icon" /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\",9"
reg add "HKCR\Directory\shell\MaxCab\command" /f /ve /t REG_SZ /d "\"X:\Windows\System32\pecmd.exe\" --MaxCab \"%%1\""



%say% "正在加载外置..."
if exist %systemroot%\pecmd.ini  (
start "" pecmd load %systemroot%\pecmd.ini
%xsay%
)
%xsay%

:sharex
%say% "完全共享X盘为X..."
::网络图标指示
net start netprofm
start "" pecmd exec! net share X=X:\ /grant:everyone,full /y

if exist %systemroot%\system32\startup.bat start "" %systemroot%\system32\startup.bat
%xsay%
%xsay%
exit

