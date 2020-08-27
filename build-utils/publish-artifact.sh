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
# publish-artifact.sh

EXECPATH=$(pwd)
BAZEL_WORKSPACE=${1}
echo $(pwd)
cd ${BAZEL_WORKSPACE}
echo $(pwd)
ARTIFACTBUCKET=${2}
ARTIFACTDIR=${3}
BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
COMMIT_SHA=$(git rev-parse HEAD)
ARTIFACT="game-event.deb"
RENAMED="game_event_${BRANCH_NAME}_${COMMIT_SHA}.deb"
ARTIFACTREPO=${4}
REGION=${5}

copy_artifact_to_gcs() {
#    cd  ${EXECPATH}
    echo ${ARTIFACTDIR}

    mv ${ARTIFACTDIR}/${ARTIFACT} ${ARTIFACTDIR}/${RENAMED}
    echo "renamed... "
    gsutil -m cp ${ARTIFACTDIR}/${RENAMED} ${ARTIFACTBUCKET}
    echo "upload to gcs ... "
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
