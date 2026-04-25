variable "was_instance_type" {
  description = "WAS EC2 default Instance type"
  default     = "t4g.micro"
}

variable "my_ip" {
  description = "My public IP address for SSH access"
  type        = string
}

variable "my_ami" {
  description = "WAS golden image"
  type        = string
}

variable "db_name" {
  description = "DB name"
  type        = string
  default     = "my_db"
}

variable "username" {
  description = "RDS username"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "RDS account password"
  type        = string
  sensitive   = true
}
