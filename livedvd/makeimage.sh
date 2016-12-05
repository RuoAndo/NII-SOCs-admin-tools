mkdir iso
mkdir iso/live
sudo cp -a chroot/boot iso/
sudo mksquashfs chroot iso/live/filesystem.squashfs
sudo grub-mkrescue -o ubuntu-live.iso iso
