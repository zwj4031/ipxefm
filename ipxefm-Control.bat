@ECHO OFF&PUSHD %~DP0 &TITLE 史上最伟大局域网PE控制器
if not exist %~dp0client md %~dp0client
mode con cols=46 lines=20

color 2f

:menu

cls

echo.

echo 想让minipe执行什么任务

echo ==============================

echo.

echo 输入1，网络克隆-ghost

echo.

echo 输入2，网络同传-netcopy

echo.

echo 输入3，全自动分区-P2P部署[MBR]

echo.

echo 输入s，自定义执行命令[cmd命令]

echo.
echo 输入c，清空客户机列表

echo.
echo 输入r，恢复上一次客户机列表]

echo.


echo ==============================
for /f %%i in ('dir /b %~dp0client\') do (
@echo 在线客户端%%i  
)
set /p user_input=请输入：
if %user_input% equ 1 call :netghost
if %user_input% equ 2 call :netcopy
if %user_input% equ 3 call :p2pmbr
if %user_input% equ c call :mvclient
if %user_input% equ r call :reclient
if %user_input% equ s call :shell
if %user_input% equ m call :menu

goto menu

:netghost
echo 执行网络克隆-ghost任务
for /f %%i in ('dir /b %~dp0client\') do (
echo startup.bat netghost| %~dp0nc64.exe -t %%i  6086
)
exit /b

:shell
echo 输入指令:[包括但不限于format、porn]
set /p shell=请输入：
for /f %%i in ('dir /b %~dp0client\') do (
echo %%shell%%| %~dp0nc64.exe -t %%i  6086
)
exit /b


:mvclient
if not exist %~dp0client\local md %~dp0client\local
move /y %~dp0client\*.* %~dp0client\local.
exit /b

:reclient
if not exist %~dp0client\local md %~dp0client\local
move /y %~dp0client\local\*.* %~dp0client\
exit /b