# export the acm certificate arn
output "certificate_arn" {
  value = aws_acm_certificate_validation.acm_certificate_validation.certificate_arn
}

# export the domain name
output "domain_name" {
  value = aws_acm_certificate.acm_certificate.domain_name
}