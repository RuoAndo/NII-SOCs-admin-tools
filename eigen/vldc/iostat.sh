#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument"
fi

iostat 1 -x -t /dev/$1 awk '
  BEGIN {
    print "time %user %nice %system %iowait %steal %idle Device rrqm/s wrqm/s r/s w/s rsec/s wsec/s avgrq-sz avgqu-sz await svctm %util "
  }
  NF==2{
    # 2行目に実行される
    # 現在時刻を取ってくる
    s = strftime("%H:%M:%S");
    # 3行目を読む
    getline;
    # 4行目を読む
    getline;
    # フィールドの再構築(スペースを1個にまとめる)
    $1=$1;
    # avp-cpuの値をとってくる
    l=s " " $0 
  }
  /Device:/{
    # Device:が現れた行に実行される
    # Device:の次の行を読む
    getline; 
    # フィールドの再構築(スペースを1個にまとめる)
    $1=$1;
    # avp-cpuの値の後ろにデバイスの値をくっつける
    l=l " " $0;
    #l=$0;
    #print l;
    fflush(); 
  }'
