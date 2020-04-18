#!/usr/bin/env bash

# simple utility, no arg checks


site_pos=$1
site_name=$2
admin_user=$3
admin_password=$4
admin_email=$5


cd "$site_pos"

# however, we check if a directory exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' does not exist"); 
    exit 1;
fi


# go
cd "$site_name"

# Make superuser for a new site
export DJANGO_SUPERUSER_USERNAME="$admin_user"
export DJANGO_SUPERUSER_PASSWORD="$admin_password"
export DJANGO_SUPERUSER_EMAIL="$admin_email"
./manage.py createsuperuser --noinput  &&  echo "superuser created in site" || { (>&2 echo 'Error: unable to create superuser') ; exit 1; }

