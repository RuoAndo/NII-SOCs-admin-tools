time dd if=/dev/zero of=/tmp/hdparm_write.tmp ibs=1M obs=1M count=1024
for i in [1] [2] [3] [4] [5] [6] [7] [8] [9] [10] [11] [12];do sleep 10;echo $'\n\n' $i;date;time dd if=/dev/zero of=/tmp/hdparm_write$i.tmp ibs=1M obs=1M count=1024;date;done

