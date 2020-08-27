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
# push artifact.sh
#cd $(git rev-parse --show-toplevel)
EXECPATH=$(pwd)
BAZEL_WORKSPACE=${1}
cd ${BAZEL_WORKSPACE}
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
ARTIFACTBUCKET=gs://lor-data-platform-dev-gouri/staging/game-event/
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
ARTIFACTDIR="bazel-bin/etls/evaluation"
BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
COMMIT_SHA=$(git rev-parse HEAD)
ARTIFACT="game-event.deb"
RENAMED="game_event_${BRANCH_NAME}_${COMMIT_SHA}.deb"
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
# TODO: This will be a new repo for Maven Repo
ARTIFACTREPO=artifact-repo
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
REGION=us-central1
#COMPOSERENV="gs://us-central1-stage-env-a3819b6c-bucket/dags"

copy_artifact_to_gcs() {
    # Needed since Artifact Registry takes input artifacts from only GCS location at the moment
    cd  ${EXECPATH}
    mv ${ARTIFACTDIR}/${ARTIFACT} ${ARTIFACTDIR}/${RENAMED}
    echo "rename artifact complete... "
    gsutil -m cp ${ARTIFACTDIR}/${RENAMED} ${ARTIFACTBUCKET}
    echo "copy artifact to artifact registry... complete"
}

upload_deb_artifact() {
    # Upload deb artifact to artifact registry
    echo "upload deb artifact to Artifact registry ... "
    gcloud alpha artifacts packages import ${ARTIFACTREPO} --quiet \
        --location=${REGION} \
        --gcs-source=${ARTIFACTBUCKET}/${ARTIFACT} &&
        return 0
}

publish_deb_artifact() {
    # Publish .deb  artifact
    copy_artifact_to_gcs && upload_deb_artifact
}


publish_deb_artifact
