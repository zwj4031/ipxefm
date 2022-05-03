@echo off
mode con cols=45 lines=1
title=building......
@taskkill /f /im pxesrv.exe
@taskkill /f /im nginx.exe
pecmd kill nginx.exe
pecmd kill pxesrv.exe
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
::本目录给everyone添加权限
echo Y|cacls %~dp0. /t /p everyone:f
echo Y|cacls %~dp0*.* /t /p everyone:f
:start
(
echo [arch]
echo 00007=ipxe.efi
echo [dhcp]
echo start=1
echo proxydhcp=1
echo httpd=0
echo bind=1
echo smb=1
echo poolsize=998
echo root=%~dp0
echo filename=ipxe.bios
echo altfilename=ipxeboot.txt
)>%~dp0bin\config.INI
del /s /q %~dp0bin\~temp.*
mkdir %~dp0bin\logs
mkdir %~dp0bin\temp
start ""  %~dp0bin\pxesrv.exe
title Nginx WEB服务 运行中
:buildnginxconf
(
echo worker_processes  1;
echo events {
echo     worker_connections  1024;
echo }
echo http {
echo     include       mime.types;
echo     default_type  application/octet-stream;
echo     sendfile        on;
echo     keepalive_timeout  65;
echo     server {
echo         listen       80;
echo         server_name  localhost;
echo         location / {
echo             root  %cd%;
echo			 autoindex on;
echo             index  index.html index.htm;
echo         }
echo         error_page   500 502 503 504  /50x.html;
echo         location = /50x.html {
echo             root   html;
echo         }
echo     }
echo }
)>%~dp0bin\conf\nginx.conf
cd /d %~dp0bin
nginx.exe
exit
