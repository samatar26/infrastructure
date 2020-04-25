provider "cloudflare" {
  version = "~> 2.0"
}

resource "cloudflare_zone" "samatar" {
  zone = "samatar.dev"
}

resource "cloudflare_" "name" {
  zone_id = "${cloudflare_zone.samatar.zone_id}"
  name    = "design"
  value   = "c.storage.googleapis.com"
  type    = "CNAME"
}


