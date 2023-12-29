# dnsmasq 配置说明

- 修改配置文件 /etc/dnsmasq.conf

    `nano /etc/dnsmasq.conf`

- 附加到最后一行

    ```

    enable-tftp
    tftp-root=/etc/dnsmasq.d/tftp/ipxe
    dhcp-match=set:bios,option:client-arch,0
    dhcp-match=set:ipxe,175
    dhcp-boot=tag:!ipxe,tag:bios,ipxeboot-undionly.kpxe
    dhcp-boot=tag:!ipxe,tag:!bios,ipxeboot-ipxe.efi
    dhcp-boot=tag:ipxe,boot.ipxe
    ```


- 复制*nas*下的文件到*tftp/ipxe*目录下

    `scp -r /nas/ /etc/dnsmasq.d/tftp/`
