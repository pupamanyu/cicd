# push artifact.sh
find /workspace/cicd/bazel-bin/etls/evaluation -type f -ls

ARTIFACTBUCKET=gs://pramodrao-dataengg-avroload
ARTIFACTDIR=/workspace/cicd/bazel-bin/etls/evaluation
ARTIFACT=game-event_1.0.0_amd64.deb
ARTIFACTREPO=artifact-repo
REGION=us-central1

copy_artifact_to_gcs() {
    # Needed since Artifact Registry takes input artifacts from only GCS location at the moment
    gsutil -m cp ${ARTIFACTDIR}/${ARTIFACT} ${ARTIFACTBUCKET} \
    && return 0
}

upload_artifact() {
    # Upload deb artifact to artifact registry
    gcloud alpha artifacts packages import ${ARTIFACTREPO} \
    --location=${REGION} \
    --gcs-source=${ARTIFACTBUCKET}/${ARTIFACT} \
    && return 0
}

publish_artifact() {
    copy_artifact_to_gcs && upload_artifact
}

publish_artifact