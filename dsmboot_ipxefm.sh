#!/usr/bin/env bash

DNSMASQ_CONF="/etc/dnsmasq.conf"
SYSTEMD_SERVICE="/var/packages/DhcpServer/conf/systemd/pkg-dhcpserver.service"

# 读取现有配置
read_dnsmasq_conf() {
    if [ -f "$DNSMASQ_CONF" ]; then
        tftp_directory=$(grep -Po '(?<=^tftp-root=).*' $DNSMASQ_CONF)
        ip_range=$(grep -Po '(?<=^dhcp-range=).*' $DNSMASQ_CONF | awk -F, '{print $1"-"$2}')
        lease_time=$(grep -Po '(?<=^dhcp-range=).*' $DNSMASQ_CONF | awk -F, '{print $3}')
        bios_boot_file=$(grep -Po '(?<=^pxe-service=x86PC,"PXE Boot",).*' $DNSMASQ_CONF)
        uefi_boot_file=$(grep -Po '(?<=^dhcp-boot=tag:efi-x86_64,).*' $DNSMASQ_CONF)
        ipxe_boot_file=$(grep -Po '(?<=^dhcp-boot=tag:ipxe,).*' $DNSMASQ_CONF)
        proxy_mode=$(grep -q 'dhcp-range=.*proxy' $DNSMASQ_CONF && echo true || echo false)

        echo "现有配置："
        echo "TFTP 目录: $tftp_directory"
        echo "IP 范围: $ip_range"
        echo "租约时间: $lease_time"
        echo "传统 BIOS 启动文件名: $bios_boot_file"
        echo "UEFI 启动文件名: $uefi_boot_file"
        echo "iPXE 启动文件: $ipxe_boot_file"
        echo "DHCP 代理模式: $proxy_mode"
		echo "支持UEFI安全启动 [当前:$secure_boot_status]"
    else
        tftp_directory="$(pwd)"
        ip_address=$(/sbin/ifconfig | grep -v 127 | grep 'inet ' | sed 's/^.*inet addr://g' | sed 's/ *Bcast.*$//g')
        ip_last_octet=$(echo $ip_address | awk -F. '{print $4}')
        start_ip=$(echo $ip_address | awk -F. -v last_octet=$((ip_last_octet + 1)) '{print $1"."$2"."$3"."last_octet}')
        end_ip=$(echo $start_ip | awk -F. '{print $1"."$2"."$3"."$4+100}')
        lease_time="12h"
        proxy_mode=false
        bios_boot_file="ipxe.bios"
        uefi_boot_file="ipxe.efi"
        ipxe_boot_file="http://$ip_address/ipxeboot.txt"
        generate_dnsmasq_conf
    fi
}

# 显示菜单
ip_address=$(/sbin/ifconfig | grep -v 127 | grep 'inet ' | sed 's/^.*inet addr://g' | sed 's/ *Bcast.*$//g')
    echo "当前网卡 IP 地址: $ip_address"
	
show_menu() {
    
    echo "IPXEFM网启一键配置工具"
	echo "首次使用说明:群晖系统需要安装DHCP套件并启动，TFTP目录权限设置为为755"
	echo "系统直接提供DHCP服务的，先执行6再执行7，否则还要执行3"
	echo "需自启的请添加计划任务开机执行/usr/bin/ipxefm.sh"
    echo "请选择功能："
    echo "1) 设置 TFTP 目录 [当前: $tftp_directory]"
    echo "2) 获取当前网卡 IP 地址并选择 IP 范围 [当前: $ip_range, 租约时间: $lease_time]"
    echo "3) 设置是否使用 DHCP 代理 [当前: $proxy_mode]"
    echo "4) 设置传统 BIOS 和 UEFI 环境下的启动文件名 [当前: BIOS: $bios_boot_file, UEFI: $uefi_boot_file, iPXE: $ipxe_boot_file]"
    echo "5) 配置 iPXE 客户端环境下的启动文件名 [当前: $ipxe_boot_file]"
    echo "6) 一键生成默认配置文件"
    echo "7) 重启 dnsmasq 服务"
    echo "8) 配置 dnsmasq 服务自启动"
	echo "9) 删除 dnsmasq 服务自启动"
	echo "0) 查看 dnsmasq 日志"
	echo "s) 支持UEFI安全启动 [当前:$secure_boot_status]"
    echo "x) 退出"

}    

