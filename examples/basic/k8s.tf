locals {
  zone   = "example.com"
  name   = "k8s.${local.zone}"
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "kubernetes_admin" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Condition = {}
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::724902258495:root"
        }
      },
    ]
    Version = "2012-10-17"
  })
  description = "Kubernetes administrator role (for AWS IAM Authenticator for Kubernetes)."
}

module "external_secrets" {
  source     = "opzkit/k8s-addons-external-secrets/aws"
  version    = "8.3.0"
  account_id = data.aws_caller_identity.current.account_id
  name       = local.name
  region     = local.region
}

module "state_store" {
  source           = "opzkit/kops-state-store/aws"
  version          = "0.0.2"
  state_store_name = "some-kops-storage-s3-bucket"
}

module "k8s-network" {
  source              = "opzkit/k8s-network/aws"
  version             = "0.0.5"
  name                = local.name
  region              = local.region
  public_subnet_zones = ["a", "b", "c"]
  vpc_cidr            = "172.20.0.0/16"
}

module "k8s" {
  depends_on              = [module.state_store]
  source                  = "opzkit/k8s/aws"
  version                 = "0.1.2"
  name                    = local.name
  region                  = local.region
  dns_zone                = local.zone
  kubernetes_version      = "1.21.5"
  master_count            = 3
  vpc_id                  = module.k8s-network.vpc_id
  public_subnet_ids       = module.k8s-network.public_subnets
  iam_role_name           = aws_iam_role.kubernetes_admin.arn
  state_store_bucket_name = module.state_store.bucket
  admin_ssh_key           = "../dummy_ssh_private"
  aws_oidc_provider       = true
  service_account_external_permissions = [
    module.external_secrets.permissions
  ]
  extra_addons = [
    module.external_secrets.addon
  ]
}
