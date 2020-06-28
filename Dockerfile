# docker build . -t dw:2.8

FROM python:3.8 as production
ENV PYTHONUNBUFFERED 1

# NB: base runs apt-get update

RUN mkdir -p /srv

# Install Python DB communication package
RUN pip install psycopg2
# Install Python server communication package
RUN pip install gunicorn
# Wagtail bundle installs all necessary dependences. 
# OS dependences like zlib already in the base image
RUN pip install wagtail
RUN pip install wagtailmenus
#RUN pip install elasticsearch-py

EXPOSE 8000/tcp
#VOLUME /srv


FROM production as dev
# Install postgres-client so 'manage.py dbshell' works with external Postgres
RUN apt-get update; apt-get install -y --no-install-recommends postgresql-client-11; apt-get install sqlite3
RUN pip install inotify
RUN pip install django-silk
RUN pip install coverage
# pip install django-extensions
# Add create and run scripts, and dependencies to support them.
RUN mkdir -p /script/wagtail
WORKDIR /etc/profile.d
# Edge cases, untested. This is supposed to work...
COPY scripts_path.sh .
# Set path in Docker's eternal present.
ENV PATH "$PATH:/script/wagtail"
WORKDIR /script/wagtail
COPY createscaffold .
COPY createscaffoldw .
COPY createscaffold.sh .
COPY createsite .
COPY createsitew .
COPY migratesite.sh .
COPY createsuperuser.sh .
COPY runserver.sh .
COPY runserver .
COPY listsites .
COPY deletesite .
COPY deletesite.sh .
COPY configuredb .
COPY configuredb.sh .
COPY localsettings_template .
COPY configuredbsu .
WORKDIR /srv
CMD ["bash"]
