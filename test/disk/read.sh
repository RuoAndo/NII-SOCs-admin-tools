rm -t /dev/sda1
 for i in [1] [2] [3] [4] [5] [6] [7] [8] [9] [10] [11] [12];do sleep 10;echo $'\n\n' $i;hdparm -t /dev/sda2;done

