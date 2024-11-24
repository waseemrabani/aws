#!/bin/bash

# Set the AWS region
REGION="us-east-1"
function_arns=$(aws lambda list-functions --region $REGION --query 'Functions[*].FunctionArn' --output text)

for arn in $function_arns; do
  echo "Processing function: $arn"
  
  while true; do

    versions=$(aws lambda list-versions-by-function --function-name $arn --region $REGION --query 'Versions[*].Version' --output text)

    IFS=' ' read -r -a version_array <<< "$versions"

    version_array=(${version_array[@]/\$LATEST})

    # Check if there are more than 30 versions
    if [ ${#version_array[@]} -le 30 ]; then
      echo "Function $arn has 30 or fewer versions, no further deletion needed."
      break
    fi

    # Sort the versions and keep only the latest 30
    sorted_versions=($(echo "${version_array[@]}" | tr ' ' '\n' | sort -n))
    versions_to_delete=(${sorted_versions[@]:0:${#sorted_versions[@]}-30})

    for version in "${versions_to_delete[@]}"; do
      echo "Deleting version $version of function $arn"
      aws lambda delete-function --function-name $arn --qualifier $version --region $REGION
    done
  done
done
