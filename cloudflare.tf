resource "cloudflare_zone" "samatar" {
  zone = "samatar.dev"
}

resource "cloudflare_record" "marhaban" {
  zone_id = cloudflare_zone.samatar.id
  name    = "marhaban"
  value   = "c.storage.googleapis.com"
  type    = "CNAME"
  proxied = true
}


