cd /d %~dp0
@echo on
mode con cols=50 lines=2

set zip7="X:\Program Files\7-zip\7z.exe"
set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"



del /s /f pe_*.txt




%wimlib% dir mini.wim --path="\Windows\System32\DriverStore\FileRepository" >pe_drv_old.txt


dir /s /b \Windows\System32\DriverStore\FileRepository\*>>pe_drv_new_tmp.txt
for /f "tokens=1,2 delims=:" %%a in (pe_drv_new_tmp.txt) do (
echo %%b>>pe_drv_new.txt
)


bin\lsmgr sub pe_drv_new.txt pe_drv_old.txt>pe_drv.txt

mkdir %temp%\new_drv
for /f "delims=" %%i in (pe_drv.txt) do (
xcopy /s /e /y "%%i" %temp%\new_drv\.
)
%zip7% u -t7z \Windows\System32\drivers.7z %temp%\new_drv
rd /s /q %temp%\new_drv



title 添加驱动、签名到mini.wim中
set zip7="X:\Program Files\7-zip\7z.exe"
set wimlib="X:\Program Files\GhostCGI\wimlib64\wimlib-imagex.exe"

%wimlib% update mini.wim --command="add \Windows\System32\CatRoot \Windows\System32\CatRoot "
%wimlib% update mini.wim --command="add \Windows\System32\drivers.7z \Windows\System32\drivers.7z "
%wimlib% update mini.wim --command="add \Windows\System32\drivers \Windows\System32\drivers "

%wimlib% update mini.wim --command="delete \Windows\System32\Drivers.index "

%wimlib% optimize mini.wim
start "" "X:\Program Files\WinXShell.exe" -code "QuitWindow(nil,'UI_LED')"
start "" "%programfiles%\WinXShell.exe" -ui -jcfg wxsUI\UI_LED.zip -top -wait 5 -text "添加驱动完成!"
exit

