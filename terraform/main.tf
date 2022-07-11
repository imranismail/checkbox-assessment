provider "aws" {
  region = "ap-southeast-1"
}

provider "random" {}

resource "aws_secretsmanager_secret" "this" {
  name = "shopping-cart-redis"
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    db_password = random_password.db_password.result
  })
}