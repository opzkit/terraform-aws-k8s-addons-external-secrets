# terraform-aws-k8s-addons-external-secrets

**DEPRECATED**

Please use [terraform-aws-k8s-addons-external-secrets-operator](https://github.com/opzkit/terraform-aws-k8s-addons-external-secrets-operator) instead



A terraform module which provides
the [IRSA external permissions](https://kops.sigs.k8s.io/cluster_spec/#service-account-issuer-discovery-and-aws-iam-roles-for-service-accounts-irsa)
and the [custom addon](https://kops.sigs.k8s.io/addons/#custom-addons)
for [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used together
with [opzkit/k8s/aws](https://registry.terraform.io/modules/opzkit/k8s/aws/latest).

