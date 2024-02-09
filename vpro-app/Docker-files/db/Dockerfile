FROM mysql:5.7
LABEL "Project"="Vprofile"
LABEL "Owner"="Sabir"
VOLUME vprofiledata:/var/lib/mysql
ENV MYSQL_ROOT_PASSWORD=admin123
ENV MYSQL_DATABASE=accounts

COPY db_backup.sql /docker-entrypoint-initdb.d/db_backup.sql

