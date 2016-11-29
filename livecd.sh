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
