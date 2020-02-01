
output "cloudwright_admin" {
  value = google_service_account.cloudwright_admin
}

output "cloudwright_function" {
  value = google_service_account.cloudwright_function
}

output "cloudwright_invoker" {
  value = google_service_account.cloudwright_invoker
}

output "cloudwright_artifacts" {
  value = google_storage_bucket.cloudwright_artifacts
}

output "cloudwright_keyring" {
  value = google_kms_key_ring.cloudwright_keyring
}

output "cloudwright_key" {
  value = google_kms_crypto_key.cloudwright_key
}

