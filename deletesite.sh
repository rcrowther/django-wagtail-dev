#!/usr/bin/env bash

# simple utility, no arg checks


site_pos=$1
site_name=$2

cd "$site_pos"


# however, we check if a directory exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' does not exist"); 
    exit 1;
fi

# running under root, unlikely to make error in any circumstance.
rm -rf "$site_name"
echo "deleted site at '$site_pos/$site_name'"
