#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from collections import Counter

# 単語のカウントを行う Counter オブジェクト
counter = Counter()

# Mapper の出力を標準入力から受け取り1行ずつ処理
for line in sys.stdin:
    # key(=word), value(=count) に分割する
    word, count = line.strip().split('\t')
    # カウント
    counter[word] += int(count)

# カウント結果を1単語ずつ「word count」という形式で標準出力に出力
for word, count in counter.most_common():
    print '{0}\t{1}'.format(word, count)
