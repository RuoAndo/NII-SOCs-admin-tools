rm -rf avg-$1                                                                                                           
while read line; do                    
    cat $line >> avg-$1                                                                                                  
done < partlist  
