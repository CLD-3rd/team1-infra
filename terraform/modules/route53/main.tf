resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name
  tags  = var.tags
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

resource "aws_route53_record" "this" {
  count   = length(var.records)
  zone_id = local.zone_id
  name    = var.records[count.index].name
  type    = var.records[count.index].type

  dynamic "alias" {
    for_each = var.records[count.index].alias != null ? [var.records[count.index].alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  ttl     = var.records[count.index].alias == null ? var.records[count.index].ttl : null
  records = var.records[count.index].alias == null ? var.records[count.index].records : null
}

resource "aws_acm_certificate" "wildcard_cert" {
  count             = var.create_acm_certificate ? 1 : 0
  domain_name       = var.acm_domain_name
  validation_method = var.acm_validation_method

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "wildcard_validation" {
  count   = var.create_acm_certificate ? 1 : 0
  name    = tolist(aws_acm_certificate.wildcard_cert[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.wildcard_cert[0].domain_validation_options)[0].resource_record_type
  zone_id = local.zone_id
  records = [tolist(aws_acm_certificate.wildcard_cert[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
  count                   = var.create_acm_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.wildcard_cert[0].arn
  validation_record_fqdns = [aws_route53_record.wildcard_validation[0].fqdn]
}