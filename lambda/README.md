# AWS Lambda Code Storage Management

## Problem Statement

Each AWS account is allocated **75 GB** of storage in each **region** for Lambda functions and layers. Code storage includes the total storage used by both Lambda functions and layers. If this quota is exceeded, a `CodeStorageExceededException` is raised when deploying new functions.

AWS Lambda functions and layers can accumulate numerous versions over time, leading to increased storage usage and potential management difficulties.

## Objective

Automate the deletion of older Lambda function versions, retaining only the latest **30 versions** for each function. Similarly, automate the deletion of older Lambda layer versions, retaining only the latest **20 versions** for each layer.

## Prerequisites


1. **AWS CLI**
   * Ensure the AWS CLI is installed and configured with appropriate credentials and region.
   * [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
   * [AWS CLI Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
2. **jq**
   * Install `jq` to parse JSON responses.
     * **macOS**: `brew install jq`
     * **Debian-based Linux**: `sudo apt-get install jq`

## Solution

This repository contains two shell scripts:


1. **Lambda Layers Cleanup Script**
   * Automates the deletion of older Lambda layer versions, retaining only the latest 20 versions.
2. **Lambda Functions Cleanup Script**
   * Automates the deletion of older Lambda function versions, retaining only the latest 30 versions.

### How the Scripts Work

#### Lambda Layers Cleanup Script


1. Lists all Lambda layers in a specified AWS region.
2. Iterates through each layer and lists all its versions.
3. Checks if there are more than 20 versions for the layer.
4. Deletes the oldest versions, ensuring only the latest 20 versions are retained.
5. Repeats the process for all layers.

#### Lambda Functions Cleanup Script


1. Lists all Lambda functions in a specified AWS region.
2. Iterates through each function and lists all its versions.
3. Excludes the `$LATEST` version from deletion.
4. Checks if there are more than 30 versions for the function.
5. Deletes the oldest versions, ensuring only the latest 30 versions are retained.
6. Repeats the process for all functions.

## Usage Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/waseemrabani/aws.git
cd aws/lambda
chmod +x cleanup_lambda_layers.sh 
chmod +x cleanup_lambda_functions.sh


#Run these scripts
./cleanup_lambda_layers.sh 
./cleanup_lambda_functions.sh
```


