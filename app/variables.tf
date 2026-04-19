variable "was_instance_type" {
  description = "WAS EC2 default Instance type"
  default     = "t4g.micro"
}

variable "my_ip" {
  description = "My public IP address for SSH access"
  type        = string
}
