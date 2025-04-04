/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  int_required_roles = [
    "roles/bigquery.admin",
    "roles/aiplatform.admin",
    "roles/cloudfunctions.admin",
    "roles/dataform.admin",
    "roles/datalineage.viewer",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/logging.configWriter",
    "roles/resourcemanager.projectIamAdmin",
    "roles/run.invoker",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
    "roles/workflows.admin"
  ]
}

resource "google_service_account" "int_test" {
  project      = module.project.project_id
  account_id   = "ci-account"
  display_name = "ci-account"
}

resource "google_project_iam_member" "int_test" {
  count = length(local.int_required_roles)

  project = module.project.project_id
  role    = local.int_required_roles[count.index]
  member  = "serviceAccount:${google_service_account.int_test.email}"
}

resource "google_service_account_key" "int_test" {
  service_account_id = google_service_account.int_test.id
}

resource "google_project_iam_member" "bq_encryption_account" {
  depends_on = [data.google_bigquery_default_service_account.initialize_encryption_account] #waits for account initialization
  project    = module.project.project_id
  role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member     = "serviceAccount:${data.google_bigquery_default_service_account.initialize_encryption_account.email}"
}
