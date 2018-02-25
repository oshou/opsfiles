#!/bin/bash
#

MEM_TOTAL=`cat /proc/meminfo | grep 'MemTotal' | awk '{print $2}'`
UNIT=`cat /proc/meminfo | grep 'MemTotal' | awk '{print $3}'`

PARENT_PID=`ps auxw | grep httpd | grep root | grep -v grep | awk '{print $2}'`
PARENT_MEM=`cat /proc/${PARENT_PID}/status | grep 'VmHWM' | awk '{print $2}'`

CHILD_PIDS=`ps auxw | grep httpd | grep -v root | awk '{print $2}'`
COUNT=0
CHILD_MEM_TOTAL=0
CHILD_MEM_TOTAL_NO_SHARED=0

echo -e "[apache mem usage"
echo -e "(parent process�)"
echo -e "PID\tMEM"
echo -e "${PARENT_PID}\t${PARENT_MEM}${UNIT}"
echo -e "(child process�)"
echo -e "PID\tMEM\tSHARED\tNOSHARED"

for child_pid in $CHILD_PIDS
do
    # child process mem
    CHILD_MEM=`grep 'VmHWM' /proc/${child_pid}/status | awk '{print $2}'`
    # chile process mem (shared)
    CHILD_MEM_SHARED=`cat /proc/${child_pid}/smaps | awk 'BEGIN{shared=0;}/Shared/{shared+=$2;}END{printf("%d",shared);}'`
    # child process mem (noshared)
    CHILD_MEM_NO_SHARED=`expr $CHILD_MEM - $CHILD_MEM_SHARED` 
    # child process mem total
    CHILD_MEM_TOTAL=`expr $CHILD_MEM_TOTAL + $CHILD_MEM`
    # child process mem total(noshared)
    CHILD_MEM_TOTAL_NO_SHARED=`expr $CHILD_MEM_TOTAL_NO_SHARED + $CHILD_MEM_NO_SHARED`
    # child process count
    COUNT=`expr $COUNT + 1`
    echo -e "${child_pid}\t${CHILD_MEM}${UNIT}\t${CHILD_MEM_SHARED}${UNIT}\t${CHILD_MEM_NO_SHARED}${UNIT}"
done

#平均値計算
CHILD_MEM_AVG=`expr $CHILD_MEM_TOTAL / $COUNT`
CHILD_MEM_AVG_NO_SHARED=`expr $CHILD_MEM_TOTAL_NO_SHARED / $COUNT`

MEM_TOTAL_USED=`expr $PARENT_MEM + $CHILD_MEM_TOTAL_NO_SHARED`
MAX_CLIENTS_ESTIMATE=$(((MEM_TOTAL - PARENT_MEM) / CHILD_MEM_AVG_NO_SHARED))

echo -e "HTTPD_PROCESS_COUNT\t\t\t: ${COUNT}"
echo -e "MEM_TOTAL_USED_HTTPD_CHILD\t\t: ${CHILD_MEM_TOTAL} ${UNIT}"
echo -e "MEM_AVG_USED_HTTPD_CHILD\t\t: ${CHILD_MEM_AVG} ${UNIT}"
echo -e "MEM_TOTAL_USED_HTTPD_CHILD(NOSHARED)\t: ${CHILD_MEM_TOTAL_NO_SHARED} ${UNIT}"
echo -e "MEM_AVG_USED_HTTPD_CHILD(NOSHARED)\t: ${CHILD_MEM_AVG_NO_SHARED} ${UNIT}"
echo -e "=========================================================================="
echo -e "MEM_TOTAL\t\t: ${MEM_TOTAL} ${UNIT}"
echo -e "MEM_TOTAL_HTTPD_USED\t: ${MEM_TOTAL_USED} ${UNIT}"
echo -e "NEED_MAXLIENTS\t\t: ${MAX_CLIENTS_ESTIMATE}"
