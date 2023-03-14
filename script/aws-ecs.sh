#!/bin/bash

set -e

AWS_ID="4961136XXXX"
AWS_ECR_FOLDER_NAME="XXX-YYYY-container-assets-496113624764-ap-northeast-1"
AWS_PROFILE="$1"
TASK_FAMILY="YourProjectStackBackendTaskDefinition20B215F8"

ECS_CLUSTER_NAME="YourProjectStack-EcsCluster97242B84-RMvQKRK3LIh0"
ECS_CLUSTER_SERVICE_NAME="YourProjectStack-LoadBalancedEcsServiceB6FF0D3F-FSrGmNMBcbYM"


# Login docker
aws ecr get-login-password --region ap-northeast-1 --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

epochTime=`date +%s`

docker_name="YourProject_${epochTime}"

# Docker build
docker build --platform=linux/amd64 -t ${docker_name} $(for i in `cat .env`; do out+="--build-arg $i " ; done; echo $out;out="") .

# Set tag
docker tag ${docker_name} ${AWS_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${AWS_ECR_FOLDER_NAME}:${docker_name}

# Docker push
docker push ${AWS_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${AWS_ECR_FOLDER_NAME}:${docker_name}

# Docker remove image
docker image rmi ${docker_name}

NEW_IMAGE="${AWS_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${AWS_ECR_FOLDER_NAME}:${docker_name}"
# Register a new task definition
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "${TASK_FAMILY}" --region "ap-northeast-1" --profile ${AWS_PROFILE} )
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --args ".taskDefinition" | jq --args "del(.taskDefinitionArn)" | jq --args "del(.revision)" | jq --args "del(.status)" | jq --args "del(.requiresAttributes)" | jq --args "del(.registeredAt)" | jq --args "del(.registeredBy)" | jq --args "del(.compatibilities)" | jq --args "(.containerDefinitions[].image)=\"${NEW_IMAGE}\"")

aws ecs register-task-definition --region "ap-northeast-1" --cli-input-json "${NEW_TASK_DEFINITION}" --profile ${AWS_PROFILE}

# Update to the cluster
aws ecs update-service --cluster $ECS_CLUSTER_NAME --region "ap-northeast-1" --service $ECS_CLUSTER_SERVICE_NAME --task-definition $TASK_FAMILY --profile ${AWS_PROFILE}


echo "DEPLOYED !!!!"