# 设置 TFTP 目录
set_tftp_directory() {
    read -p "请输入 TFTP 目录 (默认当前目录): " new_tftp_directory
    tftp_directory=${new_tftp_directory:-$(pwd)}
    sudo sed -i "s|^tftp-root=.*|tftp-root=$tftp_directory|" $DNSMASQ_CONF
    echo "TFTP 目录设置为 $tftp_directory"
}

set_ip_range() {
    ip_address=$(/sbin/ifconfig | grep -v 127 | grep 'inet ' | sed 's/^.*inet addr://g' | sed 's/ *Bcast.*$//g')
    echo "当前网卡 IP 地址: $ip_address"
    
    ip_last_octet=$(echo $ip_address | awk -F. '{print $4}')
    start_ip_default=$(echo $ip_address | awk -F. -v last_octet=$((ip_last_octet + 1)) '{print $1"."$2"."$3"."last_octet}')
    
    # 验证 IP 地址的每个部分
    validate_ip_part() {
        if [ $1 -gt 254 ]; then
            echo "IP地址部分 $1 超过 254，已调整为 254"
            echo 254
        elif [ $1 -lt 0 ]; then
            echo "IP地址部分 $1 为负数，已调整为 0"
            echo 0
        else
            echo $1
        fi
    }
    
    read -p "请输入起始 IP 地址 (默认 $start_ip_default): " start_ip
    start_ip=${start_ip:-$start_ip_default}
    ip_parts=($(echo $start_ip | tr '.' ' '))
    start_ip=$(echo "$(validate_ip_part ${ip_parts[0]}).$(validate_ip_part ${ip_parts[1]}).$(validate_ip_part ${ip_parts[2]}).$(validate_ip_part ${ip_parts[3]})")

    end_ip_default=$(echo $start_ip | awk -F. '{print $1"."$2"."$3"."$4+100}')
    read -p "请输入结束 IP 地址 (默认 $end_ip_default): " end_ip
    end_ip=${end_ip:-$end_ip_default}
    ip_parts=($(echo $end_ip | tr '.' ' '))
    end_ip=$(echo "$(validate_ip_part ${ip_parts[0]}).$(validate_ip_part ${ip_parts[1]}).$(validate_ip_part ${ip_parts[2]}).$(validate_ip_part ${ip_parts[3]})")
    
    read -p "请输入租约时间 (默认 12h): " lease_time
    lease_time=${lease_time:-12h}
    
    sudo sed -i "s|^dhcp-range=.*|dhcp-range=$start_ip,$end_ip,$lease_time|" $DNSMASQ_CONF
    ip_range="$start_ip-$end_ip"
    echo "IP 范围设置为 $start_ip - $end_ip，租约时间为 $lease_time"
}


# 设置 DHCP 代理
set_dhcp_proxy() {
    read -p "是否使用 DHCP 代理 (yes/no, 默认 yes): " dhcp_proxy
    dhcp_proxy=${dhcp_proxy:-yes}
    if [ "$dhcp_proxy" == "yes" ]; then
        proxy_mode=true
        sudo sed -i "s|^dhcp-range=.*|dhcp-range=$ip_address,proxy|" $DNSMASQ_CONF
        echo "启用 DHCP 代理"
		
    else
        proxy_mode=false
        sudo sed -i "s|^dhcp-range=.*|dhcp-range=$start_ip,$end_ip,$lease_time|" $DNSMASQ_CONF
        echo "禁用 DHCP 代理"
    fi
}

