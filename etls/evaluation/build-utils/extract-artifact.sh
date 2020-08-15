# Extract Artifact deb from artifact registry, and push DAG directory to composer GCS DAG DIR

REGION=us-central1
PROJECT=${PROJECT_ID}
REPOSITORY=artifact-repo

configure_apt() {
    pwd
    echo ${PATH}
    id
    updatedb
    apt-cache search sudo
    locate sudo
    which sudo
    cat /etc/apt/sources.list
    cat /etc/sudoers
    uname -a
    /sbin/sudo echo "deb [ trusted=yes ] https://${REGION}-apt.pkg.dev/projects/${PROJECT} ${REPOSITORY} main" >> /etc/apt/sources.list
    /sbin/sudo apt-update
}

download_package() {
    pwd
    apt-get download game-event
    ls -l
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