# Jenkins AWS EKS Cluster Deployment

Automated Deployment of a AWS EKS cluster with EFS CSI driver pre-configured for jenkins deployment on the EKS cluster.

## Prerequisites that need to be installed

- [helm](https://helm.sh/docs/intro/install/) (v3.8.0)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.21)
- [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (v2.5.6)
- [terraform](https://www.terraform.io/downloads) (v13.0.0)

## Install Infastructure

1. In the terraform folder run `terraform init`
2. Modify the custom.tfvars.TEMPLATE file to your liking and then rename to `custom.tfvars`
3. Then run `terraform apply --var-file="custom.tfvars"` this will take about 25min to deploy
4. Open `cluster-efs-pv.yaml` and apply the access-point-id, and efs-file-system-id like the example in the yaml file.
5. Once terraform has deployed the cluster you will need to update your Kubernetes context by using `aws eks --region us-east-1 update-kubeconfig --name jenkins_playground`

## Install Jenkins

1. Check that the Kubernetes service is running `kubectl get svc`
2. Deploy the Amazon EFS CSI driver `kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"`
3. Next cd into the k8s folder `cd ../k8s/jenkins-pv`
4. Now run the pv yaml's `kubectl apply -f .\cluster-efs-claim.yaml,.\cluster-efs-pv.yaml,.\cluster-efs-sc.yaml`
5. Check that they are running `kubectl get sc,pv,pvc`
6. Update helm repo to stable `helm repo add stable https://charts.helm.sh/stable`
7. Install jenkins to the cluster `helm install jenkins stable/jenkins --set rbac.create=true,master.servicePort=80,master.serviceType=LoadBalancer,persistence.existingClaim=efs-claim`
8. Get external IP for jenkins `kubectl get svc jenkins`

## Cleanup

1. `kubectl delete svc jenkins`
2. `kubectl delete -f .\cluster-efs-claim.yaml,.\cluster-efs-pv.yaml,.\cluster-efs-sc.yaml`
3. `cd ..\..\terraform\`
4. `terraform destroy`

## Documentation Used in creation of cluster

- [EKS-cluster](https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/)
- [EKS-cluster-walkthrough-video](https://www.youtube.com/watch?v=MZyrxzb7yAU)
- [Jenkins-Deployment](https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/)
