wget http://vault.centos.org/7.2.1511/updates/Source/SPackages/kernel-3.10.0-327.4.5.el7.src.rpm
rpm -ihv kernel-3.10.0-327.4.5.el7.src.rpm
cd ~/rpmbuild/SOURCES
tar Jxvf linux-3.10.0-327.4.5.el7.tar.xz -C /usr/src/kernels/
cd /usr/src/kernels/
mv $(uname -r) $(uname -r)-old
mv linux-3.10.0-327.4.5.el7 $(uname -r)
cd $(uname -r)
make mrproper
cp ../$(uname -r)-old/Module.symvers ./
cp /boot/config-$(uname -r) ./.config
make oldconfig
make prepare
make scripts
make CONFIG_BLK_DEV_NBD=m M=drivers/block
cp drivers/block/nbd.ko /lib/modules/$(uname -r)/kernel/drivers/block/
depmod -a

