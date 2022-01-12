@ECHO OFF&PUSHD %~DP0 &TITLE 史上最伟大局域网PE控制器
set root=%systemroot%\system32
if not exist %~dp0client md %~dp0client
mode con cols=36 lines=36

color 0f

:menu

cls


echo 想让minipe执行什么任务
echo ==============================
echo 输入1，网络克隆-ghost
echo 输入2，网络同传-netcopy
echo ==============================
echo 输入3，全自动分区-P2P部署[MBR]
echo 输入4，全自动分区-P2P部署[GPT]
echo 输入5，全自动分区-多播部署[MBR]
echo 输入6，全自动分区-多播部署[GPT]
echo ==============================
echo 输入7，仅P2P部署[不分区]
echo 输入8，仅多播接收[不分区]
echo 输入9, 仅HOU多播接收[不分区]
echo ==============================

echo 输入s，自定义执行命令[CMD命令]
echo 输入x，下载文件并执行[PE客户端]
echo 输入d  下载文件到PE  [PE客户端]
echo ==============================
echo 输入b，强制终止当前任务
echo 输入c，清空客户机列表
echo 输入r，恢复上一次客户机列表
echo ==============================
echo 输入k，控制PE客户端桌面
echo ==============================
for /f %%i in ('dir /b %~dp0client\') do (
@echo 在线客户端%%i  
)
set /p user_input=请输入：
if %user_input% equ 1 set job=startup.bat netghost now&&set jobname=网络克隆-ghost&&call :dojob
if %user_input% equ 2 set job=startup.bat netcopy now&&set jobname=网络同传-netcopy&&call :dojob
if %user_input% equ 3 set job=startup.bat p2pmbr now&&echo 数据将丢失!回车三次确认&&pause&&pause&&pause&&set jobname=P2P自动部署-MBR&&call :dojob
if %user_input% equ 4 set job=startup.bat p2pgpt now&&echo 数据将丢失!回车三次确认&&pause&&pause&&pause&&set jobname=P2P自动部署-GPT&&call :dojob
if %user_input% equ 5 set job=startup.bat dbmbr now&&echo 数据将丢失!回车三次确认&&pause&&pause&&pause&&set jobname=多播自动部署-MBR&&call :dojob
if %user_input% equ 6 set job=startup.bat dbgpt now&&echo 数据将丢失!回车三次确认&&pause&&pause&&pause&&set jobname=多播自动部署-GPT&&call :dojob
if %user_input% equ 7 set job=startup.bat btonly now&&set jobname=仅P2P部署[不分区]&&call :dojob
if %user_input% equ 8 set job=startup.bat cloud now&&set jobname=仅多播接收[不分区]&&call :dojob
if %user_input% equ 9 call :houc
if %user_input% equ b set job=startup.bat kill now&&set jobname=结束所有进程&&call :dojob
if %user_input% equ c call :mvclient
if %user_input% equ r call :reclient
if %user_input% equ s call :shell
if %user_input% equ k call :vncclient
if %user_input% equ m call :menu
if %user_input% equ x call :xrun
if %user_input% equ d call :xdown
goto menu

:dojob
echo 执行%jobname%任务
for /f %%i in ('dir /b %~dp0client\') do (
echo %%job%%| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b

:shell
echo 输入指令:[包括但不限于format、porn]
echo 关机指令:wpeutil shutdown
echo 重启指令:wpeutil reboot
echo 格式化指令:format /q /x /y I:
set /p command=请输入：
set jobname=执行指令为%command% command
for /f %%i in ('dir /b %~dp0client\') do (
echo %%i执行%command%
echo startup.bat "%%command%%" shell| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b


:xrun
echo 下载并执行文件 【批处理、EXE文件】
set /p xrunfile=输入要下载执行的文件：
for /f %%i in ('dir /b %~dp0client\') do (
echo %%i下载%xrunfile%
echo startup.bat xrun %xrunfile%| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b

:xdown
echo 仅下载文件到X:\ 【分区脚本、种子】
set /p xrunfile=输入要下载的文件：
for /f %%i in ('dir /b %~dp0client\') do (
echo %%i下载%xrunfile%
echo startup.bat xdown %xrunfile%| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b



:houc
echo HOU多播到I:\
set command=start "" houcx86 I:\
set jobname=执行指令为%command% command
for /f %%i in ('dir /b %~dp0client\') do (
echo startup.bat "%%command%%" shell| %~dp0bin\nc64.exe -t %%i  6086
)
exit /b


:mvclient
if not exist %~dp0client\local md %~dp0client\local
attrib +h %~dp0client
move /y %~dp0client\*.* %~dp0client\local.
exit /b

:reclient
if not exist %~dp0client\local md %~dp0client\local
attrib +h %~dp0client
move /y %~dp0client\local\*.* %~dp0client\
exit /b

:vncclient
cls
echo 当前在线客户端:
setlocal enabledelayedexpansion
set n=0
for /f %%i in ('dir /b %~dp0client\') do (
set /a n+=1
set pc!n!=%%i
@echo !n!.%%i  
)
set /p sel=你要远程到哪台机: 
echo 选中 !pc%sel%!
start "" %~dp0bin\tvnviewer.exe !pc%sel%!
call :menu
exit /b 