# -*- coding: utf-8 -*-

import random
#print random.random()

num = 0
while num < 250:
    print str(random.uniform(1,10)) + " " + str(random.randint(50,100)) + " " + str(random.randint(20,30))
    num += 1
    
#print random.choice('1234567890abcdefghij')
#sample_list = ['python', 'izm', 'com', 'random', 'sample']
#random.shuffle(sample_list)
#print sample_list
