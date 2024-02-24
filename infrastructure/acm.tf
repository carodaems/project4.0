data "external" "dns_check_front" {
  program = ["sh", "./check_dns.sh", local.cloudflare_secret["cloudflare_zone_id"], "app.teameclypse.be", local.cloudflare_secret["cloudflare_api_token"]]
}
data "external" "dns_check_back" {
  program = ["sh", "./check_dns.sh", local.cloudflare_secret["cloudflare_zone_id"], "api.teameclypse.be", local.cloudflare_secret["cloudflare_api_token"]]
}
data "external" "dns_check_monitoring" {
  program = ["sh", "./check_dns.sh", local.cloudflare_secret["cloudflare_zone_id"], "monitoring.teameclypse.be", local.cloudflare_secret["cloudflare_api_token"]]
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "app.teameclypse.be"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

resource "aws_acm_certificate" "api_cert" {
  domain_name       = "api.teameclypse.be"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

resource "aws_acm_certificate" "monitoring_cert" {
  domain_name       = "monitoring.teameclypse.be"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_acm_certificate.cert.domain_validation_options : record.resource_record_name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_cert" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_acm_certificate.api_cert.domain_validation_options : record.resource_record_name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "monitoring_cert" {
  certificate_arn         = aws_acm_certificate.monitoring_cert.arn
  validation_record_fqdns = [for record in aws_acm_certificate.monitoring_cert.domain_validation_options : record.resource_record_name]

  lifecycle {
    create_before_destroy = true
  }
}


resource "cloudflare_record" "cert_validation" {
  for_each = { 
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    } if data.external.dns_check_front.result["exists"] == "false"
  }

  zone_id = local.cloudflare_secret["cloudflare_zone_id"]
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = 120
  proxied = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "api_cert_validation" {
  for_each = { 
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    } if data.external.dns_check_back.result["exists"] == "false"
  }

  zone_id = local.cloudflare_secret["cloudflare_zone_id"]
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = 120
  proxied = false

  lifecycle {
    create_before_destroy = true
  }
}


resource "cloudflare_record" "monitoring_cert_validation" {
  for_each = { 
    for dvo in aws_acm_certificate.monitoring_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    } if data.external.dns_check_monitoring.result["exists"] == "false"
  }

  zone_id = local.cloudflare_secret["cloudflare_zone_id"]
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = 120
  proxied = false

  lifecycle {
    create_before_destroy = true
  }
}


output "acm_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "api_acm_certificate_arn" {
  value = aws_acm_certificate.api_cert.arn
}

output "monitoring_acm_certificate_arn" {
  value = aws_acm_certificate.monitoring_cert.arn
}

