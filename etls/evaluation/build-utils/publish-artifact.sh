# push artifact.sh
ls -lR /workspace/cicd/bazel-bin
echo gcloud alpha artifacts packages import artifact-repo --location=us-central1 --gcs-source=gs://pramodrao-dataengg-avroload/code_1.39.2-1571154070_amd64.deb
