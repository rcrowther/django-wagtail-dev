#!/usr/bin/env bash

# build a site

# simple utility, no arg checks
# The template, if used, should be located in the same folder as this script.


site_pos=$1
site_name=$2
type=$3

cd "$site_pos"


# however, we do check if a file, of any kind, exists
if [ -e "$site_name" ]; then
    (>&2 echo "A file '$site_pos/$site_name' exists"); 
    exit 1;
fi


# Start new scaffold
if [[ "$type" = 'Wagtail' ]]; then
wagtail start "$site_name" || { (>&2 echo 'Error: no wagtail spotted') ; exit 1; } 
else
django-admin startproject "$site_name" || { (>&2 echo 'Error: django failed') ; exit 1; } 
fi
