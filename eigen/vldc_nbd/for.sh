modprobe nbd
ls /dev/nbd*

read -p "ok? (y/N): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

a=0
while [ $a -ne 900 ]
do
    echo "nbd"$a
    ./busexmp /dev/nbd$a &
    sleep 0.5s
    mkfs.ext4 /dev/nbd$a
    rm -rf /mnt/nbd$a
    mkdir /mnt/nbd$a
    mount /dev/nbd$a /mnt/nbd$a
    a=`expr $a + 1`
done
