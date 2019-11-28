#coding:utf-8
# K-means

import numpy as np
import sys
import matplotlib.pyplot as plt

argvs = sys.argv

if __name__ == "__main__":
    data = np.genfromtxt(argvs[1])
    print data

    args = sys.argv
    test_data = open(args[1], "r")
    prices = []
    
    line_counter = 0
    for line in test_data:
        
        if line_counter == 0:
            line_counter = line_counter + 1
            continue
        
        tmp_item = line.split(",")
        print tmp_item[1]
        prices.append(float(tmp_item[1]))
        
    print prices
      
    test_data.close()
    
    plt.plot(prices)
    plt.show()  
        
    #filename = argvs[1] + ".png"
    #plt.savefig(filename)

