cd live-build
rm -rf iso
#rm -rf iso/live
mkdir iso
mkdir iso/live
sudo cp -a chroot/boot iso/
sudo mksquashfs chroot iso/live/filesystem.squashfs
rm -rf ubuntu-live.iso
sudo grub-mkrescue -o ubuntu-live.iso iso
rm -rf /home/ubuntu/buntu-live.iso
mv ubuntu-live.iso ~/
