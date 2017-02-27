# -*- coding: utf-8


import mmh3
MIN_HASH_VALUE = 2 ** 128

def min_hash(words, seed):
    min_hash_word = None
    min_hash_value = MIN_HASH_VALUE

    for word in words:
        hash_ = mmh3.hash128(word, seed)
        if hash_ < min_hash_value:
            min_hash_word = word
            min_hash_value = hash_

    return min_hash_word


def calc_score(s1, s2, k):

    num_match = 0

    for seed in xrange(k):
        if min_hash(s1, seed) == min_hash(s2, seed):
            num_match += 1

    return float(num_match) / k


def main():
    s1 = ['a', 'b']
    s2 = ['a']
    s3 = ['b']

    s4 = [chr(ascii) for ascii in xrange(97, 123)]

    k = 2 ** 10

    print calc_score(s1, s4, k)
    print calc_score(s2, s4, k)
    print calc_score(s3, s4, k)


if __name__ == '__main__':
    main()

