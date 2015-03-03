{% set nn_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh4.hadoop.namenode', 'grains.items', 'compound').values()[0]['fqdn'] %}
#!/bin/bash -e

# configure mysql
/usr/bin/mysql_secure_installation <<EOF

n
y
y
y
y
EOF

HIVE_VERSION=`rpm -qa | grep hive-server2 | cut -d - -f 3 | cut -d . -f 2`

# create the metastore database
SETUPSQL="/tmp/hive_setup.sql"
cat >$SETUPSQL <<EOF
CREATE DATABASE metastore;
USE metastore;
SOURCE {{pillar.cdh4.hive.home}}/scripts/metastore/upgrade/mysql/hive-schema-0.$HIVE_VERSION.0.mysql.sql;
CREATE USER '{{pillar.cdh4.hive.user}}'@'localhost' IDENTIFIED BY '{{pillar.cdh4.hive.metastore_password}}';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '{{pillar.cdh4.hive.user}}'@'localhost';
GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO '{{pillar.cdh4.hive.user}}'@'localhost';
FLUSH PRIVILEGES;
EOF

mysql -u root < $SETUPSQL

# cleanup
rm -f $SETUPSQL

