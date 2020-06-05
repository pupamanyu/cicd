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


# REQUIRED TO EDIT:
variable project_id {
  description = "Your newly created project ID"
}

# OPTIONAL TO EDIT:
variable region {
  description = "The Compute Engine region for Composer to run in: us-central1 or europe-west1"
  default     = "us-central1"
}

# OPTIONAL TO EDIT:
variable zone {
  description = "The Compute Engine zone: us-central1-f or europe-west1-b"
  default     = "us-central1-f"
}