output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.main.version
}

output "configure_kubectl" {
  description = "Run this command to configure kubectl to connect to the cluster"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
}

output "eks_addons" {
  description = "Default EKS addons installed on the cluster"
  value = {
    vpc_cni            = aws_eks_addon.vpc_cni.addon_name
    coredns            = aws_eks_addon.coredns.addon_name
    kube_proxy         = aws_eks_addon.kube_proxy.addon_name
    pod_identity_agent = aws_eks_addon.pod_identity_agent.addon_name
  }
}