# 设置启动文件名
set_boot_file() {
    default_bios_boot_file="ipxe.bios"
    default_uefi_boot_file="ipxe.efi"
    default_ipxe_boot_file="http://$ip_address/ipxeboot.txt"
    read -p "请输入传统 BIOS 下的启动文件名 (默认 $default_bios_boot_file): " bios_boot_file
    bios_boot_file=${bios_boot_file:-$default_bios_boot_file}
    read -p "请输入 UEFI 下的启动文件名 (默认 $default_uefi_boot_file): " uefi_boot_file
    uefi_boot_file=${uefi_boot_file:-$default_uefi_boot_file}
    read -p "请输入 iPXE 启动文件 (默认 $default_ipxe_boot_file): " ipxe_boot_file
    ipxe_boot_file=${ipxe_boot_file:-$default_ipxe_boot_file}

    sudo sed -i "s|^pxe-service=x86PC,\"PXE Boot\",.*|pxe-service=x86PC,\"PXE Boot\",$bios_boot_file|" $DNSMASQ_CONF
    sudo sed -i "s|^dhcp-boot=tag:efi-x86_64,.*|dhcp-boot=tag:efi-x86_64,$uefi_boot_file|" $DNSMASQ_CONF
    sudo sed -i "s|^dhcp-boot=tag:ipxe,.*|dhcp-boot=tag:ipxe,$ipxe_boot_file|" $DNSMASQ_CONF
    
    echo "传统 BIOS 启动文件名设置为 $bios_boot_file"
    echo "UEFI 启动文件名设置为 $uefi_boot_file"
    echo "iPXE 启动文件设置为 $ipxe_boot_file"
}

# 配置 iPXE 客户端环境下的启动文件名
set_ipxe_boot_file() {
    default_ipxe_boot_file="http://$ip_address/ipxeboot.txt"
    read -p "请输入 iPXE 启动文件 (默认 $default_ipxe_boot_file): " new_ipxe_boot_file
    ipxe_boot_file=${new_ipxe_boot_file:-$default_ipxe_boot_file}
    sudo sed -i "s|^dhcp-boot=tag:ipxe,.*|dhcp-boot=tag:ipxe,$ipxe_boot_file|" $DNSMASQ_CONF
	sudo sed -i "s|^dhcp-boot=tag:oldipxe,.*|dhcp-boot=tag:oldipxe,$ipxe_boot_file|" $DNSMASQ_CONF
    echo "iPXE 启动文件设置为 $ipxe_boot_file"
}

# 生成 dnsmasq 配置文件并显示配置
generate_dnsmasq_conf() {
  sudo cat <<EOF > /etc/dnsmasq.conf
# 启用 TFTP 服务
enable-tftp
# 指定 TFTP 服务器的根目录
tftp-root=$tftp_directory

# 设置 DHCP 分配的 IP 范围
dhcp-range=$start_ip,$end_ip,$lease_time

# 匹配所有PXE客户端
dhcp-match=set:pxe,60,PXEClient
dhcp-match=set:tplink-pxe,60,TP-LINK
# 根据客户端架构设置标签
dhcp-match=set:bios,option:client-arch,0
dhcp-match=set:efi-x86,option:client-arch,6
dhcp-match=set:efi-x86_64,option:client-arch,7
dhcp-match=set:efi-x86_64,option:client-arch,9
dhcp-match=set:efi-arm32,option:client-arch,10
dhcp-match=set:efi-arm64,option:client-arch,11
dhcp-vendorclass=BIOS,PXEClient:Arch:00000
dhcp-vendorclass=UEFI32,PXEClient:Arch:00006
dhcp-vendorclass=UEFI,PXEClient:Arch:00007
dhcp-vendorclass=UEFI64,PXEClient:Arch:00009
# 识别旧版 iPXE 客户端
dhcp-match=set:oldipxe,77 # 旧版 iPXE 客户端检测
# 匹配iPXE，可以帮助链式加载
dhcp-match=set:ipxe,175

# 设置 IPXE 启动文件
pxe-prompt="Press F8 for menu.",1
pxe-service=tag:ipxe,X86PC,"BIOS IPXEFM",$ipxe_boot_file
pxe-service=tag:oldipxe,X86PC,"iPXE Boot",$ipxe_boot_file
# 设置 BIOS 默认启动文件
pxe-service=tag:pxe,tag:bios,X86PC,"iPXEFM Boot",$bios_boot_file
pxe-service=tag:pxe,tag:bios,X86PC,"TFTP Boot",bootmgr.bios
# 设置 UEFI 启动文件
pxe-service=tag:tplinkpxe,X86-64_EFI,"Network Boot UEFI x86_64",$ipxe_boot_file
pxe-service=tag:ipxe,X86-64_EFI,"Boot UEFI PXE-64",$ipxe_boot_file

pxe-service=X86-64_EFI, "UEFI IPXEFM",$uefi_boot_file
pxe-service=X86-64_EFI, "snponly.efi",snponly.efi

EOF

    # 如果启用了 DHCP 代理模式，添加相关配置
    if [ "$proxy_mode" == true ]; then
	  sleep 2
      sudo sed -i "s|^dhcp-range=.*|dhcp-range=$ip_address,proxy|" $DNSMASQ_CONF
    fi

    echo "📝dnsmasq 配置文件已生成：$DNSMASQ_CONF"
    echo "📋配置详情："
    echo "📂TFTP 目录: $tftp_directory"
    echo "🌐IP 范围: $start_ip - $end_ip"
    echo "⏳租约时间: $lease_time"
    echo "🔧传统 BIOS 启动文件名: $bios_boot_file"
    echo "🔧UEFI 启动文件名: $uefi_boot_file"
    echo "🔧iPXE 启动文件: $ipxe_boot_file"
}

