#!/usr/bin/env bash

echo $(pwd)
cd /workspace/cicd
# upload var files for dependecies
COMPOSER_DATA_FOLDER="/home/airflow/gcs/data"
COMPOSER_NAME="dev-env"
COMPOSER_LOCATION="us-central1"
ENV_VARIABLES_JSON_FILE="etls/evaluation/game-1/game_event/workflow-dag/config/variables.json"
echo $COMPOSER_DATA_FOLDER
echo $COMPOSER_NAME
COMPOSER_GCS_BUCKET=$(gcloud composer environments describe ${COMPOSER_NAME} --location ${COMPOSER_LOCATION} | grep 'dagGcsPrefix' | grep -Eo "\S+/")

echo $COMPOSER_GCS_BUCKET

$(gsutil cp ${ENV_VARIABLES_JSON_FILE} ${COMPOSER_GCS_BUCKET}data)

$(gcloud composer environments run ${COMPOSER_NAME} \
    --location ${COMPOSER_LOCATION} variables -- \
    -i ${COMPOSER_DATA_FOLDER}/variables.json)

echo "Loaded variables into airflow"

#gcloud composer environments describe dev-env --location us-central1 | grep 'dagGcsPrefix' | grep -Eo "\S+/"
