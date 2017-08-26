#!/bin/bash

BACKUP_DST="/var/backup/files"
BACKUP_SRC="
root
etc
home
opt
usr
var
";

# create backup directory
[ ! -d ${BACKUP_DST} ] && mkdir -p ${BACKUP_DST};

# create archive(gzip)
cd /;
tar -czf ${BACKUP_DST}/daily_backup_`hostname`_`date +%Y%m%d`.files.tar.gz ${BACKUP_SRC} 1> /dev/null;

find ${BACKUP_SRC} -type f -mtime +3 -exec rm -f {} \;;
