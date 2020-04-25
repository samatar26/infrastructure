provider "cloudflare" {
  version = "~> 2.0"
}

resource "cloudflare_zone" "samatar" {
  zone = "samatar.dev"
}


