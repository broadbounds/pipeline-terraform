variable "access_key" {
  type        = string
  default     = ""
}

variable "secret_key" {
  type        = string
  default     = ""
}

variable "key_name" {
  type        = string
  default     = "ssh_private_key"
}

variable "key_path" {
  type        = string
  default     = "~/.ssh/"
}
