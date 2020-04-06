# Enable all required services

resource "google_project_service" "iam_service" {
  project            = "${var.project_id}"
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_service" "cloudfunctions_service" {
  project            = "${var.project_id}"
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_service" "iamcreds_service" {
  project            = "${var.project_id}"
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_service" "cloudresource_service" {
  project            = "${var.project_id}"
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_service" "storage_service" {
  project            = "${var.project_id}"
  service            = "storage-component.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_service" "pubsub_service" {
  project            = "${var.project_id}"
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}


resource "google_project_service" "cloudkms_service" {
  project            = "${var.project_id}"
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudtasks_service" {
  project            = "${var.project_id}"
  service            = "cloudtasks.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudscheduler_service" {
  project            = "${var.project_id}"
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

# App engine has to exist

resource "google_app_engine_application" "appengine_app" {
  project     = "${var.project_id}"
  location_id = "us-central"
}

# Service Accounts

resource "google_service_account" "cloudwright_admin" {
  project      = "${var.project_id}"
  account_id   = "${var.deployment_zone_namespace}-cw-admin"
  display_name = "${var.deployment_zone_name} CloudWright Admin"
  description  = "Used by CloudWright to create and manage resource for the ${var.deployment_zone_name} deployment zone"
  depends_on   = [google_project_service.iam_service, google_project_service.iamcreds_service]
}

resource "google_service_account" "cloudwright_function" {
  project      = "${var.project_id}"
  account_id   = "${var.deployment_zone_namespace}-cw-fn"
  display_name = "${var.deployment_zone_name} CloudWright Function"
  description  = "Used by CloudWright applications as the Cloud Function service account. Permissions granted to this account are granted to ALL applications in the ${var.deployment_zone_name} deployment zone"
  depends_on   = [google_project_service.iam_service, google_project_service.iamcreds_service]
}

resource "google_service_account" "cloudwright_invoker" {
  project      = "${var.project_id}"
  account_id   = "${var.deployment_zone_namespace}-cw-invk"
  display_name = "${var.deployment_zone_name} CloudWright Invoker"
  description  = "Used by CloudWright to invoke applications in certain contexts (e.g. Cloud Scheduler)"
  depends_on   = [google_project_service.iam_service, google_project_service.iamcreds_service]
}

resource "google_storage_bucket" "cloudwright_artifacts" {
  project    = "${var.project_id}"
  name       = "${var.project_id}-${var.deployment_zone_namespace}-cw-artifacts"
  location   = "US"
  depends_on = [google_project_service.storage_service]
}

resource "google_storage_bucket_iam_member" "admin_bucket_admin" {
  bucket = google_storage_bucket.cloudwright_artifacts.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_storage_bucket_iam_member" "admin_bucket_owner" {
  bucket = google_storage_bucket.cloudwright_artifacts.name
  role   = "roles/storage.legacyBucketOwner"
  member = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_cloudfunctions_admin" {
  project = "${var.project_id}"
  role    = "roles/cloudfunctions.admin"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_cloudscheduler_admin" {
  project = "${var.project_id}"
  role    = "roles/cloudscheduler.admin"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_pubsub_admin" {
  project = "${var.project_id}"
  role    = "roles/pubsub.admin"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_monitoring_viewer" {
  project = "${var.project_id}"
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_logging_viewer" {
  project = "${var.project_id}"
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_logging_writer" {
  project = "${var.project_id}"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "admin_cloudtasks_admin" {
  project = "${var.project_id}"
  role    = "roles/cloudtasks.admin"
  member  = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_service_account_iam_member" "admin-impersonate-function" {
  service_account_id = google_service_account.cloudwright_function.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_service_account_iam_member" "admin-impersonate-invoker" {
  service_account_id = google_service_account.cloudwright_invoker.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_project_iam_member" "function_pubsub_publisher" {
  project = "${var.project_id}"
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloudwright_function.email}"
}

resource "google_project_iam_member" "function_cloudfunction_invoker" {
  project = "${var.project_id}"
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloudwright_invoker.email}"
}

resource "google_kms_key_ring" "cloudwright_keyring" {
  project    = "${var.project_id}"
  name       = "${var.deployment_zone_namespace}-cw-keyring"
  location   = "global"
  depends_on = [google_project_service.cloudkms_service]
}

resource "google_kms_crypto_key" "cloudwright_key" {
  name            = "${var.deployment_zone_namespace}-cw-key"
  key_ring        = google_kms_key_ring.cloudwright_keyring.self_link

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_key_ring_iam_member" "admin_own_cloudwright_keyring" {
  key_ring_id = google_kms_key_ring.cloudwright_keyring.self_link
  role        = "roles/owner"
  member      = "serviceAccount:${google_service_account.cloudwright_admin.email}"
}

resource "google_kms_key_ring_iam_member" "function_use_cloudwright_keyring" {
  key_ring_id = google_kms_key_ring.cloudwright_keyring.self_link
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = "serviceAccount:${google_service_account.cloudwright_function.email}"
}
