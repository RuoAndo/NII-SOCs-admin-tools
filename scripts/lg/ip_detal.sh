#!/bin/sh
LANG=C

[ -f "$1" ] || exit 1
CSV=./test.csv

cd $(dirname $0)
python lookup_ip_details.py scout.cfg ${CSV} NII -v
