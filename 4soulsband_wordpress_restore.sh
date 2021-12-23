#!/usr/bin/env bash

task_name=$1
mysql_db_name=$2
mysql_user=$3
mysql_password=$4
debug=$5

if [[ -z $task_name || -z $mysql_db_name || -z $mysql_user || -z $mysql_password ||  ! "$task_name" =~ ^(daily|monthly|yearly)$ ]]; then
    echo "Need args: task_name (daily, monthly, yearly), mysql_db_name, mysql_user, mysql_password, [debug (true)]"
    exit 1
fi

timestamp=2021-12-18T044715
backup_dir_name=4soulsband_backup
logfile_name="$task_name"_restore.log
logfile_path=/tmp/$backup_dir_name/$task_name/$logfile_name

db_docker_name=4soulsband_mysql_db
combine_file_name=4soulsband

keep_log_lines=300

echo "$task_name restore has started: $timestamp" |& tee -a $logfile_path

echo "Extracting files..." |& tee -a $logfile_path
tar -xvf $backup_dir_name/$task_name/"$combine_file_name"_$timestamp.tar -C /tmp \
|& tee -a $logfile_path

echo "Dropping existing tables..." |& tee -a $logfile_path
sql_query='SHOW TABLES;'
echo $sql_query | docker exec -i $db_docker_name mysql -u $mysql_user --password=$mysql_password $mysql_db_name \
|& tee -a $logfile_path
sql_query='DROP TABLE `wp_commentmeta`, `wp_comments`, `wp_links`, `wp_options`, `wp_postmeta`, `wp_posts`,`wp_termmeta`, `wp_terms`, `wp_term_relationships`, `wp_term_taxonomy`, `wp_usermeta`, `wp_users`;'
echo $sql_query | docker exec -i $db_docker_name mysql -u $mysql_user --password=$mysql_password $mysql_db_name \
|& tee -a $logfile_path

echo "Restoring MySQL DB..." |& tee -a $logfile_path
mysql_dump_path=/tmp/$backup_dir_name/$task_name/$timestamp/mysql_$timestamp.sql.gz
echo $mysql_dump_path |& tee -a $logfile_path
if [ -f $mysql_dump_path ]; then
gunzip < $mysql_dump_path | docker exec -i $db_docker_name mysql -u $mysql_user --password=$mysql_password $mysql_db_name \
|& tee -a $logfile_path
else
echo "File does not exists: "$mysql_dump_path |& tee -a $logfile_path
exit 1
fi

echo "Restoring wordpress files..." |& tee -a $logfile_path
wordpress_backup_path=/tmp/$backup_dir_name/$task_name/$timestamp/wordpress_$timestamp.tar.gz
echo $wordpress_backup_path |& tee -a $logfile_path
if [ -f $wordpress_backup_path ]; then
sudo rm -rf "$combine_file_name"_wordpress |& tee -a $logfile_path
sudo mkdir "$combine_file_name"_wordpress |& tee -a $logfile_path
sudo tar -xzf $wordpress_backup_path |& tee -a $logfile_path
else
echo "File does not exists: "$wordpress_backup_path |& tee -a $logfile_path
exit 1
fi

echo "Changing owners and file access..." |& tee -a $logfile_path
echo ./"$combine_file_name"_wordpress  |& tee -a $logfile_path
sudo chmod 755 "$combine_file_name"_wordpress
sudo find ./"$combine_file_name"_wordpress/ -type d -exec chmod -v 755 {} +
sudo find ./"$combine_file_name"_wordpress/ -type f -exec chmod -v 644 {} +
sudo chown -Rv www-data:www-data "$combine_file_name"_wordpress


echo "Restarting docker container..." |& tee -a $logfile_path
docker-compose -f 2-docker-compose.yaml down
docker-compose -f 2-docker-compose.yaml up -d

timestamp=`date +%Y-%m-%d"T"%H%M%S`
echo "Restoring was ended at: "$timestamp |& tee -a $logfile_path
echo |& tee -a $logfile_path  # A newline at the end of the file.

# Log rotate
tail -n $keep_log_lines $logfile_path > /tmp/"$logfile_name".tmp
mv -f /tmp/"$logfile_name".tmp $logfile_path

if [[ -n $debug ]]; then

echo
echo "===DEBUG==="
echo "===CAT==="
cat $logfile_path
echo

echo "===TREE==="
tree /tmp/$backup_dir_name
echo
sudo tree 4soulsband_wordpress/wp-content/ -dpugshL 3  # Show directories tree
echo "===DEBUG==="
echo
fi

exit
