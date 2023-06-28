# MySQL
- Dump DB
```shell
sudo mysqldump -u [user] -p [database_name] > [filename].sql
```
- Restore DB
```shell
mysql -u [user] -p [database_name] < [filename].sql
```

# Mongo
- Dump DB
```shell
/usr/bin/mongodump --uri "mongodb://localhost:27017/db_name?directConnection=true" --out /data/db/dump
```

- Restore DB
```shell
/usr/bin/mongorestore --uri "mongodb://localhost:27017/db_name?directConnection=true" /data/db/dump
```

# Wireguard
```shell
wg-quick up wg0
wg-quick up down
```

## Install
```shell
sudo apt-get install wireguard
sudoedit /etc/wireguard/wg0.conf

Options
sudo apt install openresolv
```

# Download logs
```
scp -i ec2-keypair_filepath.pem user@server:/data/logs/2023-03-08.log ~/Downloads/
```


# Prisma
```
yarn prisma generate
yarn prisma db seed
yarn prisma format
yarn prisma migrate dev
yarn prisma migrate reset
yarn prisma migrate deploy
yarn prisma migrate dev --skip-generate
yarn prisma migrate dev --create-only
```


# Docker
```shell
docker run --name postgres --restart=always -e POSTGRES_PASSWORD=1234567890 -p 5432:5432 -d postgres
docker run --name redis --restart=always -d redis

docker exec -it internal-fe-app /bin/bash
docker exec -it nextjs-app /bin/sh

docker exec -it “container-id” bash
docker exec -it 23b4fea8cf8e bash

// Check Image OS version
Install Docker
curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall

docker run <image-name> cat /etc/*release*
docker image prune
docker tag postgres docker-reg.dipro-tech.com/postgres
```


# Nginx
```shell
sudo systemctl status nginx
sudo systemctl stop nginx
sudo systemctl start nginx
sudo systemctl reload nginx
sudo systemctl restart nginx
sudo ln -s /etc/nginx/sites-available/internal-fe.conf /etc/nginx/sites-enabled/internal-fe.conf
sudo ln -s /etc/nginx/sites-available/test.com /etc/nginx/sites-enabled/
```

# certbot
```shell
sudo certbot --nginx -d example.upcloud.com
```

# Ubuntu
## Open GIMP
```shell
flatpak run org.gimp.GIMP//stable
```

```shell
gpasswd -a www-data ubuntu
ln -s /home/ubuntu/Dropbox/Mnemosyne ~/.local/share/mnemosyne
pkill -f skype
sudo lsof -i -P -n | grep LISTEN

```


