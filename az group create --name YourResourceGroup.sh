az group create --name YourResourceGroupName --location eastus \
az aks create --resource-group aks-prod-rg --name aks-prod-cluster --node-count 2 --node-vm-size Standard_DS2_v2 \
                      --enable-addons monitoring --generate-ssh-keys \
                      --network-plugin azure --service-cidr 10.1.0.0/16 --dns-service-ip 10.1.0.10 --docker-bridge-address 172.17.0.1/16 \
                      --location eastus \
&& az aks get-credentials --resource-group aks-prod-rg --name aks-prod-cluster

az aks show --resource-group aks-prod-rg --name aks-prod-cluster --query servicePrincipalProfile.clientId -o tsv
# Attach using acr-name
az aks update -n aks-prod-cluster -g  aks-prod-rg --attach-acr aksprodacr 

# Attach using acr-resource-id
az aks update -n myAKSCluster -g myResourceGroup --attach-acr <acr-resource-id>



az network public-ip create --resource-group MC_aks-prod-rg_aks-prod-cluster_eastus \
                            --name aksprodpipIngress \
                            --sku Standard \
                            --allocation-method static \
                            --query publicIp.ipAddress 
                            -o tsv

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
kubectl create namespace ingress-basic

helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="40.71.160.13" 



az group delete --name aks-prod-rg --yes --no-wait