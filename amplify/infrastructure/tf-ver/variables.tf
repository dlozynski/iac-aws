variable "aws_account" {
  type        = string
  description = "Account number"
}
variable "repo" {
  type        = string
  description = "Application repo name."
}
variable "app_name_main" {
  type        = string
  description = "AWS Amplify Main application name."
}
variable "app_name_admin" {
  type        = string
  description = "AWS Amplify Admin application name."
}
variable "access_token" {
  type        = string
  description = "Repo access token."
}
variable "domain_name" {
  type        = string
  description = "Domain name for main app."
}
variable "subdomain_name_main" {
  type        = string
  description = "Subdomain name for main app."
}
variable "subdomain_name_admin" {
  type        = string
  description = "Subdomain name for admin app."
}
variable "amplify_amazon_client_id" {
  type        = string
  description = "amplify_amazon_client_id"
}
variable "amplify_amazon_client_secret" {
  type        = string
  description = "amplify_amazon_client_secret"
}
variable "amplify_facebook_client_id" {
  type        = string
  description = "amplify_facebook_client_id"
}
variable "amplify_facebook_client_secret" {
  type        = string
  description = "amplify_facebook_client_secret"
}
variable "amplify_google_client_id" {
  type        = string
  description = "amplify_google_client_id"
}
variable "amplify_google_client_secret" {
  type        = string
  description = "amplify_google_client_secret"
}
variable "amplify_identitypool_id" {
  type        = string
  description = "amplify_identitypool_id"
}
variable "amplify_nativeclient_id" {
  type        = string
  description = "amplify_nativeclient_id"
}
variable "amplify_userpool_id" {
  type        = string
  description = "amplify_userpool_id"
}
variable "amplify_webclient_id" {
  type        = string
  description = "amplify_webclient_id"
}
variable "email" {
  type        = string
  description = "SES email"
}






