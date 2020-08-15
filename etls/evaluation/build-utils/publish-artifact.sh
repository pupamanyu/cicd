# push artifact.sh
find /workspace/cicd/bazel-bin/etls/evaluation -type f -ls

install_gcloud_alpha() {
    # Needed until Artifact Registry supports deb package
    gcloud components install alpha
}

copy_artifact_to_gcs() {
    # Needed since Artifact Registry takes input artifacts from only GCS location at the moment
    gsutil -m cp /workspace/cicd/bazel-bin/etls/evaluation/game-event_1.0.0_amd64.deb gs://pramodrao-dataengg-avroload/
}

upload_artifact() {
    # Upload deb artifact to artifact registry
    gcloud alpha artifacts packages import artifact-repo --location=us-central1 --gcs-source=gs://pramodrao-dataengg-avroload/code_1.39.2-1571154070_amd64.deb
}

copy_artifact_to_gcs
upload_artifact
