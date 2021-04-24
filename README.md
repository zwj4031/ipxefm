# ipxefm
IPXE文件管理器!支持启动WIM、ISO、IMG、RAMOS、ISCSI的网启模板(BIOS/UEFI) 
使用ipxe，自动判断legacybios和uefi(64位)环境，用不同方式启动WIM、ISO、IMG、RAMOS

ipxe.bios和ipxe.efi为tinypxe或pxelinux菜单调用专用文件(原版无嵌入脚本)

ipxeboot.pcbios和ipxeboot.efi为通用启动文件，各种网启启动器通用(群晖&openwrt等)

可以从腾讯QQ群146859089下载完整的ipxefm.7z包，里面包含演示的mini.wim

![image](https://github.com/zwj4031/ipxefm/blob/main/bin/ipxefm.gif)

应用视频https://www.bilibili.com/video/BV1Sf4y1x7ea

如果pe无法取得IP地址是因为缺少网卡驱动，可以加入你的驱动目录到app\inject\default下的   drivers.7z
或者直接把你的驱动包改名为drivers.7z