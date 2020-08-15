# Copyright 2020 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# Extract Artifact deb from artifact registry, and push DAG directory to composer GCS DAG DIR

REGION=us-central1
PROJECT=pramodrao-dataengg-workshop
REPOSITORY=artifact-repo
ARTIFACT=game-event
ARTIFACTVERSION=1.0.0
ARTIFACTARCH=amd64
AIRFLOWDAGDIR=gs://pramodrao-dataengg-avroload/dag

configure_apt() {
    pwd
    echo "deb [ trusted=yes ] https://${REGION}-apt.pkg.dev/projects/${PROJECT} ${REPOSITORY} main" >>/etc/apt/sources.list
    apt-get update
}

download_package() {
    apt-get download ${ARTIFACT}
}

extract_package() {
    # extract the dag from downloaded .deb
    echo "TODO: Extract dag from .deb"
    ar xv ${ARTIFACT}_${ARTIFACTVERSION}_${ARTIFACTARCH}.deb
    tar tj data.tar.bz2
}

deploy_dag_to_airflow() {
    # Deploy DAG to airflow 
    configure_apt \
    && download_package \
    && extract_package 
    #\
    #&& gsutil -m cp -r game_event ${AIRFLOWDAGDIR}
}

# Main
deploy_dag_to_airflow

