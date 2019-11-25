vmstat -n 1 | awk 'NR > 2 {print strftime("%Y/%m/%d %H:%M:%S")","$3,"," $4,","$5","$6","$7","$8","$9","$10"," $15,"," $16,"," $17}{system("")}' 
#vmstat -n 1 | awk 'NR > 2 {print strftime("%Y/%m/%d %H:%M:%S")","$3,"," $4,","$5","$6","$7","$8","$9","$10"," $15,"," $16,"," $17}{system("")}' | tee -a vmstat-h-dev02
