from datetime import datetime

import matplotlib.pyplot as plt
import matplotlib.dates as md
import dateutil

import random

import sys
args = sys.argv

x = []
y = []

f = open(args[1], 'r')

line = f.readline()
line = f.readline()

while line:
    tmp = line.split(",")
    print(str(tmp[0] + "," + str(random.randint(5, 200))))
    
    line = f.readline()
          
f.close()

