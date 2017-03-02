#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

# 入力テキストを標準入力から受け取り1行ずつ処理
for line in sys.stdin:
    # テキストをスペースで区切って単語に分割
    for word in line.strip().split():
        # 各単語を「word        1」という形式で標準出力に出力
        # タブで区切られた左が key, 右が value に相当
        print '{0}\t1'.format(word)