# 一键生成默认配置文件并显示配置
one_key_generate() {
    tftp_directory=$(pwd)
    ip_address=$(/sbin/ifconfig | grep -v 127 | grep 'inet ' | sed 's/^.*inet addr://g' | sed 's/ *Bcast.*$//g')
    ip_last_octet=$(echo $ip_address | awk -F. '{print $4}')
    start_ip=$(echo $ip_address | awk -F. -v last_octet=$((ip_last_octet + 1)) '{print $1"."$2"."$3"."last_octet}')
    end_ip=$(echo $start_ip | awk -F. '{print $1"."$2"."$3"."$4+100}')
    lease_time="12h"
    proxy_mode=false
    bios_boot_file="ipxe.bios"
    uefi_boot_file="ipxe.efi"
    ipxe_boot_file="http://$ip_address/ipxeboot.txt"

    generate_dnsmasq_conf
}

# 重启 dnsmasq 服务
restart_dnsmasq() {
    # 停用原 DHCP 和 TFTP 服务
	
    sudo systemctl stop pkgctl-DhcpServer.service
    sudo systemctl stop tftp.service
	# 目标目录
TARGET_DIR="/var/lib/misc"
	# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "目录不存在，正在创建..."
    sudo mkdir -p "$TARGET_DIR"
    echo "目录已创建：$TARGET_DIR"
else
    echo "目录已存在：$TARGET_DIR"
fi


    dnsmasq_pid=$(ps xa | grep dnsmasq | grep -v grep | awk '{print $1}')
    dnsmasq_path=$(grep -Po '(?<=^ExecStart=).*?(?= --user)' $SYSTEMD_SERVICE | awk '{print $1}')

    if [ ! -z "$dnsmasq_pid" ]; then
        echo "找到 dnsmasq 进程 (PID: $dnsmasq_pid)，正在重启..."
        sudo kill -9 $dnsmasq_pid
		echo $dnsmasq_path --conf-file=$DNSMASQ_CONF
		sleep 2
        sudo $dnsmasq_path --conf-file=$DNSMASQ_CONF
        echo "dnsmasq 已重启并指向新的配置文件"
		sudo cat $DNSMASQ_CONF
    else
	    cho $dnsmasq_path --conf-file=$DNSMASQ_CONF
        echo "未找到运行中的 dnsmasq 进程"
		sleep 2
		echo "启动进程..."
        sudo $dnsmasq_path --conf-file=$DNSMASQ_CONF
		sudo cat $DNSMASQ_CONF
		sleep 1
    fi
}

