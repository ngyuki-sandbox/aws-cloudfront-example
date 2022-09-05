variable "prefix" {
  type    = string
  default = "hoge"
}

variable "region" {
  type = string
}

variable "allow_ssh_ips" {
  type = list(string)
}

variable "allow_s3_ips" {
  type = list(string)
}

variable "allow_cf_ips" {
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
