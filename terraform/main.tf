# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



provider "google" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

provider "google-beta" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

# Enable APIs; Must be individual resources or else it will disable all other APIs for the project.
resource "google_project_service" "billingapi" {
  service = "cloudbilling.googleapis.com"
}

resource "google_project_service" "composerapi" {
  service = "composer.googleapis.com"
}

# Grant custom role to service account
resource "google_project_iam_binding" "custom_role_binding" {
  members = ["serviceAccount:${google_service_account.cicd}"]
  role    = "projects/${var.project_id}/roles/${google_project_iam_custom_role.cicd_iam_role.role_id}"
}

# Grant Cloud Composer Role to service account
resource "google_project_iam_binding" "composer_binding" {
  members = ["serviceAccount:${google_service_account.cicd_service_account.email}"]
  role    = "roles/composer.worker"
}


# Create bucket for Composer temporary file store
resource "google_storage_bucket" "dataflow_jar_bucket"{
  name     = "DATAFLOW_JAR_BUCKET_TEST"
  location = "${var.COMPOSER_REGION}"
}
resource "google_storage_bucket" "input_bucket" {
  name     = "INPUT_BUCKET_TEST"
  location = "${var.COMPOSER_REGION}"
}
resource "google_storage_bucket" "ref_bucket"{
  name     = "${REF_BUCKET_TEST}
  location = "${var.COMPOSER_REGION}"
}
resource "google_storage_bucket" "result_bucket"{
  name     = "RESULT_BUCKET_TEST"
  location = "${var.COMPOSER_REGION}"
}
resource "google_storage_bucket" "dataflow_staging_bucket"{
  name     = "DATAFLOW_STAGING_BUCKET_TEST"
  location = "${var.COMPOSER_REGION}"
}


# Create Composer Environment
resource "google_composer_environment" "env" {
  provider = "google-beta"
  name     = "staging-composer-env"
  region   = "${var.region}"
  depends_on = ["google_project_service.composerapi",
    "google_project_iam_binding.custom_role_binding",
    "google_project_iam_binding.composer_binding",
    "google_storage_bucket.commitment_file_store"
  ]

  config {
    node_config {
      zone            = "${var.zone}"
      service_account = "${google_service_account.cud_service_account.email}"
    }
    software_config {
      python_version = 3
      airflow_config_overrides = {
        update-pypi = "requirements.txt"
      }

      env_variables = {
        project_id			="${var.project_id}"
	"gcp_project"			="${var.GCP_PROJECT_ID}"
	"gcp_region"			="${var.COMPOSER_REGION}"
	"gcp_zone"			="${var.COMPOSER_ZONE_ID}"
	"dataflow_jar_location_test"	="${var.DATAFLOW_JAR_BUCKET_TEST}"
	"gcs_input_bucket_test"		="${var.INPUT_BUCKET_TEST}"
	"gcs_ref_bucket_test"		="${var.REF_BUCKET_TEST}"
	"gcs_output_bucket_test"	="${var.RESULT_BUCKET_TEST}"
	"dataflow_staging_bucket_test"	="${var.DATAFLOW_STAGING_BUCKET_TEST}"

      }
    }
  }
}
