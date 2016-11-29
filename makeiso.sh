cd live-build
rm -rf iso
mkdir iso
mkdir iso/live
sudo cp -a chroot/boot iso/
rm -rf iso/live/filesystem.squashfs
sudo mksquashfs chroot iso/live/filesystem.squashfs
rm -rf ubuntu-live.iso
sudo grub-mkrescue -o ubuntu-live.iso iso
