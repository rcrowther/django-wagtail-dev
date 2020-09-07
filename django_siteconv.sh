#!/usr/bin/env bash

# simple utility, no arg checks
# Convert Django scaffold into something more website/deplayable friendly
#! unfinished, untested
site_pos=$1
site_name=$2

script_dir="$(dirname "$(readlink -f "$0")")"

cd "$site_pos"

# check if a directory exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' does not exist"); 
    exit 1;
fi

# To project...
cd '$site_name'

# Make a /media directory
mkdir baseDir/media

# Set manage settings to the sub-directory settings, not top level
#rm manage.py
sed 's/SITENAME/$site_name/g' <$script_dir/site_files/manage.tpl >manage.py

# To project app...
cd '$site_name'

# new WSGI  
#rm wsgi.py
sed "s/SITENAME/$site_name/g" <$script_dir/site_files/wsgi.tpl >wsgi.py

# create sidewide /static and populate
mkdir static
mkdir static/css
mkdir static/js
touch static/js/$site_name.js
touch static/css/$site_name.css

# create sitewide templates
#NB cant sed to same file
cp -r $script_dir/site_files/templates templates
sed 's/SITENAME/$site_name/g' <script_dir/site_files/templates/base.py >templates/base.py

# create staged /settings
#NB cant sed to same file
#rm settings.py
cp -r $script_dir/site_files/settings settings
sed 's/SITENAME/$site_name/g' <$script_dir/site_files/settings/base.py >settings/base.py

# URLs
#rm urls.py
sed 's/SITENAME/$site_name/g' <$script_dir/site_files/urls.tpl >urls.py


# done
echo "A need to reboot server>!"
