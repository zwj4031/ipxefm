#!/bin/bash

# 初始化变量（默认值）
tftp_path_default="/opt/wwwroot/default/ipxefm"
bios_bootfile_default="ipxe.bios"
uefi_bootfile_default="ipxe.efi"
ipxeboot_default="ipxeboot.txt"

# 设置当前配置为默认值
tftp_path="$tftp_path_default"
bios_bootfile="$bios_bootfile_default"
uefi_bootfile="$uefi_bootfile_default"
ipxeboot="$ipxeboot_default"

# 读取配置文件路径的函数
get_dnsmasq_conf_file() {
  local conf_file=$(grep '^conf-file=' /etc/dnsmasq.conf | cut -d'=' -f2)
  if [ -z "$conf_file" ]; then
    echo "/etc/dnsmasq.conf"  # 默认路径
  else
    echo "$conf_file"
  fi
}

# 加载配置变量
load_variables() {
  local conf_file=$(get_dnsmasq_conf_file)
  if [ -f "$conf_file" ]; then
    # 提取 TFTP 根目录路径
    local tftp_path_temp=$(grep -E '^tftp-root=' "$conf_file" | cut -d'=' -f2 | tr -d ' ')
    # 提取 BIOS 启动文件
    local bios_bootfile_temp=$(grep -E 'pxe-service=tag:pxe,tag:bios' "$conf_file" | awk -F',' '{print $NF}' | tr -d ' ')
    # 提取 UEFI 启动文件
    local uefi_bootfile_temp=$(grep -E 'pxe-service=X86-64_EFI,"UEFI IPXEFM"' "$conf_file" | awk -F',' '{print $NF}' | tr -d ' ')
    # 提取 iPXE 启动文件
    local ipxeboot_temp=$(grep -E 'pxe-service=tag:ipxe,X86PC,"BIOS IPXEFM"' "$conf_file" | awk -F',' '{print $NF}' | tr -d ' ')

    # 设置提取到的值或默认显示“未配置”
    [ -n "$tftp_path_temp" ] && tftp_path="$tftp_path_temp" || tftp_path="未配置"
    [ -n "$bios_bootfile_temp" ] && bios_bootfile="$bios_bootfile_temp" || bios_bootfile="未配置"
    [ -n "$uefi_bootfile_temp" ] && uefi_bootfile="$uefi_bootfile_temp" || uefi_bootfile="未配置"
    [ -n "$ipxeboot_temp" ] && ipxeboot="$ipxeboot_temp" || ipxeboot="未配置"
  fi
}

# 更新配置文件中的某一行
update_line_in_config() {
  local conf_file=$1
  local key="$2"
  local value="$3"
  if grep -q "$key" "$conf_file"; then
    sed -i "s|^.*$key.*$|$value|g" "$conf_file"
  else
    echo "$value" >> "$conf_file"
  fi
}

# 显示菜单
show_menu() {
  # 加载当前配置
  load_variables

  echo "============================"
  echo " ipxefm 一键配置工具 for openwrt"
  echo "============================"
  echo "请选择配置环境："
  echo "1) 配置 TFTP 路径 [当前: $tftp_path]"
  echo "2) 传统 BIOS 启动文件 [当前: ${bios_bootfile//[$'\t\r\n']/  TFTP启动文件:}]"
  echo "3) UEFI 启动文件 [当前: $uefi_bootfile]"
  echo "4) iPXE 启动文件 [当前: $ipxeboot]"
  echo "5) 一键配置 (应用默认值)"
  echo "6) 清空 ipxefm 相关配置"
  echo "7) 退出"
}

# 重启 dnsmasq 服务
restart_dnsmasq() {
  /etc/init.d/dnsmasq restart
  #pandavan
  restart_dhcpd
  echo "dnsmasq 服务已重启"
}

# 配置 TFTP 路径
setup_tftp_path() {
  local conf_file=$(get_dnsmasq_conf_file)
  read -p "请输入 TFTP 路径: " tftp_path
  local tftp_config="tftp-root=$tftp_path"
  update_line_in_config "$conf_file" "tftp-root" "$tftp_config"
  echo "TFTP 路径已更新到 $conf_file"
  restart_dnsmasq
}

