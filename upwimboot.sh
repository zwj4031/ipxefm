#!/usr/bin/env sh
cd ~/git/ipxefm/
wget https://github.com/ipxe/wimboot/releases/latest/download/wimboot -O app/wimboot/wimboot
cp -r ~/git/ipxefm/* /mnt/s/ipxefm/
cp -r ~/git/ipxefm/* /mnt/m/ipxefm/