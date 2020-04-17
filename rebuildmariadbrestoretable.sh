export DBDATADIR=/var/lib/mysql
export DBUSER=mysql
export DBGROUP=mysql
export DBNAME=YOURDB

echo stopping mariadb server...
systemctl stop mariadb

echo moving existing datadir...
mv ${DBDATADIR}  /var/lib/oldmysql$$

echo creating datadir and setting permission...
mkdir ${DBDATADIR}
chmod 755 ${DBDATADIR}
chown ${DBUSER}:${DBGROUP} ${DBDATADIR}

echo configuring Server ...
mysql_install_db  --user=${DBUSER}  --datadir=${DBDATADIR}

systemctl start mariadb

echo setting up a database...
mysql -uroot  <<EOF_0CRDB
show databases;
drop database if exists ${DBNAME};
create database ${DBNAME};
show databases;
EOF_0CRDB

echo importing tables from tabledump
mysql -uroot ${DBNAME} < tabledump.sql

echo create DB user and permission
mysql -uroot << EOF_2CRUSR
drop user if exists 'labuser'
create user 'labuser' identified by 'labuserpass' ;
select user,host from mysql.user;
grant SELECT,UPDATE on ${DBNAME}.`TABLENAME` to 'labuser';
EOF_2CRUSR

echo Please setup with Root password
mysql_secure_installation 

