provider "cloudflare" {
  version = "~> 2.0"
}

resource "cloudflare_zone" "samatar" {
  zone = "samatar.dev"
}

resource "cloudflare_record" "design" {
  zone_id = "${cloudflare_zone.samatar.id}"
  name    = "design"
  value   = "c.storage.googleapis.com"
  type    = "CNAME"
  proxied = true
}


