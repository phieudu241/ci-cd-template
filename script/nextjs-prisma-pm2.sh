#!/bin/bash
start_time=`date +%s`

# Exit on error
set -e

# Enable debug
set -x

#Build
rm -rf .next
yarn install
yarn prisma generate
yarn build
rm -f .next.zip
zip -r .next.zip .next
rm -f public.zip
zip -r public.zip public

rm -f prisma.zip
zip -r prisma.zip prisma

#Upload
scp -i $PEM_FILE .next.zip $SERVER_USER@$SERVER_HOST://home/$SERVER_USER/$REMOTE_SERVER_PROJECT_DIR/.next.zip
scp -i $PEM_FILE public.zip $SERVER_USER@$SERVER_HOST://home/$SERVER_USER/$REMOTE_SERVER_PROJECT_DIR/public.zip
scp -i $PEM_FILE prisma.zip $SERVER_USER@$SERVER_HOST://home/$SERVER_USER/$REMOTE_SERVER_PROJECT_DIR/prisma.zip
scp -i $PEM_FILE package.json $SERVER_USER@$SERVER_HOST://home/$SERVER_USER/$REMOTE_SERVER_PROJECT_DIR/package.json
scp -i $PEM_FILE yarn.lock $SERVER_USER@$SERVER_HOST://home/$SERVER_USER/$REMOTE_SERVER_PROJECT_DIR/yarn.lock
scp -i $PEM_FILE next.config.js $SERVER_USER@$SERVER_HOST://home/$SERVER_USER/$REMOTE_SERVER_PROJECT_DIR/next.config.js

#Deploy
ssh -i $PEM_FILE $SERVER_USER@$SERVER_HOST '
  set -e
  cd $REMOTE_SERVER_PROJECT_DIR
  pm2 stop $SERVICE
  npm install
  rm -R .next
  unzip .next.zip
  rm -R public
  unzip public.zip
  rm -R prisma
  unzip prisma.zip
  npx prisma generate
  npx prisma migrate deploy
  pm2 restart $SERVICE --update-env --time --log-date-format "YYYY-MM-DD HH:mm:ss.SSS"
'

end_time=`date +%s`
runtime=$( echo "$end_time - $start_time" | bc -l )
echo $runtime seconds
