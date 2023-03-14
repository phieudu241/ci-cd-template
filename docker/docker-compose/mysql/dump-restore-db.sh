Docker
- Creating database dumps
docker exec some-mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql

- Restoring data from dump files
$ docker exec -i some-mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < /some/path/on/your/host/all-databases.sql


- Creating database dumps
mysqldump -h rds.host.name -u remote_user_name -p remote_db > dump.sql
- Restoring data from dump files
mysql -u local_user_name -p local_db < dump.sql

Examples:
mysqldump -h adima-database-test.casdjvpmfv1y.ap-southeast-1.rds.amazonaws.com -u root -p adima_test > /var/data/adima_test_dump.sql
mysql -u root -p adima < adima_test_dump.sql
