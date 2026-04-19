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
