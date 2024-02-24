#Cloudflare CNAME Records
resource "cloudflare_record" "a_record" {
  zone_id = local.cloudflare_secret["cloudflare_zone_id"]
  name    = "app" # Subdomain part (app.teameclypse.be)
  type    = "CNAME"
  value   = aws_lb.ecs_alb.dns_name
  proxied = true
}

resource "cloudflare_record" "api_a_record" {
  zone_id = local.cloudflare_secret["cloudflare_zone_id"]
  name    = "api"  # Subdomain for the API (api.teameclypse.be)
  type    = "CNAME"
  value   = aws_lb.ecs_alb_backend.dns_name
  proxied = true
}

resource "cloudflare_record" "monitoring_a_record" {
  zone_id = local.cloudflare_secret["cloudflare_zone_id"]
  name    = "monitoring"  # Subdomain for the API (monitoring.teameclypse.be)
  type    = "CNAME"
  value   = aws_lb.ecs_alb_monitoring.dns_name
  proxied = true
}


# #Cloudflare WAF rules
# # Firewall rule to allow traffic from your front-end domain
# resource "cloudflare_firewall_rule" "allow_frontend" {
#   zone_id    = local.cloudflare_secret["cloudflare_zone_id"]
#   action     = "allow"
#   priority   = 1
#   filter_id  = cloudflare_filter.frontend.id
#   description = "Allow requests from front-end"
# }

# resource "cloudflare_filter" "frontend" {
#   zone_id     = local.cloudflare_secret["cloudflare_zone_id"]
#   expression  = "(http.host eq \"api.teameclypse.be\" and http.referer contains \"app.teameclypse.be\")"
#   paused      = false
#   description = "Filter for front-end requests to API"
# }

# # Firewall rule to block all other traffic to the API
# resource "cloudflare_firewall_rule" "block_others" {
#   zone_id    = local.cloudflare_secret["cloudflare_zone_id"]
#   action     = "block"
#   priority   = 2
#   filter_id  = cloudflare_filter.others.id
#   description = "Block all other requests to API"
# }

# resource "cloudflare_filter" "others" {
#   zone_id     = local.cloudflare_secret["cloudflare_zone_id"]
#   expression  = "http.host eq \"api.teameclypse.be\" and not http.referer contains \"app.teameclypse.be\""
#   paused      = false
#   description = "Filter to block other requests to API"
# }
