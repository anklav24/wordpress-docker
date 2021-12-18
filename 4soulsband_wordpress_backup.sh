#!/usr/bin/env bash

task_name=$1
days_to_keep=$2
mysql_db_name=$3
mysql_user=$4
mysql_password=$5
debug=$6

db_docker_name=4soulsband_mysql_db
wp_source_dir=4soulsband_wordpress
config_source_dir=deploy_configs
backup_dir_name=./4soulsband_backup
combine_file_name=4soulsband

keep_log_lines=300

if [[ -z $task_name || -z $days_to_keep || -z $mysql_db_name || -z $mysql_user || -z $mysql_password ||  ! "$task_name" =~ ^(daily|monthly|yearly)$ ]]; then
    echo "Need args: task_name (daily, monthly, yearly), days_to_keep (7, 186, 1825), mysql_db_name, mysql_user, mysql_password, [debug (true)]"
    echo "In cron: daily 7 copies, monthly 6 copies, yearly 5 copies"
    exit 1
fi

timestamp=`date +%Y-%m-%d"T"%H%M%S`
logfile_name="$task_name"_backup.log
backup_task_path=$backup_dir_name/$task_name
logfile_path="$backup_task_path/$logfile_name"
backup_path_timestamp=$backup_dir_name/$task_name/$timestamp

if [[ -n $debug ]]; then
echo "===DEBUG==="
echo '$task_name: '$task_name
echo '$days_to_keep: '$days_to_keep
echo '$logfile_name: '$logfile_name
echo '$logfile_path: '$logfile_path
echo '$backup_dir_name: '$backup_dir_name
echo '$backup_task_path: '$backup_task_path
echo '$backup_path_timestamp: '$backup_path_timestamp
echo "===DEBUG==="
echo
fi

mkdir --parents $backup_path_timestamp

echo "$task_name backup has started: $timestamp" |& tee -a $logfile_path
# Wordpress DB backup
echo "MySQL..." |& tee -a $logfile_path
docker exec $db_docker_name mysqldump --no-tablespaces -u $mysql_user --password=$mysql_password $mysql_db_name \
| gzip -9 > "$backup_path_timestamp/mysql_$timestamp.sql.gz" \
|& tee -a $logfile_path

# Wordpress files backup
echo "Wordpress..." |& tee -a $logfile_path
tar -czf "$backup_path_timestamp/wordpress_$timestamp.tar.gz" $wp_source_dir \
|& tee -a "$logfile_path"

# Env and settings files backup
echo "Settings..." |& tee -a $logfile_path
tar -czf "$backup_path_timestamp/config_$timestamp.tar.gz" $config_source_dir .env README_secret.md\
|& tee -a "$logfile_path"

# Combine files
echo "Combine it into one file..." |& tee -a $logfile_path
tar -cf "$backup_task_path"/"$combine_file_name"_"$timestamp.tar" \
"$backup_path_timestamp/mysql_$timestamp.sql.gz" \
"$backup_path_timestamp/wordpress_$timestamp.tar.gz" \
"$backup_path_timestamp/config_$timestamp.tar.gz"
rm -rf $backup_path_timestamp

# Log rotate
tail -n $keep_log_lines $logfile_path > /tmp/"$logfile_name".tmp
mv -f /tmp/"$logfile_name".tmp $logfile_path

# Rotate backups
echo "Delete files older than $days_to_keep (Day/Days)" |& tee -a $logfile_path
find $backup_task_path/* ! -path $logfile_path -mtime +$days_to_keep |& tee -a $logfile_path
find $backup_task_path/* ! -path $logfile_path -mtime +$days_to_keep -delete |& tee -a $logfile_path
echo "Deletion completed" |& tee -a $logfile_path

timestamp=`date +%Y-%m-%d"T"%H%M%S`
echo "Backup was ended at: "$timestamp |& tee -a $logfile_path
echo |& tee -a $logfile_path  # A newline at the end of the file.

if [[ -n $debug ]]; then

echo "===DEBUG==="
echo "===CAT==="
cat $logfile_path
echo

echo "===TREE==="
tree ./4soulsband_backup -pugsh
echo "===DEBUG==="
echo
fi

exit
