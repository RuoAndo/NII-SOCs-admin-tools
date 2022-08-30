import csv
import sys
import matplotlib.pyplot as plt
import numpy as np

args = sys.argv

import csv

filename = args[1]

X = []

counter1 = 0
counter2 = 0

with open(filename, encoding='utf8', newline='') as f:
    csvreader = csv.reader(f)
    header = next(f)
    for row in csvreader:
        print(row)
        try:
            if int(row[0]) > int(row[1]):
                counter1 = counter1 + 1
            else:
                counter2 = counter2 + 1

            #print(row[3] + "," + row[7])
        except:
            pass

    print(counter1)
    print(counter2)
