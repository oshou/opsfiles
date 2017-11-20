#!/bin/bash
#
# Apache httpd メモリ計算用スクリプト
#

MEM_TOTAL=`cat /proc/meminfo | grep 'MemTotal' | awk '{print $2}'`
UNIT=`cat /proc/meminfo | grep 'MemTotal' | awk '{print $3}'`

PARENT_PID=`ps auxw | grep httpd | grep root | grep -v grep | awk '{print $2}'`
PARENT_MEM=`cat /proc/${PARENT_PID}/status | grep 'VmHWM' | awk '{print $2}'`

CHILD_PIDS=`ps auxw | grep httpd | grep -v root | awk '{print $2}'`
COUNT=0
CHILD_MEM_TOTAL=0
CHILD_MEM_TOTAL_NO_SHARED=0

echo -e "[apacheプロセスメモリ使用量]"
echo -e "(親プロセス)"
echo -e "PID\tMEM"
echo -e "${PARENT_PID}\t${PARENT_MEM}${UNIT}"
echo -e "(子プロセス)"
echo -e "PID\tMEM\tSHARED\tNOSHARED"

for child_pid in $CHILD_PIDS
do
    #メモリ使用量
    CHILD_MEM=`grep 'VmHWM' /proc/${child_pid}/status | awk '{print $2}'`
    #共用メモリ
    CHILD_MEM_SHARED=`cat /proc/${child_pid}/smaps | awk 'BEGIN{shared=0;}/Shared/{shared+=$2;}END{printf("%d",shared);}'`
    #プライベートメモリ使用量
    CHILD_MEM_NO_SHARED=`expr $CHILD_MEM - $CHILD_MEM_SHARED` 
    #メモリ合計
    CHILD_MEM_TOTAL=`expr $CHILD_MEM_TOTAL + $CHILD_MEM`
    CHILD_MEM_TOTAL_NO_SHARED=`expr $CHILD_MEM_TOTAL_NO_SHARED + $CHILD_MEM_NO_SHARED`
    
    #カウントアップ
    COUNT=`expr $COUNT + 1`
    echo -e "${child_pid}\t${CHILD_MEM}${UNIT}\t${CHILD_MEM_SHARED}${UNIT}\t${CHILD_MEM_NO_SHARED}${UNIT}"
done

#平均値計算
CHILD_MEM_AVG=`expr $CHILD_MEM_TOTAL / $COUNT`
CHILD_MEM_AVG_NO_SHARED=`expr $CHILD_MEM_TOTAL_NO_SHARED / $COUNT`

MEM_TOTAL_USED=`expr $PARENT_MEM + $CHILD_MEM_TOTAL_NO_SHARED`
MAX_CLIENTS_ESTIMATE=$(((MEM_TOTAL - PARENT_MEM) / CHILD_MEM_AVG_NO_SHARED))

echo -e "子プロセス数 \t\t\t\t: ${COUNT}"
echo -e "子プロセスメモリ使用量合計 \t\t: ${CHILD_MEM_TOTAL} ${UNIT}"
echo -e "子プロセスメモリ使用量平均 \t\t: ${CHILD_MEM_AVG} ${UNIT}"
echo -e "子プロセスメモリ使用量合計(共有除く) \t: ${CHILD_MEM_TOTAL_NO_SHARED} ${UNIT}"
echo -e "子プロセスメモリ使用量平均(共有除く) \t: ${CHILD_MEM_AVG_NO_SHARED} ${UNIT}"
echo -e "=========================================================================="
echo -e "総メモリ量 \t\t: ${MEM_TOTAL} ${UNIT}"
echo -e "httpd 総メモリ使用量 \t: ${MEM_TOTAL_USED} ${UNIT}"
echo -e "MaxClient目安 \t: ${MAX_CLIENTS_ESTIMATE}"
