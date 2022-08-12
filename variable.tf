variable "prefix" {
  type    = string
  default = "hoge"
}

variable "region" {
  type = string
}

variable "allow_ips" {
  type = list(string)
}

variable "authorized_keys" {
  type = list(string)
}

variable "zone_name" {
  type = string
}

variable "cf_domain_name" {
  type = string
}
