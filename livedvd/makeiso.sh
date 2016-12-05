sudo apt install -y livecd-rootfs systemd-container xorriso
mkdir live-build
cd live-build/
cp -a /usr/share/livecd-rootfs/live-build/auto .
cp -a /usr/share/livecd-rootfs/live-build/ubuntu-core .
PROJECT=ubuntu-core lb config
sed -i 's/precise/xenial/g' config/bootstrap
mkdir chroot
sudo lb build
sudo cp /etc/apt/sources.list chroot/etc/apt/
echo "ubuntu-live" | sudo tee chroot/etc/hostname
echo "127.0.0.1 ubuntu-live" | sudo tee chroot/etc/hosts
sudo chroot chroot
sudo systemd-nspawn -b -D chroot

#cd live-build
#rm -rf iso
#mkdir iso
#mkdir iso/live
#sudo cp -a chroot/boot iso/
#rm -rf iso/live/filesystem.squashfs
#sudo mksquashfs chroot iso/live/filesystem.squashfs
#rm -rf ubuntu-live.iso
#sudo grub-mkrescue -o ubuntu-live.iso iso
