#!/usr/bin/env bash

echo $(pwd)
# upload var files for dependecies
COMPOSER_DATA_FOLDER="/home/airflow/gcs/data"
COMPOSER_NAME="data-pipeline-composer"
COMPOSER_LOCATION="us-central1"
ENV_VARIABLES_JSON_FILE="bigquery_pipeline/config/variables.json"
echo $COMPOSER_DATA_FOLDER
echo $COMPOSER_NAME
COMPOSER_GCS_BUCKET=$(gcloud composer environments describe ${COMPOSER_NAME} --location ${COMPOSER_LOCATION} | grep 'dagGcsPrefix' | grep -Eo "\S+/")

echo $COMPOSER_GCS_BUCKET

$(gsutil cp ${ENV_VARIABLES_JSON_FILE} ${COMPOSER_GCS_BUCKET}data)

$(gcloud composer environments run ${COMPOSER_NAME} \
    --location ${COMPOSER_LOCATION} variables -- \
    -i ${COMPOSER_DATA_FOLDER}/variables.json)

echo "Loaded variables into airflow"