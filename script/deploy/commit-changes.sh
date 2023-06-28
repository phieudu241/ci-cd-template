#!/bin/bash

function get_undeploy_commits() {
  # Define the Git repository directory
  repository_dir="./"

  # Change to the repository directory
  cd "$repository_dir" || exit

  last_deploy_commit_hash=$(head -n 1 "last-success-deploy-commit-hash.log")
  #  Reset
  echo "" >"last-deploy-commit-hash.log"

  # Fetch the latest changes from the remote repository
  # git fetch

  # Get the list of last 20 commit hashes
  commit_hashes=$(git log -n 20 --pretty=format:"%h")

  undeploy_commits=""

  # Iterate over each commit hash
  for hash in $commit_hashes; do
    if [ "$hash" == "$last_deploy_commit_hash" ]; then
      break
    fi

    # Get the commit message and author
    commit_message=$(git show -s --format="%s" "$hash")
    commit_author=$(git show -s --format="%an" "$hash")

    if [ "$undeploy_commits" == "" ]; then
      echo -e "$hash\n$commit_message [$commit_author]" >"last-deploy-commit-hash.log"
    fi

    undeploy_commits="$undeploy_commits\n\n$commit_message [$commit_author]"

    # Print the commit details
    #  echo "Commit: $hash"
    #  echo "Author: $commit_author"
    #  echo "Message: $commit_message"
    #  echo "------------------------------"
  done

  echo "$undeploy_commits"
}

function push_deploy_report_notification() {
  deploy_return_code=$1
  success_color="#22bb33"
  error_color="#bb2124"
  warning_color="#f0ad4e"

  deploy_result="UNKNOWN"
  color=warning_color

  undeploy_commits=$(get_undeploy_commits)
  echo -e "$undeploy_commits"

  if [ "$deploy_return_code" -eq 0 ]; then
    echo "Deploy executed successfully."
    deploy_result="SUCCESS"
    color=$success_color
    last_deploy_commit_hash=$(cat "last-deploy-commit-hash.log")
    echo -e "$last_deploy_commit_hash" >"last-success-deploy-commit-hash.log"
  else
    echo "Deploy executed failed."
    deploy_result="FAILURE"
    color=$error_color
  fi

  data="{\"text\":\"[$ENV] $SERVICE_NAME - $deploy_result\",\"attachments\":[{\"title\":\"[$ENV] $SERVICE_NAME\",\"title_link\":\"$APP_URL\",\"text\":\"$undeploy_commits\",\"color\":\"$color\"}]}"
  curl -X POST -H 'Content-Type: application/json' --data "$data" $WEB_HOOK_URL
}
