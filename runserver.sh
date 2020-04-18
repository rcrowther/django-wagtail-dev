#!/usr/bin/env bash

# simple utility, no arg checks


site_pos=$1
site_name=$2

cd "$site_pos"

# however, we do check if a directory exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' does not exist"); 
    exit 1;
fi

cd "$site_name"

# go
echo "Serve site '$site_name'"

#gunicorn --bind :8000 --reload "$site_name.wsgi"
gunicorn --reload --reload-engine inotify --bind :8000 "$site_name.wsgi"


