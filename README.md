# ipxefm
IPXE文件管理器!支持启动WIM、ISO、IMG、RAMOS、ISCSI的网启模板(BIOS/UEFI) 
使用ipxe，自动判断legacybios和uefi(64位)环境，用不同方式启动WIM、ISO、IMG、RAMOS

ipxe.bios和ipxe.efi为tinypxe或pxelinux菜单调用专用文件(原版无嵌入脚本)

ipxeboot.pcbios和ipxeboot.efi为通用启动文件，各种网启启动器通用(群晖&openwrt等)
