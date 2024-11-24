#!/bin/bash

set -e

# Set the region
AWS_REGION="us-east-1"

# Function to clean up old versions of a specific Lambda layer
cleanup_layer_versions() {
    local layer_name=$1
    echo "Processing layer: $layer_name"
    versions=()
    next_marker=""

    while : ; do
        if [ -z "$next_marker" ]; then
            response=$(aws lambda list-layer-versions --layer-name "$layer_name" --region $AWS_REGION --output json)
        else
            response=$(aws lambda list-layer-versions --layer-name "$layer_name" --region $AWS_REGION --output json --starting-token "$next_marker")
        fi

     
        new_versions=$(echo $response | jq -c '.LayerVersions[] | .Version')
        for version in $new_versions; do
            versions+=($version)
        done

     
        next_marker=$(echo $response | jq -r '.NextMarker // empty')
  
        if [ -z "$next_marker" ]; then
            break
        fi
    done


    echo "Number of versions retrieved: ${#versions[@]}"
    # Skip if there are 20 or fewer versions
    if [ ${#versions[@]} -le 20 ]; then
        echo "Layer $layer_name has ${#versions[@]} versions, no cleanup needed."
        return
    fi

    sorted_versions=($(printf '%s\n' "${versions[@]}" | sort -nr))
  
    to_delete=("${sorted_versions[@]:20}")


    echo "Versions to delete: ${to_delete[@]}"

    for version in "${to_delete[@]}"; do
        echo "Attempting to delete layer $layer_name version $version"
        delete_output=$(aws lambda delete-layer-version --layer-name "$layer_name" --version-number "$version" --region $AWS_REGION 2>&1)
        if [ $? -eq 0 ]; then
            echo "Successfully deleted layer $layer_name version $version"
        else
            echo "Failed to delete layer $layer_name version $version: $delete_output"
        fi
    done
}

# Function to clean up all Lambda layers
cleanup_all_layers() {
    next_marker=""
    layers=()

    while : ; do
        if [ -z "$next_marker" ]; then
            response=$(aws lambda list-layers --region $AWS_REGION --output json)
        else
            response=$(aws lambda list-layers --region $AWS_REGION --output json --starting-token "$next_marker")
        fi

        new_layers=$(echo $response | jq -r '.Layers[] | .LayerName')

        for layer in $new_layers; do
            layers+=("$layer")
        done

     
        next_marker=$(echo $response | jq -r '.NextMarker // empty')

        if [ -z "$next_marker" ]; then
            break
        fi
    done

    for layer in "${layers[@]}"; do
        cleanup_layer_versions "$layer"
    done
}

cleanup_all_layers

echo "Cleanup of all layers completed."
