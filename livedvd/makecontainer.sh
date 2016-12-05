apt-get update
apt-get install -y ubuntu-desktop
apt install -y live-boot live-boot-initramfs-tools
apt install -y grub2-common
apt install -y linux-image-$(uname -r)
apt install -y network-manager openssh-server openssh-client byobu emacs less lvm2 e2fsprogs net-tools
#apt install -y  gnome-shell-extensions gnome ubuntu-desktop xinit
apt-get install -y xfce4 xfce4-goodies

sudo systemctl enable ssh
