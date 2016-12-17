LiveDVDの作成手順

#シェルスクリプトの実行手順

<pre>
bash# makerootfs.sh
bash" makeisoimage.sh
</pre>

# LiveDVDを作成するためのパッケージのインストール

<pre>
$ sudo apt install -y livecd-rootfs systemd-container xorriso
</pre>

#STEP2: ルートファイルシステムの作成

STEP2-1: LiveDVD作成用のワークスペースディレクトリの作成と設定

<pre>
$ mkdir live-build
$ cd live-build/
$ cp -a /usr/share/livecd-rootfs/live-build/auto .
$ cp -a /usr/share/livecd-rootfs/live-build/ubuntu-core .

$ PROJECT=ubuntu-core lb config
$ sed -i 's/precise/xenial/g' config/bootstrap
</pre>

STEP2-2: ルートファイルシステムを格納するディレクトリの作成

<pre>
$ mkdir chroot
$ sudo lb build

$sudo cp /etc/apt/sources.list chroot/etc/apt/

$ echo "ubuntu-live" | sudo tee chroot/etc/hostname
$ echo "127.0.0.1 ubuntu-live" | sudo tee chroot/etc/hosts
</pre>

STEP2-3: LiveDVDのrootパスワード設定

<pre>
$ sudo chroot chroot
bash# passwd
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
bash# exit
</pre>

#STEP3 コンテナを起動して、LiveDVDにパッケージをインストール

<pre>
$ sudo systemd-nspawn -b -D chroot
<snip>
[  OK  ] Started Update UTMP about System Runlevel Changes.

Ubuntu 16.04 LTS localhost.localdomain console

localhost login: root
Password:
Welcome to Ubuntu 16.04 LTS (GNU/Linux 4.4.0-22-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@ubuntu-live:~#
</pre>

STEP3-1：最小限のパッケージのインストール

<pre>
bash# apt update -y

bash# apt install -y live-boot live-boot-initramfs-tools

bash# apt install -y grub2-common
bash# apt install -y linux-image-$(uname -r)
</pre>

STEP3-2：必要なパッケージのインストール

<pre>
bash# apt install -y network-manager openssh-server openssh-client \
byobu emacs less lvm2 e2fsprogs net-tools

$ sudo systemctl enable ssh
</pre>

STEP3-3: LiveDVDのユーザ追加

<pre>
bash# useradd -m -s /bin/bash hiroom2
bash# gpasswd -a hiroom2 sudo
Adding user hiroom2 to group sudo
bash# passwd hiroom2
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
</pre>

STEP3-4:grub.cfgの作成

<pre>
/boot/grub/grub.cfg

set timeout=1

serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
terminal_input console serial
terminal_output console serial

menuentry 'ubuntu-live' {
  linux /boot/vmlinuz-4.4.0-45-generic boot=live console=tty1 console=ttyS0,115200
    initrd /boot/initrd.img-4.4.0-45-generic
    }
    EOF
</pre>

STEP3-4：コンテナからログオフ、電源を切る

<pre>
bash# poweroff
</pre>

#STEP4: LiveDVD isoイメージを作成

STEP4-1: iso用ディレクトリの作成

<pre>
$ mkdir iso
$ mkdir iso/live
</pre>

STEP4-2: bootディレクトリのコピー

<pre>
$ sudo cp -a chroot/boot iso/
</pre>

STEP4-3: squashfsの作成

<pre>
$sudo mksquashfs chroot iso/live/filesystem.squashfs
</pre>

STEP4-4: iso作成

<pre>
$ sudo grub-mkrescue -o ubuntu-live.iso iso
</pre>

<img src="livedvd-2016-11-20-01.png" width="70%"> <br>