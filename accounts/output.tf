output "security_auditor_key_id" {
  value = aws_iam_access_key.security_auditor.id
}

output "security_auditor_key_secret" {
  value = aws_iam_access_key.security_auditor.secret
}
