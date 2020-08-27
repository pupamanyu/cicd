#!/bin/bash
#
# This script sets the environment variables for project environment specific
# information such as project_id, region and zone choice. And also name of
# buckets that are used by the build pipeline and the data processing workflow.
#
# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export TEST='test'
export STAGING_GCP_PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export STAGING_PROJECT_NUMBER=$(gcloud projects describe "${STAGING_GCP_PROJECT_ID}" --format='get(projectNumber)')
export JAR_BUCKET_TEST="${STAGING_GCP_PROJECT_ID}-composer-source-${TEST}"
export INPUT_BUCKET_TEST="${STAGING_GCP_PROJECT_ID}-composer-input-${TEST}"
export RESULT_BUCKET_TEST="${STAGING_GCP_PROJECT_ID}-composer-result-${TEST}"
export REF_BUCKET_TEST="${STAGING_GCP_PROJECT_ID}-composer-ref-${TEST}"
export STAGING_BUCKET_TEST="${STAGING_GCP_PROJECT_ID}-staging-${TEST}"

# Export prod settings

#export PROD='prod'
#export PROD_GCP_PROJECT_ID=$(gcloud config list --format 'value(core.project)')
#export PROD_PROJECT_NUMBER=$(gcloud projects describe "${PROD_GCP_PROJECT_ID}" --format='get(projectNumber)')
#export JAR_BUCKET_PROD="${PROD_GCP_PROJECT_ID}-composer-source-${PROD}"
#export INPUT_BUCKET_PROD="${PROD_GCP_PROJECT_ID}-composer-input-${PROD}"
#export RESULT_BUCKET_PROD="${PROD_GCP_PROJECT_ID}-composer-result-${PROD}"
#export STAGING_BUCKET_PROD="${PROD_GCP_PROJECT_ID}-staging-${PROD}"


# Set stage composer variables
export STAGING_COMPOSER_ENV_NAME='staging-data-pipeline-composer3'
export COMPOSER_REGION='us-central1'
export RESULT_BUCKET_REGION="${COMPOSER_REGION}"
export COMPOSER_ZONE_ID='us-central1-a'
export STAGING_COMPOSER_DAG_BUCKET=$(gcloud composer environments describe $STAGING_COMPOSER_ENV_NAME \
                              --location $COMPOSER_REGION \
                              --format="get(config.dagGcsPrefix)")
export STAGING_COMPOSER_SERVICE_ACCOUNT=$(gcloud composer environments describe $STAGING_COMPOSER_ENV_NAME \
                                  --location $COMPOSER_REGION \
                                  --format="get(config.nodeConfig.serviceAccount)")
export REPO_NAME='cicd'
export COMPOSER_DAG_NAME_TEST='test_lor_game_event'
#export COMPOSER_DAG_NAME_PROD='prod_lor_game_event'
