#!/bin/bash
start_time=$(date +%s)

# Exit on error
set -e

# Enable debug
set -x

#ENV="dev"
PROJECT_NAME="your_project"
epoch_time=$(date +%s)
#epoch_time="1701310221"

# Build Docker Image
docker_name="$PROJECT_NAME/$ENV-your_image_name:$epoch_time"
docker build -f ./Dockerfile . --build-arg APP_VERSION="$epoch_time" -t "$docker_name"

AWS_ID="your_AWS_ID"
AWS_PROFILE="your_profile_or_default"
AWS_REGION="ap-northeast-1"
AWS_ECR_REPOSITORY="your_project-$ENV"

ECS_CLUSTER="your_project-$ENV"
ECS_SERVICE_WEB="your_project"

# Login Elastic Container Registry - ECR
aws ecr get-login-password --region ap-northeast-1 --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

## Set tag
DOCKER_REPOSITORY_WEB=${AWS_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${AWS_ECR_REPOSITORY}
docker tag "${docker_name}" ${DOCKER_REPOSITORY_WEB}:"${epoch_time}"
docker tag "${docker_name}" $DOCKER_REPOSITORY_WEB:latest

# Docker remove image
docker image rm ${docker_name}

# Docker push
docker push ${DOCKER_REPOSITORY_WEB}:"${epoch_time}"
docker push ${DOCKER_REPOSITORY_WEB}:latest

# Deploy
curl https://raw.githubusercontent.com/silinternational/ecs-deploy/master/ecs-deploy | sudo tee /usr/bin/ecs-deploy
sudo chmod +x /usr/bin/ecs-deploy
ecs-deploy -p ${AWS_PROFILE} -r ${AWS_REGION} -c $ECS_CLUSTER -n $ECS_SERVICE_WEB --force-new-deployment -to latest -i ignore -t 180

end_time=$(date +%s)
runtime=$( echo "$end_time - $start_time" | bc -l )
echo "DEPLOYED in $runtime" seconds
exit 0
