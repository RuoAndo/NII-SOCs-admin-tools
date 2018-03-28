import random
import string
import numpy as np
import tensorflow as tf
from tensorflow.python.framework import ops
ops.reset_default_graph()

import sys 

n = 1000

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

attack_names = []
attack_types = []

counter = 0
while line:
    tmp = line.split(",")
    #print tmp[6]
    #print tmp[12]

    attack_names.append(tmp[6])
    attack_types.append(tmp[12])

    if counter > 10:
        break
                         
    counter = counter + 1
                         
    line = f.readline()

print attack_names
print attack_types

random.seed(31)
rand_zips = [random.randint(65000,65999) for i in range(5)]

def gen_typo(s, prob=0.75):
    if random.uniform(0,1) < prob:
        rand_ind = random.choice(range(len(s)))
        s_list = list(s)
        s_list[rand_ind]=random.choice(string.ascii_lowercase)
        s = ''.join(s_list)
    return(s)

numbers = [random.randint(1, 9999) for i in range(n)]
attacks = [random.choice(attack_names) for i in range(n)]
attack_suffs = [random.choice(attack_types) for i in range(n)]
zips = [random.choice(rand_zips) for i in range(n)]
full_attacks = [str(x) + ' ' + y + ' ' + z for x,y,z in zip(numbers, attacks, attack_suffs)]
reference_data = [list(x) for x in zip(full_attacks,zips)]

typo_attacks = [gen_typo(x) for x in attacks]

print typo_attacks

typo_full_attacks = [str(x) + ' ' + y + ' ' + z for x,y,z in zip(numbers, typo_attacks, attack_suffs)]
test_data = [list(x) for x in zip(typo_full_attacks,zips)]

sess = tf.Session()

test_attack = tf.sparse_placeholder( dtype=tf.string)
test_zip = tf.placeholder(shape=[None, 1], dtype=tf.float32)
ref_attack = tf.sparse_placeholder(dtype=tf.string)
ref_zip = tf.placeholder(shape=[None, n], dtype=tf.float32)

zip_dist = tf.square(tf.subtract(ref_zip, test_zip))

attack_dist = tf.edit_distance(test_attack, ref_attack, normalize=True)

zip_max = tf.gather(tf.squeeze(zip_dist), tf.argmax(zip_dist, 1))
zip_min = tf.gather(tf.squeeze(zip_dist), tf.argmin(zip_dist, 1))
zip_sim = tf.div(tf.subtract(zip_max, zip_dist), tf.subtract(zip_max, zip_min))
attack_sim = tf.subtract(1., attack_dist)

attack_weight = 0.5
zip_weight = 1. - attack_weight
weighted_sim = tf.add(tf.transpose(tf.multiply(attack_weight, attack_sim)), tf.multiply(zip_weight, zip_sim))

top_match_index = tf.argmax(weighted_sim, 1)

def sparse_from_word_vec(word_vec):
    num_words = len(word_vec)
    indices = [[xi, 0, yi] for xi,x in enumerate(word_vec) for yi,y in enumerate(x)]
    chars = list(''.join(word_vec))
    return(tf.SparseTensorValue(indices, chars, [num_words,1,1]))

reference_attackes = [x[0] for x in reference_data]
reference_zips = np.array([[x[1] for x in reference_data]])

# Create sparse attack reference set
sparse_ref_set = sparse_from_word_vec(reference_attackes)

counter = 0

for i in range(n):
    test_attack_entry = test_data[i][0]
    test_zip_entry = [[test_data[i][1]]]
    
    # Create sparse attack vectors
    test_attack_repeated = [test_attack_entry] * n
    sparse_test_set = sparse_from_word_vec(test_attack_repeated)
    
    feeddict={test_attack: sparse_test_set,
               test_zip: test_zip_entry,
               ref_attack: sparse_ref_set,
               ref_zip: reference_zips}
    best_match = sess.run(top_match_index, feed_dict=feeddict)
    best_attack = reference_attackes[best_match[0]]
    [best_zip] = reference_zips[0][best_match]
    [[test_zip_]] = test_zip_entry

    #print("####")

    if test_attack_entry != best_attack:
        print "#" + str(counter)
        print('attack: ' + str(test_attack_entry) + ', ' + str(test_zip_))
        print('match  : ' + str(best_attack) + ', ' + str(best_zip))

    counter = counter + 1
