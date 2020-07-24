date=$(date -d '2 day ago' "+%Y%m%d")

rm -rf /mnt/nvme15/${date}
rm -rf /mnt/nvme16/${date}
rm -rf /mnt/nvme17/${date}
rm -rf /mnt/nvme1/${date}

echo "copying..."
start_time=`date +%s`
cp -r ${date} /mnt/nvme15 &
cp -r ${date} /mnt/nvme16 &
cp -r ${date} /mnt/nvme17 &
cp -r ${date} /mnt/nvme1 &
wait
end_time=`date +%s`
time=$((end_time - start_time))
echo "copy time:"$time




