#!/usr/bin/env sh

echo "Deploy Tokiwagi app - tag $TAG"

DOCKER_COMPOSE_FILE_NAME=docker-compose.yml
SERVER_DOCKER_COMPOSE_DIR=$SERVER_PROJECT_DIR/docker
SSH_KEY_FILE=./server_ssh_key.pem
PROJECT_ENV_FILE_NAME=.env.$TAG

DOCKER_REGISTRY_URL=https://docker-reg.dipro-tech.com

#Enable debugging mode
set -x
chmod 400 $SSH_KEY_FILE

#Upload docker compose file to server
scp -i $SSH_KEY_FILE ./$DOCKER_COMPOSE_FILE_NAME $SERVER_USERNAME@$SERVER_URL:$SERVER_DOCKER_COMPOSE_DIR/
#Upload project env file to server
scp -i $SSH_KEY_FILE ./$PROJECT_ENV_FILE_NAME $SERVER_USERNAME@$SERVER_URL:$SERVER_PROJECT_DIR/

# Rename $PROJECT_ENV_FILE_NAME[.env.test|.env.production] to .env file
ssh -i $SSH_KEY_FILE $SERVER_USERNAME@$SERVER_URL "
  cd $SERVER_PROJECT_DIR
  mv $PROJECT_ENV_FILE_NAME .env
"

#Pull docker images from docker registry and run
ssh -i $SSH_KEY_FILE $SERVER_USERNAME@$SERVER_URL "
  cd $SERVER_DOCKER_COMPOSE_DIR
  echo -e \"TAG=$TAG\" > .env
  docker login -u $DOCKER_REGISTRY_USERNAME -p $DOCKER_REGISTRY_PW $DOCKER_REGISTRY_URL
  docker-compose -f $DOCKER_COMPOSE_FILE_NAME pull
  docker-compose -f $DOCKER_COMPOSE_FILE_NAME up -d
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
