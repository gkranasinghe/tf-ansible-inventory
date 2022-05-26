module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset([for x in range(3) : tostring(x)])

  name = "instance-${each.key}"

  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_key_name
  monitoring             = true
  vpc_security_group_ids = [module.frontend-sg.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  depends_on = [
    module.key_pair
  ]
}

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] #canonical 
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {

  source  = "terraform-aws-modules/key-pair/aws"
  version = "1.0.1"

  key_name   = "ansible-key"
  public_key = tls_private_key.this.public_key_openssh

    tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "local_sensitive_file" "private_key" {
    content  = tls_private_key.this.private_key_pem
    filename = "${path.module}/ansible-key.pem"
    file_permission = "0400"
    
}

module "frontend-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "allow ssh "
  description = "Security group for SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

resource "local_file" "inventory" {
  filename = "inventory"
  content = templatefile("template-inventory.tpl",
    {
      vm_web = zipmap([ for instance in module.ec2_instances : instance.tags_all.Name], [ for instance in module.ec2_instances : instance.public_ip] ) #,
      
      # vm_api = zipmap([ for instance in module.ec2_instances : instance.tags_all.Name], [ for instance in module.ec2_instances : instance.public_ip] ),
      # vm_db = zipmap([ for instance in module.ec2_instances : instance.tags_all.Name], [ for instance in module.ec2_instances : instance.public_ip] )
  })
}