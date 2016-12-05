git filter-branch --tree-filter "rm -f [消したいファイルパス]" HEAD
git filter-branch --tree-filter "rm -f -r [消したいディレクトリパス] " HEAD
git gc --aggressive --prune=now