# 配置 dnsmasq 服务自启动
setup_autostart() {
    # 创建 /usr/bin/ipxefm.sh 脚本
    sudo tee /usr/bin/ipxefm.sh > /dev/null <<EOF
/bin/systemctl stop pkgctl-DhcpServer.service # 停用原 DHCP 服务
/bin/systemctl stop tftp.service # 停用原 TFTP 服务
echo "启动iPXE网启服务"
sleep 5
$(grep -Po '(?<=^ExecStart=).*?(?= --user)' $SYSTEMD_SERVICE | awk '{print $1}') -C $DNSMASQ_CONF
EOF
    sudo chmod +x /usr/bin/ipxefm.sh

    # 配置 dnsmasq 服务
    if [ ! -f "$SYSTEMD_SERVICE" ]; then
        sudo tee $SYSTEMD_SERVICE > /dev/null <<EOF
[Unit]
Description=dnsmasq - A lightweight DHCP and caching DNS server
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/ipxefm.sh
ExecReload=/bin/kill -HUP \$MAINPID
PIDFile=/var/run/dnsmasq/dnsmasq.pid

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl enable dnsmasq
        echo "dnsmasq 服务已配置为自启动"
		echo "如果不能自启，请在任务计划里手工添加/usr/bin/ipxefm.sh开机脚本"
    else
        echo "dnsmasq 服务已经配置为自启动"
    fi
}

# 删除 dnsmasq 服务自启动配置
remove_autostart() {
    if [ -f "$SYSTEMD_SERVICE" ]; then
        sudo systemctl disable dnsmasq
        sudo rm $SYSTEMD_SERVICE
        echo "已删除 dnsmasq 服务的自启动配置"
    else
        echo "dnsmasq 服务的自启动配置不存在"
    fi
}






#!/bin/bash

# 定义函数
modify_dnsmasq_conf() {
    local conf_file="/etc/dnsmasq.conf"
    
    # 检查文件是否包含"Secure Boot"
    if grep -q "Secure Boot" "$conf_file"; then
        # 如果包含"Secure Boot"，删除包含它的整行
        sed -i '/Secure Boot/d' "$conf_file"
        secure_boot_status="不支持安全启动"
    else
        secure_boot_status="支持安全启动"
        # 搜索包含"UEFI IPXEFM"的行，并在其上方添加指定内容
        sed -i '/UEFI IPXEFM/i pxe-service=X86-64_EFI, "Secure Boot",bootmgr.efi' "$conf_file"
    fi


}

#!/bin/bash

# 定义函数
check_dnsmasq_conf() {
    local conf_file="/etc/dnsmasq.conf"
    local secure_boot_status

    # 检查文件是否包含"Secure Boot"
    if grep -q "Secure Boot" "$conf_file"; then
        secure_boot_status="不支持安全启动"
    else
        secure_boot_status="支持安全启动"
    fi

    # 输出变量值
    echo "Secure Boot Status: $secure_boot_status"
}






# 主循环
while true; do
    show_menu
	
    read -p "请选择一个选项: " choice
    case $choice in
        1)
            set_tftp_directory
			restart_dnsmasq
            ;;
        2)
            set_ip_range
			restart_dnsmasq
            ;;
        3)
            set_dhcp_proxy
			restart_dnsmasq
            ;;
        4)
            set_boot_file
			restart_dnsmasq
            ;;
        5)
            set_ipxe_boot_file
			restart_dnsmasq
            ;;
 
        6)
            read -p "使用默认值一键生成 dnsmasq 配置文件 (y/n, 默认 y): " default_conf
            default_conf=${default_conf:-y}
            if [ "$default_conf" == "y" ]; then
                one_key_generate
                echo "默认配置文件已生成"
				restart_dnsmasq
            fi
            ;;
        7)
            restart_dnsmasq
            ;;
        8)
		    setup_autostart
                echo "任务已添加"
			sleep 2
            ;;
	    8)
		    remove_autostart
                echo "任务已添加"
			sleep 2
            ;;
	    0)
            sudo tail -f /var/log/dnsmasq.log
            ;;
		s)
            modify_dnsmasq_conf
			restart_dnsmasq
			# 调用函数并将状态赋值给变量
			 ;;	
        x)
            echo "退出"
            exit 0
            ;;
        *)
            echo "无效选项，请重试"
            ;;
    esac
done
