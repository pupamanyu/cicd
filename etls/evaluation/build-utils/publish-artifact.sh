# push artifact.sh
find cicd/bazel-bin/etls/evaluation -type f -ls
echo gcloud alpha artifacts packages import artifact-repo --location=us-central1 --gcs-source=gs://pramodrao-dataengg-avroload/code_1.39.2-1571154070_amd64.deb
