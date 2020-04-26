#!/usr/bin/env bash

# simple utility, no arg checks
#! unfinished, untested
site_pos=$1
site_name=$2

cd "$site_pos"

# check if a directory exists
if [ ! -d "$site_name" ]; then
    (>&2 echo "A directory '$site_pos/$site_name' does not exist"); 
    exit 1;
fi

cd '$site_name'
# project
mkdir baseDir/media

sed 's/SITENAME/$site_name/g' <django_manage.tpl >manage.py

# project app
cd '$site_name'

# organise media
mkdir static
mkdir static/css
mkdir static/js
touch static/js/'$site_name'.js
touch static/css/'$site_name'.css

# settings
mkdir settings
mv settings.py /settings/base.py
file_contents=$(</settings.py)
cd settings

== Settings
rsettings="PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))\nBASE_DIR = os.path.dirname(PROJECT_DIR)"
#echo "${file_contents// /site_name" > base.py
sed 's/PROJECT_DIR[^\n[+/$paths/g' <django_manage.tpl >manage.py

STATICFILES_FINDERS
fsettings="STATICFILES_FINDERS = [
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]

STATICFILES_DIRS = [
    os.path.join(PROJECT_DIR, 'static'),
]

STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_URL = '/static/'

MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
MEDIA_URL = '/media/'
"
echo "$fsettings" >> base,py
cd ..
# sitewide template locations
#! Should move something in that means something
mkdir templates
touch templates/404.html 
touch templates/500.html 
touch templates/base.html 
touch templates/base.html

# URLs

# new WSGI  
sed "s/SITENAME/$site_name/g" <django_wsgi.tpl >wsgi.py


echo "A need to reboot server>!"
