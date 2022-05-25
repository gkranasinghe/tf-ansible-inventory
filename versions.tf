terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.15.1"
    }

    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }

    null = {
      source = "hashicorp/null"
      version = "3.1.1"
    }


  }

  required_version = ">= 1.1.9"
}



provider "aws" {
  # Configuration options
}


provider "local" {
  # Configuration options
}


provider "null" {
  # Configuration options
}