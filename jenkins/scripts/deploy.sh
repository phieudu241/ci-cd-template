#!/usr/bin/env sh

echo "Deploy app - tag $TAG"

SSH_KEY_FILE=./server_ssh_key.pem
PROJECT_ENV_FILE=./.env

#Enable debugging mode
set -x
# Remove old ssh key file
rm -f $SSH_KEY_FILE
# Cat ssh key from Jenkins Credentials to ssh key file
cat $SERVER_SSH_KEY_FILE > $SSH_KEY_FILE
chmod 400 $SSH_KEY_FILE

# Cat env content from Jenkins Credentials to .env file
cat $ENV_FILE > $PROJECT_ENV_FILE

#Upload
scp -i $SSH_KEY_FILE .next.zip $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/.next.zip
scp -i $SSH_KEY_FILE public.zip $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/public.zip
scp -i $SSH_KEY_FILE prisma.zip $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/prisma.zip
scp -i $SSH_KEY_FILE package.json $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/package.json
scp -i $SSH_KEY_FILE yarn.lock $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/yarn.lock
scp -i $SSH_KEY_FILE next.config.js $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/next.config.js
scp -i $SSH_KEY_FILE $PROJECT_ENV_FILE $SERVER_USERNAME@$SERVER_URL://home/$SERVER_USERNAME/your_project/.env

#Deploy
ssh -i $SSH_KEY_FILE $SERVER_USERNAME@$SERVER_URL "
  set -e
  cd your_project
  yarn install
  rm -R .next
  unzip .next.zip
  rm -R public
  unzip public.zip
  rm -R prisma
  unzip prisma.zip
  npx prisma generate
  npx prisma migrate deploy
  pm2 restart $SERVICE_NAME --update-env --log-date-format 'YYYY-MM-DD HH:mm:ss.SSS'
"

OUT=$?
#Disable debugging mode
set +x

if [ $OUT -eq 0 ]
then
  echo 'Deploy: Successful'
  exit 0
else
  echo 'Deploy: Failed'
  exit 1
fi
