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

# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
ARTIFACTBUCKET=gs://pramodrao-dataengg-avroload
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
ARTIFACTDIR=/workspace/cicd/bazel-bin/etls/evaluation
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
# TODO: This will be a JAR FILE for Maven Repo
ARTIFACT=game-event_1.0.0_amd64.deb
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
# TODO: This will be a new repo for Maven Repo
ARTIFACTREPO=artifact-repo
# TODO: Need to look at getting these variables passed down from global environment for Cloud Build
REGION=us-central1

copy_artifact_to_gcs() {
    # Needed since Artifact Registry takes input artifacts from only GCS location at the moment
    gsutil -m cp ${ARTIFACTDIR}/${ARTIFACT} ${ARTIFACTBUCKET} &&
        return 0
}

upload_jar_artifact() {
    # TODO:test mvn deploy
    mvn deploy:${ARTIFACTBUCKET}/${ARTIFACT}
}

upload_deb_artifact() {
    # Upload deb artifact to artifact registry
    gcloud alpha artifacts packages import ${ARTIFACTREPO} \
        --location=${REGION} \
        --gcs-source=${ARTIFACTBUCKET}/${ARTIFACT} &&
        return 0
}

publish_deb_artifact() {
    # Publish .deb  artifact
    copy_artifact_to_gcs && upload_deb_artifact
}

publish_jar_artifact() {
    # TODO: testing
    copy_artifact_to_gcs && upload_jar_artifact
}

publish_deb_artifact
publish_jar_artifact
