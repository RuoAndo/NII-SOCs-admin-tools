#FILLFACTOR

FILLFACTOR: データ挿入時に、ページ内の空き領域をどの程度使うかを設定するパラメータ

デフォルト値：テーブル１００％、インデックス９０％

FILLFACTORを減らすとINSERT時に使用できる領域は少なくなるが、更新時に空き領域を有効に活用できる。
一方で、過度に小さくすると各ページでの空き領域が多くなり効率が落ちる。

bash# python fillfactor.py

<pre>
[('public', 'Fri Oct 28 18:24:54 2016', 'r', None), ('public', 'Fri Oct 28 18:50:39 2016', 'r', None), ('public', 'Fri Oct 28 19:06:41 2016', 'r', None), ('public', 'callchain', 'r', None), ('public', 'ex', 'r', None), ('public', 'test2', 'r', None), ('public', 'test2_pkey', 'i', None), ('public', 'definition', 'r', None)]
</pre>

関連項目: HOT (Heap Only Taple)

#テーブルのキャッシュヒット

heap_blks_readとheap_blks_hitによるテーブル毎のキャッシュのヒット率を計算
ある程度長い時間稼働した後に、キャッシュヒット率が低いままなら、共有バッファshared_buffersの調整やテーブルのアクセスパターンを調整する。

<pre>
bash# python table-cachehit.py bind929
('template1', Decimal('99.00'))
('template0', Decimal('99.00'))
('postgres', Decimal('99.00'))
('sample', Decimal('99.00'))
</pre>