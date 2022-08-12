variable "profile" {
  type = string
}

variable "prefix" {
  type    = string
  default = "hoge"
}

variable "my_ips" {
  type = list(string)
}
