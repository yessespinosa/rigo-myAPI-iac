terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.16.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

# provider "docker" {
#   host = "npipe:////.//pipe//docker_engine" # Comenta esta linea si eres usuario MacOS o Linux
# }

resource "docker_image" "microservice" {
  name = "microservice"
  build {
    path = "../microservice/."
    tag = [
      "microservice:latest"
    ]
  }
}

resource "docker_container" "microservice" {
  image = docker_image.microservice.latest
  name  = "microservice-demo"
  ports {
    internal = 5000
    external = 5000
  }
  depends_on = [
    docker_image.microservice
  ]
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "dev-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev-subnet-public-1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-1a"
  tags = {
    Name = "dev-subnet-public-1"
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.dev-subnet-public-1.id
  tags = {
    Name        = "dev-server-1",
    Environment = "Develop",
    Owner       = "iGomezP"

  }
}