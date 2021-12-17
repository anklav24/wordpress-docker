#!/usr/bin/env bash

task_name=$1
days_to_keep=$2

if [[ -z $task_name || -z $days_to_keep ]]
then
    echo "Need args: task_name (daily, monthly, yearly), days_to_keep (7, 6, 5)"
    echo "In cron: daily 7 copies, monthly 6 copies, yearly 5 copies"
    exit 1
fi

out_file="$task_name".tar.gz
logfile_name="$task_name"_backup.log

source_dir=4soulsband_wordpress
source_db=4soulsband_mysql_db
source_config_dir=deploy_configs

backup_path=./4soulsband_backup
logfile_path=$backup_path/$logfile_name

mkdir --parents $backup_path

status="Status: "$?
echo $status >> $logfile_path

# Rotate backups
#find $backup_path/ -mtime +$days_to_keep -delete
find $backup_path/ -mtime +$days_to_keep |& tee -a $logfile_path

# Log rotate
tail -n 10 $logfile_path > /tmp/"$logfile_name".tmp
mv -f /tmp/"$logfile_name".tmp $logfile_path

# Show log
cat $logfile_path

exit