# 一键配置（应用默认值）
one_key_setup() {
  local conf_file=$(get_dnsmasq_conf_file)

  # 用初始化默认值进行配置
  local full_config="#ipxefm_start
# 启用 TFTP 服务
enable-tftp
# 指定 TFTP 服务器的根目录
tftp-root=$tftp_path_default

# 设置 DHCP 分配的 IP 范围 openwrt 禁用
#dhcp-range=\$start_ip,\$end_ip,\$lease_time

# 匹配所有 PXE 客户端
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
# 匹配 iPXE，可以帮助链式加载
dhcp-match=set:ipxe,175

# 设置 IPXE 启动文件
pxe-prompt=\"Press F8 for menu.\",1
pxe-service=tag:ipxe,X86PC,\"BIOS IPXEFM\",$ipxeboot_default
pxe-service=tag:oldipxe,X86PC,\"iPXE Boot\",$ipxeboot_default
# 设置 BIOS 默认启动文件
pxe-service=tag:pxe,tag:bios,X86PC,\"iPXEFM Boot\",$bios_bootfile_default
pxe-service=tag:pxe,tag:bios,X86PC,\"TFTP Boot\",bootmgr.bios
# 设置 UEFI 启动文件
pxe-service=tag:tplinkpxe,X86-64_EFI,\"Network Boot UEFI x86_64\",$ipxeboot_default
pxe-service=tag:ipxe,X86-64_EFI,\"Boot UEFI PXE-64\",$ipxeboot_default

pxe-service=X86-64_EFI,\"UEFI IPXEFM\",$uefi_bootfile_default
pxe-service=X86-64_EFI,\"snponly.efi\",snponly.efi
#ipxefm_end"

  # 直接写入默认配置
  echo "$full_config" > "$conf_file"

  echo "ipxefm 一键配置已完成"
  restart_dnsmasq
}

# 清空 ipxefm 配置
clear_ipxefm_config() {
  local conf_file=$(get_dnsmasq_conf_file)
  sed -i '/#ipxefm_start/,/#ipxefm_end/d' "$conf_file"
  echo "ipxefm 配置已清空"
  restart_dnsmasq
}

# 自定义 BIOS 启动文件
setup_bios() {
  local conf_file=$(get_dnsmasq_conf_file)
  read -p "请输入自定义 BIOS 启动文件路径: " bios_bootfile
  # 直接修改配置文件中的指定行
  local bios_config="pxe-service=tag:pxe,tag:bios,X86PC,\"iPXEFM Boot\",$bios_bootfile"
  update_line_in_config "$conf_file" "pxe-service=tag:pxe,tag:bios,X86PC,\"iPXEFM Boot\"" "$bios_config"
  echo "BIOS 启动文件已更新到 $conf_file"
  restart_dnsmasq
}


# 自定义 UEFI 启动文件
setup_uefi() {
  local conf_file=$(get_dnsmasq_conf_file)
  read -p "请输入自定义 UEFI 启动文件路径: " uefi_bootfile
  local uefi_config="pxe-service=X86-64_EFI,\"UEFI IPXEFM\",$uefi_bootfile"
  update_line_in_config "$conf_file" "X86-64_EFI,\"UEFI IPXEFM\"" "$uefi_config"
  echo "UEFI 启动文件已更新到 $conf_file"
  restart_dnsmasq
}

# 自定义 iPXE 启动文件
setup_ipxe() {
  local conf_file=$(get_dnsmasq_conf_file)
  read -p "请输入自定义 iPXE 启动文件路径: " ipxeboot
  local ipxe_config="pxe-service=tag:ipxe,X86PC,\"iPXE Boot\",$ipxeboot"
  update_line_in_config "$conf_file" "tag:ipxe,X86PC,\"iPXE Boot\"" "$ipxe_config"
  echo "iPXE 启动文件已更新到 $conf_file"
  restart_dnsmasq
}

# 主菜单循环
while true; do
  show_menu
  read -p "请输入选项: " option
  case $option in
    1) setup_tftp_path ;;
    2) setup_bios ;;
    3) setup_uefi ;;
    4) setup_ipxe ;;
    5) one_key_setup ;;
    6) clear_ipxefm_config ;;
    7) exit ;;
    *) echo "无效的选项，请重新选择。" ;;
  esac
done
one
e
