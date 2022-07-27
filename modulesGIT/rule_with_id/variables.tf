variable "type" {

}

variable "rules" {
  type = map(any)
  default = {
    "" = ["", "", "", "", ""]
  }
}

variable "security_group_id" {

}