# Test Case with NGINX Ingress Controller

## Steps
1. Create 3 GKE clusters
2. Use helm chart to install helm on each cluster
    ```
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm install nginx-ingress ingress-nginx/ingress-nginx
3. Annotate the nginx ingress service to use NEG
    ```
    kubectl annotate service nginx-ingress-ingress-nginx-controller cloud.google.com/neg='{"exposed_ports": {"443":{}}}'
    ```
4. Run terraform to deploy GLB. Modify `terraform/terraform.tfvars` as needed. The external IP will be outputted. 
    ```
    cd terraform
    terraform init
    terraform plan
    terraform apply -autoapprove
    ```
5. Create TLS cert with the external IP:
    ```
    export KEY_FILE=key.key
    export CERT_FILE=key.crt
    export HOST=<outputted IP from terraform>
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}"
    kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
    ```

6. Install BackendServiceBinding CRD and deploy a nginxbinding. 

7. Modify `apiVersion`, `kind`, `gcpProject` values in the manifest in `manifests/nginxbackend.yaml` as needed. 
    ```
    kubectl apply -f manifests/nginxbackend.yaml
    ```
8. Deploy a sample app with Nginx ingress
    ```
    kubectl apply -f manifests/zoneprinter.yaml
    ```
9. Access the deployed app at 'http://<outputted IP from terraform>/zone'

Scale down `nginx-ingress-ingress-nginx-controller` deployment to 0 in two of the clusters. Refresh the page to see if the app is still accessible. 

Go to Cloud Logging and search for GLB logs using query: `jsonPayload.@type="type.googleapis.com/google.cloud.loadbalancing.type.LoadBalancerLogEntry"`