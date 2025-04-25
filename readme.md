
# Jenkins AWS EKS Cluster Deployment

This guide provides an automated deployment process for an **AWS EKS** cluster with **EFS CSI driver** pre-configured for Jenkins deployment on the EKS cluster. The steps include setting up the required infrastructure, deploying Jenkins, and cleaning up the environment.

## Prerequisites

Before starting, ensure that you have the following tools installed:

- **[Helm](https://helm.sh/docs/intro/install/)** (v3.8.0)
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)** (v1.21)
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** (v2.5.6)
- **[Terraform](https://www.terraform.io/downloads)** (v0.13.0)

## Infrastructure Setup

1. **Initialize Terraform:**
   Run the following command to initialize Terraform:
   ```bash
   terraform init
   ```

2. **Configure Variables:**
    - Modify the `custom.tfvars.TEMPLATE` file to suite your environment.
    - Rename it to `custom.tfvars` after making your changes

3. **Deploy Infastructure:** Run the following commands to apply the configuration:
    ```bash
    terraform plan --var-file="custom.tfvars"
    ```
    - If everything looks correct then run the following.

    ```bash
    terraform apply --var-file="custom.tfvars"
    ```
    - This will take approximately **25 minutes** to deploy the infastructure.

4. **Update Persistent Volumne Configuration:**
    - After Terraform ahs completed the deployment, open the `cluster-efs-pv.yaml` file.
    - Apply your **Access PointID** and **EFS File System ID** as shown in the example.

5. **Update Kubernetes Context:**
    - Once the infastructure is deployed, update your Kubernetes context using the following command:
    ```bash
    aws eks --region us-east-1 update-kubeconfig --name jenkins_playground
    ```
## Jenkins Installation

1. **Verify Kubernetes Service:** Check that your Kubernetes service is funning with:
    ```bash
    kubectl get svc
    ```

2. **Deploy Amazon EFS CSI Driver:** Apply the Amazon EFS CSI driver to the cluster:
    ```bash
    kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
    ```

3. **Navigate to Jenkins Deployment Directory:** Change to the Kubernetes Jenkins deployment folder:
    ```bash
    cd ../k8s/jenkins-pv
    ```

4. **Apply Persistent Volume Files:** Apply the Persistent Volume (PV) configuration files to the cluster:
    ```bash
    kubectl apply -f cluster-efs-claim.yaml,cluster-efs-pv.yaml,cluster-efs-sc.yaml
    ```

5. **Verify PV and PVC Status:** Ensure that the Persistent Volumes and Claims are properly created:
    ```bash
    kubectl get sc,pv,pvc
    ```

6. **Update Helm Repository:** Update your Helm repositories:
    ```bash
    helm repo add stable https://charts.helm.sh/stable
    helm repo update
    ```

7. **Install Jenkins:** Install Jenkins using Helm with the EFS volume claim:
    ```bash
    helm install jenkins stable/jenkins --set rbac.create=true,master.servicePort=80,master.serviceType=LoadBalancer,persistence.existingClaim=efs-claim
    ```

8. **Get Jenkins External IP:** Retrieve the external IP for Jenkins to access the UI:
    ```bash
    kubectl get svc jenkins
    ```

## Cleanup

1. **Delete Jenkins Service:** Remove the Jenkins service from Kubernetes:
    ```bash
    kubectl delete svc jenkins
    ```

2. **Delete Persistent Volumes:** Delete the Persistent Volume resources:
    ```bash
    kubectl delete -f cluster-efs-claim.yaml,cluster-efs-pv.yaml,cluster-efs-sc.yaml
    ```

3. **Navigate Back to Terraform Directory:** Change to the Terraform directory:
    ```bash
    cd ../../terraform/
    ```

4. **Destroy Infrastructure:** Run the following Terraform command to destroy the infrastructure:
    ```bash
    terraform destroy
    ```

## Documentation Refrences

**EKS Cluster Setup Using Terraform:** [EKS-cluster](https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/)

**EKS Cluster Walkthrough Video:** [EKS-cluster-walkthrough-video](https://www.youtube.com/watch?v=MZyrxzb7yAU)

**Jenkins Deployment on EKS with EFS:** [Jenkins-Deployment](https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/)