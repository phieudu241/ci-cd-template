#!/bin/bash

source ./commit-changes.sh

# Exit on error
set -e

# Enable debug
set -x

#Build
rm -rf dist
yarn prisma generate
yarn build
rm -f dist.zip
zip -r dist.zip dist

rm -f prisma.zip
zip -r prisma.zip prisma

#Upload
scp -i $PEM_FILE dist.zip ubuntu@$SERVER://home/ubuntu/project-api/dist.zip
scp -i $PEM_FILE prisma.zip ubuntu@$SERVER://home/ubuntu/project-api/prisma.zip
scp -i $PEM_FILE package.json ubuntu@$SERVER://home/ubuntu/project-api/package.json
scp -i $PEM_FILE yarn.lock ubuntu@$SERVER://home/ubuntu/project-api/yarn.lock
scp -i $PEM_FILE .env ubuntu@$SERVER://home/ubuntu/project-api/.env

#Deploy
ssh -i $PEM_FILE ubuntu@$SERVER '
  cd project-api
  export PATH="$PATH:/home/ubuntu/.nvm/versions/node/v18.16.0/bin"
  pm2 stop project-api
  yarn install
  rm -R dist
  unzip dist.zip
  rm -R prisma
  unzip prisma.zip
  yarn prisma generate
  yarn prisma migrate deploy
  pm2 restart project-api
'

deploy_return_code=$?
echo "deploy_return_code: $deploy_return_code"

# Push notification
push_deploy_report_notification $deploy_return_code
