#!/usr/bin/env bash

# migrate

# simple utility, no arg checks
# The template, if used, should be located in the same folder as this script.


site_pos=$1
site_name=$2


cd "$site_pos"


# however, we do check if a file, of any kind, exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' not exists"); 
    exit 1;
fi


cd "$site_name"


# Install new data framework
./manage.py migrate --noinput &&  echo "new site migrated to DB" || { (>&2 echo "Error: unable to migrate site into database '$site_name'") ; exit 1; }

