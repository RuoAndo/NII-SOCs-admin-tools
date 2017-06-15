rm -rf tmp-avg
rm -rf tmp-cls-0
rm -rf tmp-cls-1
rm -rf tmp-cls-2
rm -rf tmp-cls-3
rm -rf tmp-cls-4

pig -x local -param SRCS=$1 label.pig


