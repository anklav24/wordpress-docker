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

timestamp=2021-12-18T010208
backup_dir_name=4soulsband_backup
logfile_name="$task_name"_restore.log
logfile_path=/tmp/$backup_dir_name/$task_name/$logfile_name

db_docker_name=4soulsband_mysql_db
combine_file_name=4soulsband

keep_log_lines=20

echo "$task_name restore has started: $timestamp" |& tee -a $logfile_path

echo "Extracting files..." |& tee -a $logfile_path
tar -xvf $backup_dir_name/$task_name/"$combine_file_name"_$timestamp.tar -C /tmp \
|& tee -a $logfile_path

# Drop DB
echo "Dropping existing tables..." |& tee -a $logfile_path
sql_query='SHOW TABLES;'
echo $sql_query | docker exec -i $db_docker_name mysql -u $mysql_user --password=$mysql_password $mysql_db_name \
|& tee -a $logfile_path
sql_query='DROP TABLE `wp_commentmeta`, `wp_comments`, `wp_links`, `wp_options`, `wp_postmeta`, `wp_posts`,`wp_termmeta`, `wp_terms`, `wp_term_relationships`, `wp_term_taxonomy`, `wp_usermeta`, `wp_users`;'
echo $sql_query | docker exec -i $db_docker_name mysql -u $mysql_user --password=$mysql_password $mysql_db_name \
|& tee -a $logfile_path

# Restore DB
echo "Restoring MySQL DB..." |& tee -a $logfile_path
mysql_dump_path=/tmp/$backup_dir_name/$task_name/$timestamp/mysql_$timestamp.sql.gz
if [ -f $mysql_dump_path ]; then
gunzip < $mysql_dump_path | docker exec -i $db_docker_name mysql -u $mysql_user --password=$mysql_password $mysql_db_name \
|& tee -a $logfile_path
else
echo "File does not exists: "$mysql_dump_path |& tee -a $logfile_path
exit 1
fi

#
#### Restore files
#sudo rm -rfv 4soulsband_wordpress/
#sudo tar -xzvf 4soulsband_wordpress_backup_2021-12-15T132100.tar.gz
#./down_up.sh  # Restart docker containers
#
## If the above does not work. Try this.
#sudo chmod 755 4soulsband_wordpress
#sudo find ./4soulsband_wordpress/ -type d -exec chmod -v 755 {} +
#sudo find ./4soulsband_wordpress/ -type f -exec chmod -v 644 {} +
#sudo chown -Rv www-data:www-data 4soulsband_wordpress
#./down_up.sh  # Restart docker containers
#
#sudo tree 4soulsband_wordpress/wp-content/ -dpugL 3  # Show directories tree
#sudo tree 4soulsband_wordpress/wp-content/ -pugL 4  # Show all files tree
#./down_up.sh  # Restart docker containers

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
echo "===DEBUG==="
echo
fi

exit