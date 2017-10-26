modprobe nbd
a=0
while [ $a -ne 1100 ]
do
    echo "nbd"$a
    ./busexmp /dev/nbd$a &
    mkfs.ext4 /dev/nbd$a
    rm -rf /mnt/nbd$a
    mkdir /mnt/nbd$a
    mount /dev/nbd$a /mnt/nbd$a
    a=`expr $a + 1`
done
