#!/usr/bin/env bash

# Configure an external db, restart gunicorn

# simple utility, no arg checks
# The template, should be located in the same folder as this script.


site_pos=$1
site_name=$2
db_admin_user=$3
db_admin_password=$4
db_init_name=$2
db_host_name=$5


cd "$site_pos"

# however, we check if a file, of any kind, exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' does not exist"); 
    exit 1;
fi


# Move to site and write data
cd "$site_name"

# Check if config exists
if [ -e "$site_name/settings/local.py" ]; then
    (>&2 echo "A file '$site_pos/$site_name/$site_name/settings/local.py' exists"); 
    exit 1;
fi

script_dir="$(dirname "$(readlink -f "$0")")"

echo "Writing db settings..."
echo "From $script_dir/localsettings_template"
# Reconfigure the database connection
settings_text=$(< $script_dir/localsettings_template)
settings_text="${settings_text/dbAdminUser/$db_admin_user}"
settings_text="${settings_text/dbAdminPassword/$db_admin_password}"
settings_text="${settings_text/dbInitName/$db_init_name}"
settings_text="${settings_text/dbHostName/$db_host_name}"
echo "${settings_text}" > "$site_name/settings/local.py" || { (>&2 echo 'Warning: unable to write db settings into site.') ; exit 1; }
echo "written new DB settings into site at '$site_pos/$site_name/$site_name/settings/local.py'"

# Create a database
#./manage.py dbshell psql -U $db_admin_user -W $db_admin_password --command "CREATE DATABASE $site_name" &&  echo "created new db" || { (>&2 echo 'Warning: unable to create new db (or migrate).') ; exit 1; }    

# reboot server to use this configuration
#ps -e | grep gun
pkill -HUP gunicorn
