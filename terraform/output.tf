output "password" {
  value = "${aws_iam_user_login_profile.candidate.encrypted_password}"
}
