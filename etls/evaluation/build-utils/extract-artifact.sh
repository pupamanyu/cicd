# Extract Artifact deb from artifact registry, and push DAG directory to composer GCS DAG DIR

REGION=us-central1
PROJECT=${PROJECT_ID}
REPOSITORY=artifact-repo

configure_apt() {
    sudo echo "deb [ trusted=yes ] https://${REGION}-apt.pkg.dev/projects/${PROJECT} ${REPOSITORY} main" >> /etc/apt/sources.list
    sudo apt-update
}

download_package() {
    apt download game-event
}

extract_package() {
    # extract the dag from downloaded .deb
    echo "TODO: Extract dag from .deb"
}

push_dag_to_airflow() {
    # use gsutil -m cp -r .. to push the exploded dag directory to airflow dag bucket on GCS
    echo "TODO: Push dag to Airflow DAG bucket" 
}

configure_apt
download_package
extract_package
push_dag_to_airflow